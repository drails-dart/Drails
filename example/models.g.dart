// GENERATED CODE - DO NOT MODIFY BY HAND

part of drails_example.models;

// **************************************************************************
// Generator: DsonGenerator
// **************************************************************************

abstract class _$EmployeeSerializable extends SerializableMap {
  num get salary;
  int get id;
  String get name;
  String get password;
  List<String> get roles;
  void set salary(num v);
  void set id(int v);
  void set name(String v);
  void set password(String v);
  void set roles(List<String> v);

  operator [](Object __key) {
    switch (__key) {
      case 'salary':
        return salary;
      case 'id':
        return id;
      case 'name':
        return name;
      case 'password':
        return password;
      case 'roles':
        return roles;
    }
    throwFieldNotFoundException(__key, 'Employee');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'salary':
        salary = __value;
        return;
      case 'id':
        id = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'password':
        password = __value;
        return;
      case 'roles':
        roles = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Employee');
  }

  Iterable<String> get keys => EmployeeClassMirror.fields.keys;
}

abstract class _$UserSerializable extends SerializableMap {
  int get id;
  String get name;
  String get password;
  List<String> get roles;
  void set id(int v);
  void set name(String v);
  void set password(String v);
  void set roles(List<String> v);

  operator [](Object __key) {
    switch (__key) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'password':
        return password;
      case 'roles':
        return roles;
    }
    throwFieldNotFoundException(__key, 'User');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'id':
        id = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'password':
        password = __value;
        return;
      case 'roles':
        roles = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'User');
  }

  Iterable<String> get keys => UserClassMirror.fields.keys;
}

abstract class _$UserMixinSerializable extends SerializableMap {
  int get id;
  String get name;
  String get password;
  List<String> get roles;
  void set id(int v);
  void set name(String v);
  void set password(String v);
  void set roles(List<String> v);

  operator [](Object __key) {
    switch (__key) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'password':
        return password;
      case 'roles':
        return roles;
    }
    throwFieldNotFoundException(__key, 'UserMixin');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'id':
        id = __value;
        return;
      case 'name':
        name = __value;
        return;
      case 'password':
        password = __value;
        return;
      case 'roles':
        roles = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'UserMixin');
  }

  Iterable<String> get keys => UserMixinClassMirror.fields.keys;
}

abstract class _$PersonSerializable extends SerializableMap {
  int get id;
  String get firstName;
  String get lastName;
  DateTime get dob;
  void set id(int v);
  void set firstName(String v);
  void set lastName(String v);
  void set dob(DateTime v);

  operator [](Object __key) {
    switch (__key) {
      case 'id':
        return id;
      case 'firstName':
        return firstName;
      case 'lastName':
        return lastName;
      case 'dob':
        return dob;
    }
    throwFieldNotFoundException(__key, 'Person');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'id':
        id = __value;
        return;
      case 'firstName':
        firstName = __value;
        return;
      case 'lastName':
        lastName = __value;
        return;
      case 'dob':
        dob = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'Person');
  }

  Iterable<String> get keys => PersonClassMirror.fields.keys;
}

// **************************************************************************
// Generator: MirrorsGenerator
// **************************************************************************

_Employee__Constructor([positionalParams, namedParams]) => new Employee();

const $$Employee_fields_salary =
    const DeclarationMirror(name: 'salary', type: num);

const EmployeeClassMirror =
    const ClassMirror(name: 'Employee', constructors: const {
  '': const FunctionMirror(name: '', $call: _Employee__Constructor)
}, fields: const {
  'salary': $$Employee_fields_salary,
  'id': $$UserMixin_fields_id,
  'name': $$UserMixin_fields_name,
  'password': $$UserMixin_fields_password,
  'roles': $$UserMixin_fields_roles
}, getters: const [
  'salary',
  'id',
  'name',
  'password',
  'roles'
], setters: const [
  'salary',
  'id',
  'name',
  'password',
  'roles'
]);
_User__Constructor([positionalParams, namedParams]) => new User();

const UserClassMirror = const ClassMirror(name: 'User', constructors: const {
  '': const FunctionMirror(name: '', $call: _User__Constructor)
}, fields: const {
  'id': $$UserMixin_fields_id,
  'name': $$UserMixin_fields_name,
  'password': $$UserMixin_fields_password,
  'roles': $$UserMixin_fields_roles
}, getters: const [
  'id',
  'name',
  'password',
  'roles'
], setters: const [
  'id',
  'name',
  'password',
  'roles'
]);

const $$UserMixin_fields_id = const DeclarationMirror(name: 'id', type: int);
const $$UserMixin_fields_name =
    const DeclarationMirror(name: 'name', type: String);
const $$UserMixin_fields_password =
    const DeclarationMirror(name: 'password', type: String);
const $$UserMixin_fields_roles =
    const DeclarationMirror(name: 'roles', type: const [List, String]);

const UserMixinClassMirror = const ClassMirror(
    name: 'UserMixin',
    fields: const {
      'id': $$UserMixin_fields_id,
      'name': $$UserMixin_fields_name,
      'password': $$UserMixin_fields_password,
      'roles': $$UserMixin_fields_roles
    },
    getters: const ['id', 'name', 'password', 'roles'],
    setters: const ['id', 'name', 'password', 'roles'],
    isAbstract: true);
_Person__Constructor([positionalParams, namedParams]) => new Person();

const $$Person_fields_id = const DeclarationMirror(name: 'id', type: int);
const $$Person_fields_firstName =
    const DeclarationMirror(name: 'firstName', type: String);
const $$Person_fields_lastName =
    const DeclarationMirror(name: 'lastName', type: String);
const $$Person_fields_dob =
    const DeclarationMirror(name: 'dob', type: DateTime);

const PersonClassMirror =
    const ClassMirror(name: 'Person', constructors: const {
  '': const FunctionMirror(name: '', $call: _Person__Constructor)
}, fields: const {
  'id': $$Person_fields_id,
  'firstName': $$Person_fields_firstName,
  'lastName': $$Person_fields_lastName,
  'dob': $$Person_fields_dob
}, getters: const [
  'id',
  'firstName',
  'lastName',
  'dob'
], setters: const [
  'id',
  'firstName',
  'lastName',
  'dob'
]);
