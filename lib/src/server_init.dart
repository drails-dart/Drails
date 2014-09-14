part of drails;

final _serverInitLog = new Logger('server_init');

HttpServer drailsServer;

Map<String, Function> GET = {}, POST = {}, PUT = {}, DELETE = {};

/**
 * Initialize the server with the given arguments
 */
void initServer(List<Symbol> includedLibs, {InternetAddress address , int port : 4040}) {
  address = address != null ? address : InternetAddress.LOOPBACK_IP_V4;
  _serverInitLog.fine('address: $address, port: $port');
  
  ApplicationContext.bootstrap(includedLibs);

  var controllers = ApplicationContext.controllers;
  
  HttpServer.bind(address, port).then((server) {
    drailsServer = server;
    var router = new Router(server);

    controllers.forEach((controller) {
      var controllerIm = reflect(controller),
          controllerCm = controllerIm.type,
          controllerName = MirrorSystem.getName(controllerCm.simpleName).replaceFirst('Controller', '').toLowerCase(),
          controllerMms = getMethodMirrorsFromClass(controllerCm);
      
      controllerMms.forEach((MethodMirror controllerMm) {
        var controllerMethodName = MirrorSystem.getName(controllerMm.simpleName);

        var urlPath = '/$controllerName',
            method = 'GET',
            wordPath = '/(\\w+)',
            pathParamBegin = 1;
        switch (controllerMethodName) {
          case 'get':
            urlPath += wordPath;
            break;
          case 'getAll':
            break;
          case 'save':
            urlPath += wordPath;
            method = 'PUT';
            break;
          case 'saveAll':
            method = 'POST';
            break;
          case 'delete':
            urlPath += wordPath;
            method = 'DELETE';
            break;
          case 'deleteAll':
            method = 'DELETE';
            break;
          default:
            urlPath += '/$controllerMethodName';
            pathParamBegin = 2;
            if(new IsAnnotation<_Post>().onDeclaration(controllerMm)) {
              method = 'POST';
            }
            controllerMm.parameters.forEach((param) {
              if(!new IsAnnotation<_RequestBody>().onDeclaration(param)
                  && param.type != reflectClass(HttpRequest)
                  && param.type != reflectClass(HttpSession))
              urlPath += wordPath;
            });
        }

        _serverInitLog.info('method: $method, url: $urlPath');

        router.serve(new UrlPattern(urlPath), method: method).listen((request) {
          _process(request, controllerIm, controllerMm, pathParamBegin);
        });
      });
    });

    router.serve('/').listen((req) => req.response
        ..write("Hello")
        ..close());
    
    <String, Map<String, Function>>{'GET': GET, 'POST': POST, 'PUT': PUT, 'DELETE': DELETE}.forEach((method, methodsMap) {
      methodsMap.forEach((url, function) {
        _serverInitLog.info('method: $method, url: $url');
        router.serve(new UrlPattern(url), method: method).listen((request) {
          ClosureMirror closureMirror = reflect(function);
          _process(request, closureMirror, closureMirror.function);
        });
      });
    });
  });
}

void _process(HttpRequest request, InstanceMirror instanceMirror, MethodMirror methodMirror, [int pathParamBegin = 1]) {
  var pathSegments = request.uri.pathSegments,
      positionalArgs = [], 
      namedArgs = {},
      _ref,
      i = 0,
      removeBrackets = false;

  Iterable<String> pathVariables = pathSegments.length <= pathParamBegin ? [] : pathSegments.getRange(pathParamBegin, pathSegments.length);

  UTF8.decodeStream(request).then((data) {
    try {
      methodMirror.parameters.forEach((parameter) {
        if (parameter.type == reflectClass(HttpRequest)) {
          positionalArgs.add(request);
        } else if (parameter.type == reflectClass(HttpHeaders)) {
          positionalArgs.add(request.headers);
        } else if (parameter.type == reflectClass(HttpSession)) {
          positionalArgs.add(request.session);
        } else if( (parameter.isNamed || new IsAnnotation<RequestParam>().onDeclaration(parameter))
            && (_ref = request.uri.queryParameters[MirrorSystem.getName(parameter.simpleName)]) != null) {
          namedArgs[parameter.simpleName] = _ref;
        } else if(new IsAnnotation<_RequestBody>().onDeclaration(parameter) 
            && data.isNotEmpty) {
          if(parameter.type.qualifiedName == _QN_LIST) {
            if(!(data as String).startsWith('[')) {
              data = '[$data]';
              removeBrackets = true;
            }
            positionalArgs.add(deserializeList(data, parameter.type.typeArguments.first.reflectedType));
          } else {
            positionalArgs.add(deserialize(data, parameter.type.reflectedType));
          }
        } else if(pathVariables.length >= i + 1 ) {
          if (parameter.type == reflectClass(int)) {
            positionalArgs.add(int.parse(pathVariables.elementAt(i++)));
          } else if (parameter.type == reflectClass(String)) {
            positionalArgs.add(pathVariables.elementAt(i++));
          } else if (parameter.type == reflectClass(DateTime)) {
            positionalArgs.add(DateTime.parse(pathVariables.elementAt(i++)));
          } else {_serverInitLog.fine('parameter.type.reflectedType: ${parameter.type.reflectedType}');
            positionalArgs.add(deserialize(pathVariables.elementAt(i++), parameter.type.reflectedType));
          }
        }
      });

      _serverInitLog.fine(
          'invoking controller:'
          '\n\tpathSegments: $pathSegments'
          '\n\tpathVariables: $pathVariables'
          '\n\tcontrollerIm: $instanceMirror'
          '\n\tcontrollerMm: $methodMirror'
          '\n\tpositionalArgs: $positionalArgs'
          '\n\tnamedArgs: $namedArgs');
      
      _invokeControllerMethod(instanceMirror, methodMirror, positionalArgs, namedArgs, request, removeBrackets);
    } catch (e) {
      print(e);
      request.response
        ..statusCode = 400
        ..close();
    }
  });
}

void _invokeControllerMethod(
  InstanceMirror instanceMirror, 
  MethodMirror methodMirror,
  List positionalArgs,
  Map<Symbol, dynamic> namedArgs,
  HttpRequest request,
  bool removeBrackets) {
  
  var user = request.session['user'],
      _ref1 = new GetValueOfAnnotation<AuthorizeIf>().fromInstance(instanceMirror),
      authorizedForControlled = (_ref1 == null) ? true : (user == null) ? false : _ref1.isAuthorized(user, _ref1),
      _ref2 = new GetValueOfAnnotation<AuthorizeIf>().fromDeclaration(methodMirror),
      authorizedForMethod = (_ref2 == null) ? true : (user == null) ? false : _ref2.isAuthorized(user, _ref2);
  
  if(authorizedForControlled && authorizedForMethod) {
    var result;
    if(instanceMirror is ClosureMirror) {
      result = instanceMirror.apply(positionalArgs, namedArgs).reflectee;
    } else {
      result = instanceMirror.invoke(methodMirror.simpleName, positionalArgs, namedArgs).reflectee;
    }
    result = result == null ? "" : serialize(result);
    if(removeBrackets) {
      result = result.substring(1, result.length - 1);
    }
    request.response
        ..write(result)
        ..close();
  } else {
    request.response
      ..statusCode = 401
      ..close();
  }
}
