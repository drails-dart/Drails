library drails_example;

import 'package:drails/drails.dart';
import 'package:logging/logging.dart';

part 'controllers/persons_controller.dart';

initLogging() {
  Logger.root.level = Level.FINE;
//  hierarchicalLoggingEnabled = true;
//  new Logger('server_init').level = Level.INFO;
  
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

void main() {
  initLogging();
  initServer();
}

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

class HiController {
  String index() => "hi";
  
  String get2() => 'get';
}

abstract class HelloService {
  String sayHello() => 'hello from Hello service abstract class';
}

class HelloServiceImpl extends HelloService {
  String sayHello() => super.sayHello();
}

class HelloServiceImpl2 extends HelloServiceImpl {
  
}

abstract class SomeService {
  String someMethod();
}


class SomeServiceImpl implements SomeService {
  String someMethod() => 'someMethod';
}