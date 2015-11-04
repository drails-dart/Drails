import 'package:dson/dson.dart';

@serializable
class Employee extends User {
  num salary;
}

@serializable
class User {
  int id;
  String name;
  String password;
  List<String> roles;
}

@serializable
class Person {
  int id;
  String firstName;
  String lastName;
  DateTime dob;
}