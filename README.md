#Drails

[![Build Status](https://drone.io/github.com/luisvt/Drails/status.png)](https://drone.io/github.com/luisvt/Drails/latest)

DART MVC Framework inspired on Groovy on Grails and Ruby on Rails.

To get a sample application that uses Drails go to:

https://github.com/luisvt/drails_example

##Setup the Server
To setup a server you just need to call the method `initServer` and pass the list of libraries that are going to be taken in count when bootstrapping the application context, for example:

```dart
library drails_example;
//... other parts and imports omitted ...

main() {
  initServer([#drails_example]); //Initialize a server that listen on localhost:4040
}
```

If you want to define a different address or port for your server, you just need to pass the decided values. For example:

```dart
main() {
  initServer([#drails_example], address: new InternetAddress('<someaddress>'), port: 9090);
}
```
    
If you want to stop the server for any reason, for example after finishing all tests, you could do:

```dart
DRAILS_SERVER.close();
```

##Dependency Injection
The framework has a small dependency injection system that wires Classes with Postfix: Controller, Service, and Repository. For example, you can create a abstract class named 'SomeService':

```dart
abstract class SomeService {
  String someMethod();
}
```

and then we can create next implementation class:

```dart
class SomeServiceImpl implements SomeService {
  String someMethod() => 'someMethod';
}
```

in that way whenever a controller has a variable of Type SomeService and is annotated with @autowired the framework is going to inject SomeServiceImpl into the controller.

If you have a third level class that implements or extends SomeService this class is going to be used doubt to the level.

```
NOTE: Since Dart has support for Global Variables and Methods, I think that we don't need to add support for annotations @Component, @Value, or @Bean that are used on Spring MVC.
```

##Create Controllers
To create a controller you only need to append 'Controller' to the class name, for example:

```dart
class PersonsController {
  //Methods
}
```

###Methods and URIs
By convention a URI is created with the combination of the Controller name and the method name:

```dart
class HiController {
  // method mapped to: Hi/index
  String index() => "hi";
  
  // method mapped to: Hi/get2
  String get2() => 'get2';
}
```

Methods: get, getAll, save, saveAll, delete, and deleteAll are being ignored during the mapping. So that, they are only going to have the controller name

###Path Variables
By convention path variables are going to be the required arguments from the methods, for example:

```dart
class HelloController extends HiController {

  // mapped to: Hello/getVar/{id}/{var1}  
  String getVar(int id, String var1) => 'get: $id, $var1';
  
}
```

If the argument type is HttpRequest, HttpHeaders or HttpSession, this is not going to be mapped as path variable. In contrast, those arguments are going to be passed to the method from the current request.

###Query parameters
By convention, query parameters are going to be mapped from the optional arguments, for example:

```dart
class PersonsController extends HiController {
  
  // mapped to: persons?pageSize=25&pageNumber=2 or just persons
  String getAll({int pageSize: 20, int pageNumber: 1}) {
    return 'getAll: $pageSize, $pageNumber';
  }
}
```
in the previous sample pageSize and pageNumber are optional, so users could or could not write those values during a new request
    
###Autowiring Variables
To autowire a variable by Class Type and Weight you only need to annotate that variable with @autowired (similar to Spring).

```dart
class HelloController extends HiController {
  String someString;
  
  @autowired
  HelloService helloService;
  
  String index() => helloService.sayHello() + ' and from HelloController ' + super.index();
}
```

###Create Rest Controllers

If you want to create a REST-API with controllers you could do the next:
 
```dart
class PersonsController {

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
class AsyncEmployeesController {

  Future<Employee> get(int id) => new Future<Employee>.delayed(new Duration(seconds: 5), () => 
      employees[id]);
}
```

## Authorization

If you want to add authorization logic to a Controller or a Method of a Controller you only need to annotate it with `@AuthroizeIf` or any of its implementations. For example:

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

Since annotations `@AuthorizeRoles` and `@DenyRoles` implements `@AuthorizeIf` they are taking in count when authorization checker is run.

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

##TODOs

* Create Dependency Injection Tests
* Create Generic Rest Controller which should be extended for other controllers
* Add Object Relational Mapping (ORM) or Domain Object Model (DOM) support
* Create Repositories or Store objects to connect to database
* Add Exceptions Handlers
* Add Angular Dart or Polymer Dart client side
* Handle Cyclic Reference parsing
* Handle hashcode, _ref or @id variable to deserialize objects that don't have ids (for inserting purposes).
 
