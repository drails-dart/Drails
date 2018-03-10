part of drails_example;

Map<int, User> users = {
  1: new User()
    ..id = 1
    ..name = 'lulo'
    ..password = 'lulo'
    ..roles = ['ADMIN'],
  2: new User()
    ..id = 2
    ..name = 'beto'
    ..password = 'beto'
    ..roles = ['PUBLIC']
};

bool hasRolePublicOrAdmin(user, AuthorizeIf me) =>
    user.roles.any((role) =>
        ['PUBLIC', 'ADMIN'].any((v) =>
            v == role));

@injectable
@AuthorizeIf(hasRolePublicOrAdmin) //You can use next annotation as shorthand
//@AuthorizeRoles(const ['PUBLIC', 'ADMIN'])
class EmployeesController extends _$EmployeesControllerSerializable {

  String get(int id) =>
      'employee: $id';

  @AuthorizeRoles(const ['ADMIN'])
  String save(int id, @RequestBody Map employee) =>
      'saved employee: $id, $employee';

  @DenyRoles(const ['PUBLIC'])
  Map saveAll(@RequestBody Map employee) => employee;
}
