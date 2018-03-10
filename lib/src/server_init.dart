part of drails;

final _serverInitLog = new Logger('server_init');

/// Initialize the server with the given arguments
void initServer({address, int port: 4040}) {
  address = address != null ? address : '0.0.0.0';

  ApplicationContext.bootstrap();

  var controllers = ApplicationContext.controllers;

  //Get port from enviroment if server is on heroku
  var envPort = Platform.environment['PORT'];

  if (envPort != null) port = int.parse(envPort);

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
    if (dir.path == (clientFiles + './')) {
      var filePath = clientFiles + CLIENT_URL;
      _serverInitLog.info("Serving: $filePath");

      Uri fileUri = Platform.script.resolve(filePath);
      File file = new File(fileUri.toFilePath());
      virDir.serveFile(file, request);
    } else {
      virDir
        ..directoryHandler = null
        ..serveRequest(request).then((r) {
          virDir.directoryHandler = dirHandler;
        });
    }
  };

  virDir.directoryHandler = dirHandler;
}

void _initProxyServer(Router router) {

  ApplicationContext.proxyFunctions.forEach((fnMirror, fn) {
    Path _path = fnMirror.annotations?.firstWhere((a) => a is Path, orElse: () => null);
    String method = _path == null || _path is Get ? "GET" : "POST";

    String url = _path?.url?.isEmpty ?? true ? fnMirror.name : _path.url;

    _logInitRoute(method, url, fnMirror);

    router.serve(new UrlPattern('/$url(/(\\w+))?/?'), method: method).listen((request) {
      _process(request, fn, null, fnMirror);
    });
  });
}

void _logInitRoute(String method, String url, FunctionMirror fnMirror) =>
    _serverInitLog.info(() => 'initializing route:[method: $method, url: $url'
        '/${fnMirror.positionalParameters?.map((p) => '{${p.name}}')?.join('/') ?? ''}/?,'
        ' queryParams: ${fnMirror.namedParameters?.keys ?? 'NONE'}]');

void _mapControllers(SerializableMap controller, Router router) {
  var controllerCm = reflect(controller),
      controllerName = controllerCm.name.replaceFirst('Controller', '').toLowerCase(),
      controllerMms = controllerCm.methods,
      controllerPath = controllerCm.annotations?.firstWhere((a) => a is Path, orElse: () => null)?.url ?? '/$controllerName';

  router.serve(new UrlPattern("/$controllerName(/(\\w+))?/?"), method: 'OPTIONS').listen((request) {
    _writeResponse("", false, request);
  });

  controllerMms.forEach((controllerMethodName, controllerMm) {
    var urlPath = controllerPath,
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
        if (controllerMm.annotations?.any((a) => a is Post) == true) {
          method = 'POST';
        }
        controllerMm.parameters.forEach((paramDm) {
          if (paramDm.annotations?.any((a) => a is _RequestBody) != true
              && paramDm.type != HttpRequest
              && paramDm.type != HttpSession
              && paramDm.isRequired)
            urlPath += wordPath;
        });
    }

    _logInitRoute(method, urlPath, controllerMm);

    router.serve(new UrlPattern(urlPath), method: method).listen((request) {
      _process(request, controller, controllerCm, controllerMm, pathParamBegin);
    });
  });
}

