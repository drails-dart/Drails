part of drails_example;

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
      ..password = 'betopass'
      ..roles = ['PUBLIC']
  };
  
  @Post
  void login(HttpSession session, @RequestBody User user) {
    var currentUser = users.values.singleWhere((u) => u.name == user.name && u.password == user.password);
    session['user'] = currentUser; 
  }
  
}

@AuthorizeRoles(const ['PUBLIC', 'ADMIN'])
class EmployeesController {

  String get(int id) => 'employee: $id';
  
  @AuthorizeRoles(const ['ADMIN'])
  String save(int id, @RequestBody String employee) => 'saved employee: $id';
}