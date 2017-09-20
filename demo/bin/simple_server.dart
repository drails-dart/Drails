library drails_demo.simple_server;

import 'package:drails/drails.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/server_logging_handlers.dart';

part 'simple_server.g.dart';

main() {
  _initMirrors();

  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(new LogPrintHandler());

  initServer();
}

@GET // This annotation is optional, and can be replaced by `@Get()` or `Get(url = 'say-hello')`
@component // This annotation can be replaced by @injectable
String hello(String name) => 'Hello $name!';