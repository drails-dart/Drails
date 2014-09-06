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
      ..password = 'betop'
      ..roles = ['PUBLIC']
  };
  
  @Post
  void login(HttpSession session, @RequestBody User user) {
    var currentUser = users.values.singleWhere((u) => u.name == user.name && u.password == user.password);
    session['user'] = currentUser; 
  }
  
}

bool hasRolePublicOrAdmin(user, AuthorizeIf me) => user.roles.any((role) => ['PUBLIC', 'ADMIN'].any((v) => v == role));

@AuthorizeIf(hasRolePublicOrAdmin) //You can use next annotation as shorthand
//@AuthorizeRoles(const ['PUBLIC', 'ADMIN'])
class EmployeesController {

  String get(int id) => 'employee: $id';
  
  @AuthorizeRoles(const ['ADMIN'])
  String save(int id, @RequestBody Map employee) => 'saved employee: $id, $employee';
  
  @DenyRoles(const ['PUBLIC'])
  Map saveAll(@RequestBody Map employee) => employee;
}