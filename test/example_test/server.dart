library drails_example;

import 'package:drails/drails.dart';
import 'package:drails_di/drails_di.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'dart:async';
import 'package:dson/dson.dart';

part 'controllers/persons_controller.dart';
part 'controllers/authorization_sample_controller.dart';
part 'controllers/async_employee_controller.dart';
part 'models/user.dart';
part 'models/employee.dart';


initLogging() {
  Logger.root.level = Level.ALL;
  hierarchicalLoggingEnabled = true;
  new Logger('server_init').level = Level.INFO;
  
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

@component
@post
login(HttpSession session, @RequestBody User user) {
  var currentUser = users.values.singleWhere((u) => u.name == user.name && u.password == user.password);
  if(currentUser == null) throw Exception;
  session['user'] = currentUser;
}

void main() {
  initLogging();
  
  initServer(['drails_example']);
}

@component
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

@component
class HiController {
  String index() => "hi";
  
  String get2() => 'get';
}

@component
abstract class HelloService {
  String sayHello() => 'hello from Hello service abstract class';
}

@component
class HelloServiceImpl extends HelloService {
  String sayHello() => super.sayHello();
}

@component
class HelloServiceImpl2 extends HelloServiceImpl {
  
}

@component
abstract class SomeService {
  String someMethod();
}


@component
class SomeServiceImpl implements SomeService {
  String someMethod() => 'someMethod';
}