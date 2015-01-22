part of drails;

final _serverInitLog = new Logger('server_init');

String ENV = 'dev';

/// Instance of the current running server, useful to stop the server.
HttpServer DRAILS_SERVER;

/// Specifies the URI used to get the main html file
String CLIENT_URL = 'index.html';

/// Map that mantains the list of URI that could be used to serve files
Map<String, String> CLIENT_DIR = {
  'dev': '/../../client/web/',
  'prod': '/../../client/build/'
};

Map<String, bool> ENABLE_CORS = {
  'dev': true,
  'prod': false
};
///Maps Used to define fast request functions
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
    DRAILS_SERVER = server;
    
    var router = new Router(server);
    
    _initFileServer(router);

    _initProxyServer(router);
    
    controllers.forEach((controller) => _mapControllers(controller, router));
  });
}

void _initFileServer(Router router) {
    var clientFiles = dirname(Platform.script.toFilePath()) + CLIENT_DIR[ENV];
    
    _serverInitLog.info('clientFiles: $clientFiles');
    
    var virDir = new VirtualDirectory(clientFiles)
      ..allowDirectoryListing = true
      ..jailRoot = false
      ..serve(router.defaultStream)
      ..errorPageHandler = (HttpRequest request) {
          _serverInitLog.warning("Resource not found ${request.uri.path}");
          request.response
              ..statusCode = HttpStatus.NOT_FOUND
              ..close();
        };

    var dirHandler;
    dirHandler = (Directory dir, HttpRequest request) {
      if(dir.path == (clientFiles + './')) {
        var filePath = clientFiles + CLIENT_URL;
        _serverInitLog.info("Serving: $filePath");
        
        Uri fileUri = Platform.script.resolve(filePath);
        File file = new File(fileUri.toFilePath());
        virDir.serveFile(file, request);
      } else {
        virDir
            ..directoryHandler = null
            ..serveRequest(request).then((r) {virDir.directoryHandler = dirHandler;});
      }
    };
    
    virDir.directoryHandler = dirHandler;
}

void _initProxyServer(Router router) {

    <String, Map<String, Function>>{'GET': GET, 'POST': POST, 'PUT': PUT, 'DELETE': DELETE}.forEach((method, methodsMap) {
      methodsMap.forEach((url, function) {
        _serverInitLog.info('method: $method, url: $url');
        router.serve(new UrlPattern(url), method: method).listen((request) {
          ClosureMirror closureMirror = reflect(function);
          _process(request, closureMirror, closureMirror.function);
        });
      });
    });
}

void _mapControllers(Object controller, Router router) {
  var controllerIm = reflect(controller),
      controllerCm = controllerIm.type,
      controllerName = MirrorSystem.getName(controllerCm.simpleName).replaceFirst('Controller', '').toLowerCase(),
      controllerMms = getPublicMethodsFromClass(controllerCm);

  router.serve(new UrlPattern("/$controllerName(/(\\w+))?"), method: 'OPTIONS').listen((request) {
    _writeResponse("", false, request);
  });
  controllerMms.forEach((symbol, MethodMirror controllerMm) {
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
        } else if(new IsAnnotation<_RequestBody>().onDeclaration(parameter) && data.isNotEmpty) {
          if(parameter.type.qualifiedName == QN_LIST) {
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
      authorizedForController = (_ref1 != null && user != null) ?
          _ref1.isAuthorized(user, _ref1) 
          : false,
      _ref2 = new GetValueOfAnnotation<AuthorizeIf>().fromDeclaration(methodMirror),
      authorizedForMethod = (_ref2 != null && user != null) ?
          _ref2.isAuthorized(user, _ref2) 
          : false;
  
  if(_ref1 == null && _ref2 == null || authorizedForController || authorizedForMethod) {
    var result;
    if(instanceMirror is ClosureMirror) {
      result = instanceMirror.apply(positionalArgs, namedArgs).reflectee;
    } else {
      result = instanceMirror.invoke(methodMirror.simpleName, positionalArgs, namedArgs).reflectee;
    }
    
    if(result is Future) {
      result.then((value) => 
          _writeResponse(value, removeBrackets, request));
    } else {
      _writeResponse(result, removeBrackets, request);
    }
    
  } else {
    //TODO: convert this to a trhow NotAuthorizedException
    request.response
      ..statusCode = 401
      ..close();
  }
}

void _writeResponse(result, bool removeBrackets, HttpRequest request) {
  result = result == null ? "" : serialize(result);
  if(removeBrackets) {
    result = result.substring(1, result.length - 1);
  }
  if(ENABLE_CORS[ENV]) {
    request.response.headers
      ..add("Access-Control-Allow-Origin", "*, ")
      ..add("Access-Control-Allow-Methods", "PUT, DELETE, POST, GET, OPTIONS")
      ..add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  }
  request.response
      ..headers.contentType = new ContentType("application", "json", charset: "utf-8")
      ..write(result)
      ..close();
}
