part of drails;

final _serverInitLog = new Logger('server_init');


/**
 * Initialize the server with the given arguments
 */
void initServer({InternetAddress address , int port : 4040}) {
  address = address != null ? address : InternetAddress.LOOPBACK_IP_V4;
  _serverInitLog.fine('address: $address, port: $port');
  
  ApplicationContext.bootstrap();

  var controllers = ApplicationContext.controllers;
  
  
  HttpServer.bind(address, port).then((server) {
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
                  && param.type.simpleName != reflectClass(HttpRequest).simpleName
                  && param.type.simpleName != reflectClass(HttpSession).simpleName)
              urlPath += wordPath;
            });
        }

        _serverInitLog.info('method: $method, url: $urlPath');

        router.serve(new UrlPattern(urlPath), method: method).listen((request) {
          var pathSegments = request.uri.pathSegments;

          Iterable<String> pathVariables = pathSegments.length <= pathParamBegin ? [] : pathSegments.getRange(pathParamBegin, pathSegments.length);

          var positionalArgs = [], 
              namedArgs = {},
              _ref;

          var i = 0, waitFortInvocation = false;
          controllerMm.parameters.forEach((parameter) {
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
                && request.contentLength > 0) {
              waitFortInvocation = true;
              UTF8.decodeStream(request)
                .then((data) {
                  _serverInitLog.fine('RequestBodyData: $data');
                  if(parameter.type.simpleName == _QN_LIST) {
                    if(!(data as String).startsWith('['))
                      data = '[$data]';
                    positionalArgs.add(deserializeList(data, parameter.type.typeArguments.first.reflectedType));
                  } else {
                    positionalArgs.add(deserialize(data, parameter.type.reflectedType));
                  }
                }).then((_) => 
                    _invokeControllerMethod(controllerIm, controllerMm, positionalArgs, namedArgs, request));
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
              '\n\tcontrollerIm: $controllerIm'
              '\n\tcontrollerMm: $controllerMm'
              '\n\tpositionalArgs: $positionalArgs'
              '\n\tnamedArgs: $namedArgs');
          
          if(!waitFortInvocation) 
            _invokeControllerMethod(controllerIm, controllerMm, positionalArgs, namedArgs, request);
        });
      });
    });

    router.serve('/').listen((req) => req.response
        ..write("Hello")
        ..close());
  });
}

void _invokeControllerMethod(
  InstanceMirror controllerIm, 
  MethodMirror controllerMm,
  List positionalArgs,
  Map<Symbol, dynamic> namedArgs,
  HttpRequest request) {
  
  var user = request.session['user'],
      _ref1 = new GetValueOfAnnotation<AuthorizeIf>().fromInstance(controllerIm),
      authorizedForControlled = (_ref1 == null) ? true : (user == null) ? false : _ref1.authorizeFunc(user, _ref1),
      _ref2 = new GetValueOfAnnotation<AuthorizeIf>().fromDeclaration(controllerMm),
      authorizedForMethod = (_ref1 == null && _ref2 == null) ? true : (user == null) ? false : _ref1.authorizeFunc(user, _ref1);
  
  if(authorizedForControlled || authorizedForMethod) {
    var result = controllerIm.invoke(controllerMm.simpleName, positionalArgs, namedArgs).reflectee;
    result = result == null ? "" : serialize(result);
    request.response
        ..write(result)
        ..close();
  } else {
    request.response
      ..statusCode = 401
      ..write("")
      ..close();
  }
}
