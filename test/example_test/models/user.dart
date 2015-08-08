part of drails_example;

@serializable
class User {
  int id;
  String name;
  String password;
  List<String> roles;
}