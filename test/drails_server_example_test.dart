import 'example_test/server.dart' as drails_example;
import 'package:test/test.dart';
import 'package:http/http.dart';
import 'package:drails/drails.dart' hide GET, POST;
import 'dart:io';
import 'dart:convert';

main() {
  drails_example.main();
  
  var localhostUrl = 'http://127.0.0.1:4040';

  group('controllers ->', () {

    group('hello ->', () {

      var helloUrl = localhostUrl + '/hello';

      test('index', () {
        get('$helloUrl/index').then(expectAsync((response) {
          expect(response.body, equals('hello from Hello service abstract class and from HelloController hi'));
        }));
      });

      test('getAll', () {
        get(helloUrl).then(expectAsync((response) {
          expect(response.body, equals('getAll: 20, 1'));
        }));
      });

      test('get', () {
        get('$helloUrl/1').then(expectAsync((response) {
          expect(response.body, equals('get: 1'));
        }));
      });

      test('getVar', () {
        get('$helloUrl/getVar/1/2').then(expectAsync((response) {
          expect(response.body, equals('get: 1, 2'));
        }));
      });
    });

    group('persons ->', () {
      var personsUrl = '$localhostUrl/persons';

      test('get persons', () {
        get('$personsUrl').then(expectAsync((response) {
          expect(response.body, equals(
            '[{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"},'
            '{"id":2,"firstName":"Alberto","lastName":"Tijerino","dob":"1988-04-01T00:00:00.000"},'
            '{"id":3,"firstName":"Ricardo","lastName":"Vargas","dob":"1989-08-28T00:00:00.000"}]'));
        }));
      });

      test('get persons/1', () {
        get('$personsUrl/1').then(expectAsync((response) {
            expect(response.body, equals('{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}'));
        }));
      });

      test('put persons/1', () {
        put('$personsUrl/1', body: '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}')
        .then(expectAsync((response) {
          expect(response.body, '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}');
        }));
      });

      test('post one persons', () {
        post(personsUrl, body: '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}')
        .then(expectAsync((response) {
          expect(response.body, '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"1988-04-01T00:00:00.000"}');
        }));
      });

      test('post list of persons', () {
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

      test('delete one person', () {
        delete('$personsUrl/1').then(expectAsync((Response response) {
          expect(response.statusCode, 200);
        }));
      });

      test('delete list of persons', () {
        new Client().send(new Request('DELETE', new Uri.http('127.0.0.1:4040', '/persons'))..body = '[1,2]').then(expectAsync((response) {
          expect(response.statusCode, 200);
        }));
      });
    });

    group('authorization sample ->', () {
      var loginUrl = localhostUrl + '/login', employeesUrl = localhostUrl + '/employees';
      
      group('no username password', () {

        test(' login', () {
          post(loginUrl).then(expectAsync((Response response) {
            expect(response.statusCode, 400);
          }));
        });

        test('get employee 1', () {
          get('$employeesUrl/1').then(expectAsync((response) {
            expect(response.statusCode, 401);
            expect(response.body, equals(''));
          }));
        });

        test('save employee 1', () {
           put('$employeesUrl/1', body:'{"id": 1,  "name": "lulo"}').then(expectAsync((Response response) {
             expect(response.statusCode, 401);
           }));
         });

        test('save employees', () {
           post(employeesUrl, body:'{"id": 1,  "name": "lulo"}').then(expectAsync((Response response) {
             expect(response.statusCode, 401);
           }));
         });
      });

      group('wrong username password ->', () {
        test('login', () {
          post(loginUrl, body:'{"name": "lulos",  "password": "lulos"}').then(expectAsync((Response response) {
            expect(response.statusCode, 401);
          }));
        });

        test('get employee 1', () {
          get('$employeesUrl/1').then(expectAsync((response) {
            expect(response.statusCode, 401);
            expect(response.body, equals(''));
          }));
        });

        test('save employee 1', () {
           put('$employeesUrl/1', body:'{"id": 1,  "name": "lulo"}').then(expectAsync((Response response) {
             expect(response.statusCode, 401);
           }));
         });

        test('save employees', () {
           post(employeesUrl, body:'{"id": 1,  "name": "lulo"}').then(expectAsync((Response response) {
             expect(response.statusCode, 401);
           }));
         });
      });

      group('good username password ->', () {
        var sessionId;
        test('login', () {
          post(loginUrl, body:'{"name": "lulo",  "password": "lulo"}').then(expectAsync((Response response) {
            expect(response.statusCode, 200);
            sessionId = response.headers['set-cookie'].replaceFirst('DARTSESSID=', '').replaceFirst('; Path=/; HttpOnly', '');
          }));
        });

        test('get employees 1', () {
          new HttpClient().get('127.0.0.1', 4040, '/employees/1').then((request) {
            request.cookies.add(new Cookie('DARTSESSID',sessionId)..path = '/');
            return request.close();
          }).then(expectAsync((HttpClientResponse response) {
            expect(response.statusCode, 200);
            UTF8.decodeStream(response).then(expectAsync((body) {
              expect(body, equals('employee: 1'));
            }));
          }));
        });

        test('save employees 1', () {
          new HttpClient().put('127.0.0.1', 4040, '/employees/1').then((request) {
            request
                ..cookies.add(new Cookie('DARTSESSID',sessionId)..path = '/')
                ..write('{"id": 1,  "name": "luis"}');
            return request.close();
          }).then(expectAsync((HttpClientResponse response) {
            expect(response.statusCode, 200);
            UTF8.decodeStream(response).then(expectAsync((body) {
              expect(body, equals('saved employee: 1, {id: 1, name: luis}'));
            }));
          }));
        });

        test('saveAll employee 1', () {
          new HttpClient().post('127.0.0.1', 4040, '/employees').then((request) {
            request
                ..cookies.add(new Cookie('DARTSESSID',sessionId)..path = '/')
                ..writeln('{"id": 1,  "name": "lulo"}');
            return request.close();
          }).then(expectAsync((HttpClientResponse response) {
            expect(response.statusCode, 200);
            UTF8.decodeStream(response).then(expectAsync((body) {
              expect(body, equals('{"id":1,"name":"lulo"}'));
            }));
          }));
        });
      });
    });
    
    //stops the server after next test
    test('end', () {DRAILS_SERVER.close();});
  });
}
