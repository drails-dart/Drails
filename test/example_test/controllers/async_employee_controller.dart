part of drails_example;

Map<int, Employee> employees = {
  1: new Employee()
    ..name = 'emp1'
    ..roles = ['SALES']
    ..salary = 2000
};

@injectable
class AsyncEmployeesController {
  
  Future<Employee> get(int id) => new Future<Employee>.delayed(new Duration(seconds: 5), () => 
      employees[id]);
}
