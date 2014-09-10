import '../example/drails_example.dart' as drails_example;
import 'package:unittest/unittest.dart';
import 'package:http/http.dart';
import 'package:drails/drails.dart';

main() {
  drails_example.main();
  var localhostUrl = 'http://127.0.0.1:4040';
  group('controller', () {
    
    test('root request', () {
      get(localhostUrl).then(expectAsync((response) {
        expect(response.body, equals("Hello"));
      }));
    });

    group('-> hello', () {

      var helloUrl = localhostUrl + '/hello';
      
      test('-> index', () {
        get('$helloUrl/index').then(expectAsync((response) {
          expect(response.body, equals('"hello from Hello service abstract class and from HelloController hi"'));
        }));
      });
      
      test('-> getAll', () {
        get('$helloUrl').then(expectAsync((response) {
          expect(response.body, equals('"getAll: 20, 1"'));
        }));
      });
      
      test('-> get', () {
        get('$helloUrl/1').then(expectAsync((response) {
          expect(response.body, equals('"get: 1"'));
        }));
      });
      
      test('-> getVar', () {
        get('$helloUrl/getVar/1/2').then(expectAsync((response) {
          expect(response.body, equals('"get: 1, 2"'));
        }));
      });
    });
    
    group('-> persons', () {
      var personsUrl = '$localhostUrl/persons';
      
      test('-> get persons', () {
        get('$personsUrl').then(expectAsync((response) {
          expect(response.body, equals(
            '[{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"},'
            '{"id":2,"firstName":"Alberto","lastName":"Tijerino","dob":"1988-04-01T00:00:00.000"},'
            '{"id":3,"firstName":"Ricardo","lastName":"Vargas","dob":"1989-08-28T00:00:00.000"}]'));
        }));
      });
      
      test('-> get persons/1', () {
        get('$personsUrl/1').then(expectAsync((response) {
            expect(response.body, equals('{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}'));
        }));
      });
      
      test('-> put persons/1', () {
        put('$personsUrl/1', body: '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}')
        .then(expectAsync((response) {
          expect(response.body, '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}');
        }));
      });
      
      test('-> post one persons', () {
        post(personsUrl, body: '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}')
        .then(expectAsync((response) {
          expect(response.body, '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}');
        }));
      });
      
      test('-> post list of persons', () {
        post(personsUrl, body: 
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
      
      test('-> delete one person', () {
        delete('$personsUrl/1').then(expectAsync((Response response) {
          expect(response.statusCode, 200);
        }));
      });
      
      test('-> delete list of persons', () {
        new Client().send(new Request('DELETE', new Uri.http('127.0.0.1:4040', '/persons'))..body = '[1,2]').then(expectAsync((response) {
          expect(response.statusCode, 200);
        }));
      });
    });
    
    //stops the server after next test
    tearDown(() => drailsServer.close());
    
    test('end', () {});
  });
}