void _process(HttpRequest request, /*SerializableMap | Function*/ controllerOrProxy, ClassMirror mirror, FunctionMirror methodMirror, [int pathParamBegin = 1]) {
  var pathSegments = request.uri.pathSegments,
      positionalArgs = [],
      namedArgs = <String, dynamic>{},
      _ref,
      i = 0,
      removeBrackets = false;

  Iterable<String> pathVariables = pathSegments.length <= pathParamBegin ? [] : pathSegments.getRange(
      pathParamBegin, pathSegments.length);

  UTF8.decodeStream(request).then((data) {
    try {
      methodMirror.parameters.forEach((parameter) {
        if (parameter.type == HttpRequest) {
          positionalArgs.add(request);
        } else if (parameter.type == HttpHeaders) {
          positionalArgs.add(request.headers);
        } else if (parameter.type == HttpSession) {
          positionalArgs.add(request.session);
        } else if ((!parameter.isRequired || parameter.annotations?.any((a) => a is RequestParam) == true)
            && (_ref = request.uri.queryParameters[parameter.name]) != null) {
          namedArgs[parameter.name] = _ref;
        } else if (parameter.annotations?.any((a) => a is _RequestBody) == true && data.isNotEmpty) {
          if (parameter.type is List && parameter.type.first == List) {
            if (!(data as String).startsWith('[')) {
              data = '[$data]';
              removeBrackets = true;
            }
            positionalArgs.add(fromJson(data, parameter.type));
          } else {
            positionalArgs.add(fromJson(data, parameter.type));
          }
        } else if (pathVariables.length >= i + 1) {
          if (parameter.type == int) {
            positionalArgs.add(int.parse(pathVariables.elementAt(i++)));
          } else if (parameter.type == String) {
            positionalArgs.add(pathVariables.elementAt(i++));
          } else if (parameter.type == DateTime) {
            positionalArgs.add(DateTime.parse(pathVariables.elementAt(i++)));
          } else {
            _serverInitLog.fine('parameter.type.reflectedType: ${parameter.type.reflectedType}');
            positionalArgs.add(fromJson(pathVariables.elementAt(i++), parameter.type.reflectedType));
          }
        }
      });

      _serverInitLog.fine(
          'invoking controller:'
              '\n\tpathSegments: $pathSegments'
              '\n\tpathVariables: $pathVariables'
              '\n\tcontrollerCm: $mirror'
              '\n\tcontrollerMm: $methodMirror'
              '\n\tpositionalArgs: $positionalArgs'
              '\n\tnamedArgs: $namedArgs');

      _invokeControllerMethod(controllerOrProxy, mirror, methodMirror, positionalArgs, namedArgs, request, removeBrackets);
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

void _invokeControllerMethod(/*SerializableMap | Function*/ controllerOrProxy, Mirror mirror,
    FunctionMirror methodMirror,
    List positionalArgs,
    Map<String, dynamic> namedArgs,
    HttpRequest request,
    bool removeBrackets) {
  var user = request.session['user'],
      authorizedForController = true,
      authorizedForMethod = true;
  AuthorizeIf _ref1, _ref2;
  if (mirror is ClassMirror) {
    _ref1 = mirror.annotations
        ?.firstWhere((a) => a is AuthorizeIf, orElse: () => null);
    authorizedForController = (_ref1 != null && user != null) ?
    _ref1.isAuthorized(user, _ref1)
        : false;
  }
  _ref2 = methodMirror.annotations
      ?.firstWhere((a) => a is AuthorizeIf, orElse: () => null);
  authorizedForMethod = (_ref2 != null && user != null) ?
  _ref2.isAuthorized(user, _ref2)
      : false;

  if (_ref1 == null && _ref2 == null || authorizedForController || authorizedForMethod) {
    var namedArgs2 = {};
    namedArgs.forEach((key, value) => namedArgs2[new Symbol(key)] = value);
    var result = Function.apply(
        mirror == null ? controllerOrProxy : controllerOrProxy[methodMirror.name],
        positionalArgs,
        namedArgs2);

    if (result is Future) {
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
  if (removeBrackets) {
    result = result.substring(1, result.length - 1);
  }
  if (ENABLE_CORS[ENV]) {
    request.response.headers..add("Access-Control-Allow-Origin", "*, ")..add(
        "Access-Control-Allow-Methods", "PUT, DELETE, POST, GET, OPTIONS")..add(
        "Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  }
  request.response
    ..headers.contentType = new ContentType("application", "json", charset: "utf-8")
    ..write(result)
    ..close();
}
