import '../example/drails_example.dart' as drails_example;
import 'package:unittest/unittest.dart';
import 'package:http/http.dart';
import 'dart:io';

main() {
  drails_example.main();
  
  group('controller tests', () {
    test('root request', () {
      get('http://127.0.0.1:4040').then(expectAsync((response) {
        expect(response.body, equals("Hello"));
      }));
    });
    
    test('get persons', () {
      get('http://127.0.0.1:4040/persons').then(expectAsync((response) {
        expect(response.body, equals(
          '[{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"},'
          '{"id":2,"firstName":"Alberto","lastName":"Tijerino","dob":"1988-04-01T00:00:00.000"},'
          '{"id":3,"firstName":"Ricardo","lastName":"Vargas","dob":"1989-08-28T00:00:00.000"}]'));
      }));
    });
    
    test('get persons/1', () {
      get('http://127.0.0.1:4040/persons/1').then(expectAsync((response) {
          expect(response.body, equals('{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}'));
      }));
    });
    
    test('put persons/1', () {
      put('http://127.0.0.1:4040/persons/1', body: '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}')
      .then(expectAsync((response) {
        expect(response.body, '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}');
      }));
    });
    
    test('post one persons', () {
      post('http://127.0.0.1:4040/persons', body: '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}')
      .then(expectAsync((response) {
        expect(response.body, '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}');
      }));
    });
    
    test('post list of persons', () {
      post('http://127.0.0.1:4040/persons', body: 
        '[{"id":1,"firstName":"Luisss","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"},'
        '{"id":2,"firstName":"Albertoss","lastName":"Tijerino","dob":"1988-04-01T00:00:00.000"},'
        '{"id":3,"firstName":"Ricardoss","lastName":"Vargas","dob":"1989-08-28T00:00:00.000"}]')
      .then(expectAsync((response) {
        expect(response.body, equals(
          '[{"id":1,"firstName":"Luisss","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"},'
          '{"id":2,"firstName":"Albertoss","lastName":"Tijerino","dob":"1988-04-01T00:00:00.000"},'
          '{"id":3,"firstName":"Ricardoss","lastName":"Vargas","dob":"1989-08-28T00:00:00.000"}]'));
      }));
    });
    
    test('delete one person', () {
      delete('http://127.0.0.1:4040/persons/1').then(expectAsync((Response response) {
        expect(response.statusCode, 200);
      }));
    });
    
    test('delete list of persons', () {
      new Client().send(new Request('DELETE', new Uri.http('127.0.0.1:4040', '/persons'))..body = '[1,2]').then(expectAsync((response) {
        expect(response.statusCode, 200);
      }));
    });
    
    //stops the server after next test
    tearDown(() => drails_example.stopServer());
    
    test('end', () {});
  });
}