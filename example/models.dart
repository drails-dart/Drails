library drails_example.models;

import 'package:dson/dson.dart';

part 'models.g.dart';

@serializable
class Employee extends _$EmployeeSerializable with UserMixin {
  num salary;
}

@serializable
class User extends _$UserSerializable with UserMixin {}

@serializable
abstract class UserMixin {
  int id;
  String name;
  String password;
  List<String> roles;
}

@serializable
class Person extends _$PersonSerializable {
  int id;
  String firstName;
  String lastName;
  DateTime dob;
}
