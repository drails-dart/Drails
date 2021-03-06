part of drails_example;

@injectable
class PersonsController extends _$PersonsControllerSerializable {
  static int lastId = 3;
  Map<int, Person> persons = {
    1: new Person()
      ..id = 1
      ..firstName = 'Luis'
      ..lastName = 'Vargas'
      ..dob = new DateTime(2000, 1, 1),
    2: new Person()
      ..id = 2
      ..firstName = 'Alberto'
      ..lastName = 'Tijerino'
      ..dob = new DateTime(2000, 1, 1),
    3: new Person()
      ..id = 3
      ..firstName = 'Ricardo'
      ..lastName = 'Vargas'
      ..dob = new DateTime(2000, 1, 1)
  };

  Person get(int id) => persons[id];

  List<Person> getAll() => persons.values.toList();

  Person save(int id, @RequestBody Person person) => persons[id] = person;

  Iterable<Person> saveAll(@RequestBody List<Person> persons) =>
    persons..forEach((person) {
      if(person.id == null) {
        person.id = ++lastId;
      }
      this.persons[person.id] = person;
    });

  void delete(int id) { persons.remove(id); }

  void deleteAll(@RequestBody List<int> ids) { ids.forEach((id) => persons.remove(id)); }
}

