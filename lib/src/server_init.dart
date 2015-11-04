part of drails;

final _serverInitLog = new Logger('server_init');

/// Initialize the server with the given arguments
void initServer(List<String> includedLibs, {address , int port : 4040}) {
  address = address != null ? address : '0.0.0.0';
  
  ApplicationContext.bootstrap(includedLibs);

  var controllers = ApplicationContext.controllers;
  
  //Get port from enviroment if server is on heroku
  var envPort = Platform.environment['PORT'];
  
  if(envPort != null) port = int.parse(envPort);
  
  _serverInitLog.fine('address: $address, port: $port');
  
  HttpServer.bind(address, port).then((server) {
    DRAILS_SERVER = server;
    
    var router = new Router(server);
    
    try {
      _initFileServer(router);
    } catch (e) {
      print(e);
    }

    // TODO: add support for this when reflectable support top-level functions
//    _initProxyServer(router);
    
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

//void _initProxyServer(Router router) {
//
//  ApplicationContext.proxyFunctions.forEach((gfmm, lm) {
//    Path _path = new GetValueOfAnnotation<Path>().fromDeclaration(gfmm);
//    String method = _path == null || _path is Get ? "GET" : "POST";
//
//    String url = _path == null || _path.url == null ? gfmm.simpleName : _path.url;
//
//    _serverInitLog.info('method: $method, url: $url');
//    router.serve(new UrlPattern('/$url'), method: method).listen((request) {
//      _process(request, lm, gfmm);
//    });
//  });
//}

void _mapControllers(Object controller, Router router) {
  var controllerIm = injectable.reflect(controller),
      controllerCm = controllerIm.type,
      controllerName = controllerCm.simpleName.replaceFirst('Controller', '').toLowerCase(),
      controllerMms = getPublicMethodsFromClass(controllerCm, injectable),
      controllerPath = new GetValueOfAnnotation<Path>().fromInstance(controllerIm)?.url;

  router.serve(new UrlPattern("/$controllerName(/(\\w+))?"), method: 'OPTIONS').listen((request) {
    _writeResponse("", false, request);
  });

  controllerMms.forEach((symbol, MethodMirror controllerMm) {
    var controllerMethodName = controllerMm.simpleName;

    var urlPath = controllerPath ?? '/$controllerName',
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
        if(new IsAnnotation<Post>().onDeclaration(controllerMm)) {
          method = 'POST';
        }
        controllerMm.parameters.forEach((param) {
          if(!new IsAnnotation<_RequestBody>().onDeclaration(param)
              && param.type.simpleName != 'HttpRequest'
              && param.type.simpleName != 'HttpSession'
              && !param.isOptional)
          urlPath += wordPath;
        });
    }

    _serverInitLog.info('method: $method, url: $urlPath');

    router.serve(new UrlPattern(urlPath), method: method).listen((request) {
      _process(request, controllerIm, controllerMm, pathParamBegin);
    });
  });
}

void _process(HttpRequest request, InstanceMirror mirror, MethodMirror methodMirror, [int pathParamBegin = 1]) {
  var pathSegments = request.uri.pathSegments,
      positionalArgs = [], 
      namedArgs = <Symbol, dynamic>{},
      _ref,
      i = 0,
      removeBrackets = false;

  Iterable<String> pathVariables = pathSegments.length <= pathParamBegin ? [] : pathSegments.getRange(pathParamBegin, pathSegments.length);

  UTF8.decodeStream(request).then((data) {
    try {
      methodMirror.parameters.forEach((parameter) {
        if (parameter.type.simpleName == 'HttpRequest') {
          positionalArgs.add(request);
        } else if (parameter.type.simpleName == 'HttpHeaders') {
          positionalArgs.add(request.headers);
        } else if (parameter.type.simpleName == 'HttpSession') {
          positionalArgs.add(request.session);
        } else if( (parameter.isNamed || new IsAnnotation<RequestParam>().onDeclaration(parameter))
            && (_ref = request.uri.queryParameters[parameter.simpleName]) != null) {
          namedArgs[new Symbol(parameter.simpleName)] = _ref;
        } else if(new IsAnnotation<_RequestBody>().onDeclaration(parameter) && data.isNotEmpty) {
          if(parameter.type.simpleName == SN_LIST) {
            if(!(data as String).startsWith('[')) {
              data = '[$data]';
              removeBrackets = true;
            }
            positionalArgs.add(fromJsonList(data, parameter.type.typeArguments.first.reflectedType));
          } else {
            positionalArgs.add(fromJson(data, parameter.type.reflectedType));
          }
        } else if(pathVariables.length >= i + 1 ) {
          if (parameter.type.simpleName == SN_INT) {
            positionalArgs.add(int.parse(pathVariables.elementAt(i++)));
          } else if (parameter.type.simpleName == SN_STRING) {
            positionalArgs.add(pathVariables.elementAt(i++));
          } else if (parameter.type.simpleName == SN_DATETIME) {
            positionalArgs.add(DateTime.parse(pathVariables.elementAt(i++)));
          } else {_serverInitLog.fine('parameter.type.reflectedType: ${parameter.type.reflectedType}');
            positionalArgs.add(fromJson(pathVariables.elementAt(i++), parameter.type.reflectedType));
          }
        }
      });

      _serverInitLog.fine(
          'invoking controller:'
          '\n\tpathSegments: $pathSegments'
          '\n\tpathVariables: $pathVariables'
          '\n\tcontrollerIm: $mirror'
          '\n\tcontrollerMm: $methodMirror'
          '\n\tpositionalArgs: $positionalArgs'
          '\n\tnamedArgs: $namedArgs');
      
      _invokeControllerMethod(mirror, methodMirror, positionalArgs, namedArgs, request, removeBrackets);
    } on NoAuthorizedError {
      request.response
        ..statusCode = 401
        ..close();
    } catch (e, s) {
      _serverInitLog.fine(e);
      _serverInitLog.fine(s);
      request.response
        ..statusCode = 400
        ..close();
    }
  });
}

void _invokeControllerMethod(
  InstanceMirror mirror,
  MethodMirror methodMirror,
  List positionalArgs,
  Map<Symbol, dynamic> namedArgs,
  HttpRequest request,
  bool removeBrackets) {
  var user = request.session['user'], _ref1, _ref2, authorizedForController = true, authorizedForMethod = true;
  if(mirror is InstanceMirror) {
    _ref1 = new GetValueOfAnnotation<AuthorizeIf>().fromInstance(mirror);
    authorizedForController = (_ref1 != null && user != null) ?
      _ref1.isAuthorized(user, _ref1)
      : false;
    _ref2 = new GetValueOfAnnotation<AuthorizeIf>().fromDeclaration(methodMirror);
    authorizedForMethod = (_ref2 != null && user != null) ?
      _ref2.isAuthorized(user, _ref2)
      : false;
  }

  
  if(_ref1 == null && _ref2 == null || authorizedForController || authorizedForMethod) {

    var result = mirror.invoke(methodMirror.simpleName, positionalArgs, namedArgs);

    if(result is Future) {
      result.then((value) => 
          _writeResponse(value, removeBrackets, request));
    } else {
      _writeResponse(result, removeBrackets, request);
    }
    
  } else {
    throw new NoAuthorizedError();
  }
}

void _writeResponse(result, bool removeBrackets, HttpRequest request) {
  result = result == null ? "" : toJson(result);
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