library drails_demo.controller_server.dart;

import 'package:drails/drails.dart';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

part 'controller_server.g.dart';

main() {
  _initMirrors();

  Logger.root
    ..level = Level.ALL
    ..onRecord.listen(new LogPrintHandler());

  initServer();
}

@injectable
class HelloController extends _$HelloControllerSerializable {
  String get(String name) => 'Hello $name!';
}
