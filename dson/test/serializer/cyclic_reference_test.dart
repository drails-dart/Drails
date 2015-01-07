part of test_dson;

void cyclic_reference_serialize() {
  group('ciclical test with id >', () {
  
    var manager = new Employee()
      ..id = 1
      ..firstName = 'Jhon'
      ..lastName = 'Doe';
    manager.address = new Address()
        ..id = 1
        ..street = 'some street'
        ..city = 'Miami'
        ..country = 'USA'
        ..owner = manager;
  
    var employee = new Employee()
      ..id = 2
      ..firstName = 'Luis'
      ..lastName = 'Vargas'
      ..manager = manager;
    employee.address = new Address()
        ..id = 2
        ..street = 'some street'
        ..city = 'Miami'
        ..country = 'USA'
        ..owner = employee;
       
    test('serialize Employee without address and manager', () {
      expect(serialize(employee), '{"id":2,"firstName":"Luis","lastName":"Vargas","address":{"id":2},"manager":{"id":1}}');
    });
    test('serialize employee.address without owner', () {
      expect(serialize(employee.address), '{"id":2,"street":"some street","city":"Miami","country":"USA","owner":{"id":2}}');
    });
    
    test('serialize employee with address and no manager', () {
      expect(serialize(employee, depth: ['address']),
             '{"id":2,"firstName":"Luis","lastName":"Vargas",'
                '"address":{"id":2,"street":"some street","city":"Miami","country":"USA","owner":{"id":2}},'
                '"manager":{"id":1}}');
    });
    
    test('serialize employee with address, manager and manager address', () {
      expect(serialize(employee, depth: [{'manager': ['address']}, 'address']),
             '{"id":2,"firstName":"Luis","lastName":"Vargas",'
                '"address":{"id":2,"street":"some street","city":"Miami","country":"USA",'
                  '"owner":{"id":2}},'
                '"manager":{"id":1,"firstName":"Jhon","lastName":"Doe",'
                  '"address":{"id":1,"street":"some street","city":"Miami","country":"USA","owner":{"id":1}}}}');
    });
  });
  
  group('Ciclical Test without id >', () {
  
    var manager = new Employee2()
      ..firstName = 'Jhon'
      ..lastName = 'Doe';
    manager.address = new Address2()
        ..street = 'some street'
        ..city = 'Miami'
        ..country = 'USA'
        ..owner = manager;
  
    var employee = new Employee2()
      ..firstName = 'Luis'
      ..lastName = 'Vargas'
      ..manager = manager;
    employee.address = new Address2()
        ..street = 'some street'
        ..city = 'Miami'
        ..country = 'USA'
        ..owner = employee;
       
    test('serialize Employee without address and manager', () {
      expect(serialize(employee), matches(
          r'\{'
              r'"firstName":"Luis",'
              r'"lastName":"Vargas",'
              r'"address":\{"hashcode":\d+\},'
              r'"manager":\{"hashcode":\d+\},'
              r'"hashcode":\d+'
          '\}'));
    });
    test('serialize employee.address without owner', () {
      expect(serialize(employee.address), matches(
          r'\{'
              r'"street":"some street",'
              r'"city":"Miami",'
              r'"country":"USA",'
              r'"owner":\{"hashcode":\d+\},'
              r'"hashcode":\d+'));
    });
    
    test('serialize employee with address and no manager', () {
      expect(serialize(employee, depth: ['address']),
             matches(
                 r'\{"firstName":"Luis","lastName":"Vargas",'
                    r'"address":\{"street":"some street","city":"Miami","country":"USA","owner":\{"hashcode":\d+\},"hashcode":\d+\},'
                    r'"manager":\{"hashcode":\d+\},'
                 r'"hashcode":\d+\}'));
    });
    
    test('serialize employee with address, manager and manager address', () {
      expect(serialize(employee, depth: [{'manager': ['address']}, 'address']),
             matches(
                 r'\{'
                    r'"firstName":"Luis",'
                    r'"lastName":"Vargas",'
                    r'"address":\{'
                        r'"street":"some street",'
                        r'"city":"Miami",'
                        r'"country":"USA",'
                        r'"owner":\{"hashcode":\d+\},'
                        r'"hashcode":\d+'
                    r'\},'
                    r'"manager":\{'
                        r'"firstName":"Jhon",'
                        r'"lastName":"Doe",'
                        r'"address":\{'
                            r'"street":"some street",'
                            r'"city":"Miami",'
                            r'"country":"USA",'
                            r'"owner":\{"hashcode":\d+\},'
                            r'"hashcode":\d+'
                        r'\},'
                        r'"hashcode":\d+'
                    r'\},'
                    r'"hashcode":\d+'
                r'\}'));
    });
  });
        
}

@cyclical
class Employee {
  int id;
  String firstName;
  String lastName;
  
  Address address;
  
  Employee manager;
}

@cyclical
class Address {
  int id;
  String street;
  String city;
  String country;
  String postalCode;
  
  Employee owner;
}

@cyclical
class Employee2 {
  String firstName;
  String lastName;
  
  Address2 address;
  
  Employee2 manager;
}

@cyclical
class Address2 {
  String street;
  String city;
  String country;
  String postalCode;
  
  Employee2 owner;
}