# Drails

![Build Status](https://travis-ci.org/drails-dart/Drails.svg?branch=master)

DART MVC Framework inspired on Groovy on Grails and Ruby on Rails.

To get a sample application that uses Drails go to:

https://github.com/luisvt/drails_sample_app

## Getting Started

1\. Create a new console application with next structure:

```
- sample_drails_server
  ...
  * pubspec.yaml
  - bin
    * main.dart
  ...
```

2\. Inside `pubspec.yaml` add dependencies to drails, the code should look like this:

```yaml
name: drails_sample_server
version: 0.0.1
description: A minimal drails server application.
environment:
  sdk: '>=1.0.0 <2.0.0'
dependencies:
  drails: ^0.2.0
dev_dependencies:
  build_runner: ^0.7.0
  ...
```

3\. Inside `main.dart` add next code:

```dart
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
```

or you can also use a simple controller instead:

```dart
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

```

4\. Run next command in terminal to generate required files:

```sh
pub run build_runner build
```

or if you prefer to watch changes, you can run:


```sh
pub run build_runner watch
```


5\. Start the server by running `main.dart` and navigate to `localhost:4040/hello/world` in your browser

## Setup the Server

To setup a server you just need to call the method `initServer`, for example:

```dart
  initServer(); //Initialize a server that listen on localhost:4040
```

If you want to define a different address or port for your server, you just need to pass the decided values. For example:

```dart
  initServer(address: new InternetAddress('<someaddress>'), port: 9090);
```
    
If you want to stop the server for any reason, for example after finishing all tests, you could do:

```dart
DRAILS_SERVER.close();
```

## Dependency Injection

The framework has a small dependency injection system that wires Classes with Postfix: Controller, Service, and Repository. For example, you can create a abstract class named 'SomeService':

```dart
@injectable
abstract class SomeService {
  String someMethod();
}
```

and then we can create next implementation class:

```dart
@injectable
class SomeServiceImpl implements SomeService {
  String someMethod() => 'someMethod';
}
```

in that way whenever a controller has a variable of Type SomeService and is annotated with `@autowired` the framework is going to inject SomeServiceImpl into the controller.

If you have a third level class that implements or extends SomeService this class is going to be used doubt to the level.

> Since Dart has support for Global Variables and Methods, I think that we don't need to add support for annotations `@Value`, or `@Bean` that are used on Spring MVC.

## Create Controllers

To create a controller you only need to append `Controller` to the class name, for example:

```dart
@injectable
class PersonsController {
  //Methods
}
```

### Methods and URIs

By convention a URI is created with the combination of the Controller name and the method name:

```dart
@injectable
class PersonsController extends _$PersonsControllerSerializable {
  // method mapped to: persons/form/{id}
  String form(int id) => render("persons/form", model: {'person': get(id)});
  
  // method mapped to: persons/list
  String list() => render('persons/list', model: {'persons': getAll()});

  // method mapped to: persons/{id}
  Person get(int id) => personsDao.find(id);

  // method mapped to: persons/
  List<Person> getAll() => render('list', model: {'persons': personsDao.findAll()});
}
```

Methods: `get`, `getAll`, `save`, `saveAll`, `delete`, and `deleteAll` are being ignored during the mapping. So that, they are only going to have the controller name

### Path Variables

By convention path variables are going to be the required arguments from the methods, for example:

```dart
@injectable
class HelloController extends _$HelloControllerSerializable {

  // mapped to: Hello/getVar/{id}/{var1}  
  String getVar(int id, String var1) => 'get: $id, $var1';
  
}
```

If the argument type is HttpRequest, HttpHeaders or HttpSession, this is not going to be mapped as path variable. In contrast, those arguments are going to be passed to the method from the current request.

### Query parameters

By convention, query parameters are going to be mapped from the optional arguments, for example:

```dart
class PersonsController extends _$PersonsControllerSerializable {
  
  // mapped to: persons?pageSize=25&pageNumber=2 or just persons
  String getAll({int pageSize: 20, int pageNumber: 1}) {
    return 'getAll: $pageSize, $pageNumber';
  }
}
```
in the previous sample pageSize and pageNumber are optional, so users could or could not write those values during a new request
    
### Injecting Dependencies

To inject a dependency by Type you only need to annotate that variable with @inject or @autowire (similar to Spring).

```dart
@injectable
class HelloController extends _$HelloControllerSerializable {
  String someString;
  
  @inject
  HelloService helloService;
  
  String index() => helloService.sayHello() + ' and from HelloController ' + super.index();
}
```

### Create Rest Controllers

If you want to create a REST-API with controllers you could do the next:
 
```dart
@injectable
class PersonsController extends _$PersonControllerSerializable {

  // GET persons/1
  Person get(int id) => persons[id];

  // GET persons
  List<Person> getAll() => persons.values.toList();

  // PUT persons/1 {jsonObject}
  Person save(int id, @RequestBody Person person) => persons[id] = person;

  // POST persons 
  //   RequestBody: {jsonObject} or POST persons [jsonList]
  // if you do a POST with id null the server will do an INSERT but if the id is present it will do an UPDATE.
  Iterable<Person> saveAll(@RequestBody List<Person> persons) => 
    persons..forEach((person) {
    if(person.id == null) {
      person.id = this.persons.keys.last + 1;
    }
    this.persons[person.id] = person;
  });

  // DELETE persons/1
  void delete(int id) { persons.remove(id); }
  
  // DELETE persons 
  //   RequestBody: int or [intList]
  void deleteAll(List<int> ids) { ids.forEach((id) => persons.remove(id)); }
}
```

Although REST tells that POST and DELETE should only handle one resource, I decide to also handle multiple resources. This is because there are some cases where users need to do that, so in this way reducing the number of queries made to the server.

## Asynchronous Methods (Futures)

If you want to create methods that have an asynchronous behavior like: getting data from a database, calling an external service, etc. you only need to return a `Future` object. For example:

```dart
@injectable
class AsyncEmployeesController extends _$AsyncEmployeesControllerSerializable {

  Future<Employee> get(int id) => new Future<Employee>.delayed(new Duration(seconds: 5), () => 
      employees[id]);
}
```

## Authorization

If you want to add authorization logic to a Controller or its Methods you only need to annotate it with `@AuthroizeIf` or any of its implementations. For example:

```dart
//user is a dynamic so that roles is not typesafe
bool hasRolePublicOrAdmin(user, AuthorizeIf me) => user.roles.any((role) => ['PUBLIC', 'ADMIN'].any((v) => v == role));

@AuthorizeIf(hasRolePublicOrAdmin) //You can use next annotation as shorthand
//@AuthorizeRoles(const ['PUBLIC', 'ADMIN'])
class EmployeesController {

  String get(int id) => 'employee: $id';
  
  @AuthorizeRoles(const ['ADMIN']) // This annotation implements @AuthorizeIf
  String save(int id, @RequestBody Map employee) => 'saved employee: $id, $employee';
  
  @DenyRoles(const ['PUBLIC']) // This annotation extends @AuthorizeRoles (implements @AuthorizeIf)
  Map saveAll(@RequestBody Map employee) => employee;
}
```

Since annotations `@AuthorizeRoles` and `@DenyRoles` implements `@AuthorizeIf` they are taken into account when authorization checker is run.

The only thing that you need to do before is to be sure that you save into `request.session['user']` an object that has a `roles` getter. For example:

```dart
class LoginController {
  static Map<int, User> users = {
    1: new User()
      ..id = 1
      ..name = 'lulo'
      ..password = 'lulo'
      ..roles = ['ADMIN'],
    2: new User()
      ..id = 2
      ..name = 'beto'
      ..password = 'betop'
      ..roles = ['PUBLIC']
  };
  
  @Post
  void login(HttpSession session, @RequestBody User user) {
    var currentUser = users.values.singleWhere((u) => u.name == user.name && u.password == user.password);
    session['user'] = currentUser; 
  }
}
```

Since every Authorization logic is different for every case you should export `@AuthorizeRoles` and `@DenyRoles` and override those annotations and their respective `isAuthorize` function. For example, putting next code in main file:

```dart
    import 'package:drails/drails.dart' hide AuthorizeRoles, DenyRoles, authorizeRoles, denyRoles;
```
and creating your own implementation. Furthermore, you can also create a better `User` class that contains `Role` class, and instead passing a dynamic user object you could pass a typed user object. For example:

```dart
    bool authorizeRoles(User user, AuthorizeRoles me) => 
      user.roles.any((role) => 
          me.roles.any((meRole) => 
              meRole == role));
```

## TODOs

* Use `shelf` instead `dart:io`
* Create Generic Rest Controller which should be extended for other controllers
* Add Object Relational Mapping (ORM) or Domain Object Model (DOM) support
* Create Repositories, DAO, DTO, or Store objects to connect to database
* Add Exceptions Handlers
* Add Interceptors
 
