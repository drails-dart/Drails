library drails_example;

import 'package:drails/drails.dart';
import 'package:drails_di/drails_di.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'dart:async';
import 'models.dart';

part 'controllers/persons_controller.dart';
part 'controllers/authorization_sample_controller.dart';
part 'controllers/async_employee_controller.dart';


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
class LoginController {
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
}

void main() {
  initLogging();
  
  initServer(['drails_example']);
}

@injectable
class HelloController extends HiController {
  String someString;
  
  @autowired
  HelloService helloService;
  
  String index() => helloService.sayHello() + ' and from HelloController ' + super.index();
  
  String get(int id) => 'get: $id';
  
  String getAll({String pageSize: '20', String pageNumber: '1'}) {
    return 'getAll: $pageSize, $pageNumber';
  }
  
  String getVar(int id, String var1) => 'get: $id, $var1';
  
}

@injectable
class HiController {
  String index() => "hi";
  
  String get2() => 'get';
}

@injectable
abstract class HelloService {
  String sayHello() => 'hello from Hello service abstract class';
}

@injectable
class HelloServiceImpl extends HelloService {
  String sayHello() => super.sayHello();
}

@injectable
class HelloServiceImpl2 extends HelloServiceImpl {
  
}

@injectable
abstract class SomeService {
  String someMethod();
}


@injectable
class SomeServiceImpl implements SomeService {
  String someMethod() => 'someMethod';
}