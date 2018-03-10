library drails_example;

import 'dart:async';
import 'dart:io';

import 'package:drails/drails.dart';
import 'package:drails_di/drails_di.dart';
import 'package:logging/logging.dart';

import 'models.dart';

part 'controllers/async_employee_controller.dart';

part 'controllers/authorization_sample_controller.dart';

part 'controllers/persons_controller.dart';

part 'server.g.dart';


initLogging() {
  Logger.root.level = Level.INFO;
  hierarchicalLoggingEnabled = true;
  new Logger('server_init').level = Level.ALL;

  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

@injectable
@Path('')
@POST
login(HttpSession httpSession, {String username, String password}) {
  var currentUser;
  try {
    currentUser = users.values
        .singleWhere((u) =>
    u.name == username
        && u.password == password);
  } catch (e) {
    throw new NoAuthorizedError();
  }
  httpSession['user'] = currentUser;
}

void main() {
  _initMirrors();
  initLogging();

  initServer();
}

@injectable
class HelloController extends _$HelloControllerSerializable with _$HiController {
  String someString;

  @autowired
  HelloService helloService;

  String index() =>
      '${helloService.sayHello()} ${super.index()} from HelloController!';

  String get(int id) => 'get: $id';

  String getAll({String pageSize: '20', String pageNumber: '1'}) {
    return 'getAll: $pageSize, $pageNumber';
  }

  String getVar(int id, String var1) => 'get: $id, $var1';

}

class _$HiController {
  String index() => "Hi";

  String get2() => 'get2';
}

@injectable
class HiController extends _$HiControllerSerializable with _$HiController {}

@injectable
abstract class HelloService extends _$HelloServiceSerializable {
  String sayHello() => 'Hello from Hello service abstract class!';
}

@injectable
class HelloServiceImpl extends HelloService {
  String sayHello() => super.sayHello();
}

@injectable
class HelloServiceImpl2 extends HelloServiceImpl {
}

@injectable
abstract class SomeService extends _$SomeServiceSerializable {
  String someMethod();
}


@injectable
class SomeServiceImpl extends _$SomeServiceImplSerializable implements SomeService {
  String someMethod() => 'someMethod';
}
