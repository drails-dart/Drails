import 'dart:convert';
import 'dart:io';

import 'package:drails/drails.dart' hide GET, POST;
import 'package:http/http.dart';
import 'package:test/test.dart';

import '../example/server.dart' as drails_example;

main() {
  drails_example.main();

  var localhostUrl = 'http://127.0.0.1:4040';

  group('controllers ->', () {
    group('hello ->', () {
      var helloUrl = localhostUrl + '/hello';

      test('index', () async {
        var response = await get('$helloUrl/index');
        expect(response.body, equals('Hello from Hello service abstract class! Hi from HelloController!'));
      });

      test('getAll', () async {
        var response = await get(helloUrl);
        expect(response.body, equals('getAll: 20, 1'));
      });

      test('get', () async {
        var response = await get('$helloUrl/1');
        expect(response.body, equals('get: 1'));
      });

      test('getVar', () async {
        var response = await get('$helloUrl/getVar/1/2');
        expect(response.body, equals('get: 1, 2'));
      });
    });

    group('persons ->', () {
      var personsUrl = '$localhostUrl/persons';

      test('get persons', () async {
        var response = await get('$personsUrl');
        expect(response.body, equals(
            '[{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"},'
                '{"id":2,"firstName":"Alberto","lastName":"Tijerino","dob":"2000-01-01T00:00:00.000"},'
                '{"id":3,"firstName":"Ricardo","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}]'));
      });

      test('get persons/1', () async {
        var response = await get('$personsUrl/1');
        expect(
            response.body, equals('{"id":1,"firstName":"Luis","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}'));
      });

      test('put persons/1', () async {
        var response = await put(
            '$personsUrl/1',
            body: '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}');
        expect(response.body, '{"id":1,"firstName":"Luisito","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}');
      });

      test('post one persons', () async {
        var response = await post(
            personsUrl, body: '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}');
        expect(response.body, '{"id":1,"firstName":"Luisitos","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}');
      });

      test('post list of persons', () async {
        var response = await post(personsUrl, body:
        '[{"id":1,"firstName":"Luisss","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"},'
            '{"id":2,"firstName":"Albertoss","lastName":"Tijerino","dob":"2000-01-01T00:00:00.000"},'
            '{"id":3,"firstName":"Ricardoss","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}]');
        expect(response.body, equals(
            '[{"id":1,"firstName":"Luisss","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"},'
                '{"id":2,"firstName":"Albertoss","lastName":"Tijerino","dob":"2000-01-01T00:00:00.000"},'
                '{"id":3,"firstName":"Ricardoss","lastName":"Vargas","dob":"2000-01-01T00:00:00.000"}]'));
      });

      test('delete one person', () async {
        var response = await delete('$personsUrl/1');
        expect(response.statusCode, 200);
      });

      test('delete list of persons', () async {
        var response = await new Client().send(
            new Request('DELETE', new Uri.http('127.0.0.1:4040', '/persons'))..body = '[1,2]');
        expect(response.statusCode, 200);
      });
    });

    group('authorization sample ->', () {
      var loginUrl = localhostUrl + '/login',
          employeesUrl = localhostUrl + '/employees';

      group('no username password ->', () {
        test('login', () async {
          var response = await post(loginUrl);
          expect(response.statusCode, 401);
        });

        test('get employee 1', () async {
          var response = await get('$employeesUrl/1');
          expect(response.statusCode, 401);
          expect(response.body, equals(''));
        });

        test('save employee 1', () async {
          var response = await put('$employeesUrl/1', body: '{"id": 1,  "name": "lulo"}');
          expect(response.statusCode, 401);
        });

        test('save employees', () async {
          var response = await post(employeesUrl, body: '{"id": 1,  "name": "lulo"}');
          expect(response.statusCode, 401);
        });
      });

      group('wrong username password ->', () {
        test('login', () async {
          var response = await post(loginUrl + "?username=lulos&password=lulos");
          expect(response.statusCode, 401);
        });

        test('get employee 1', () async {
          var response = await get('$employeesUrl/1');
          expect(response.statusCode, 401);
          expect(response.body, equals(''));
        });

        test('save employee 1', () async {
          var response = await put('$employeesUrl/1', body: '{"id": 1,  "name": "lulo"}');
          expect(response.statusCode, 401);
        });

        test('save employees', () async {
          var response = await post(employeesUrl, body: '{"id": 1,  "name": "lulo"}');
          expect(response.statusCode, 401);
        });
      });

      group('good username password ->', () {
        var sessionId;
        test('login', () async {
          var response = await post(loginUrl + "?username=lulo&password=lulo");
          expect(response.statusCode, 200);
          sessionId =
              response.headers['set-cookie'].replaceFirst('DARTSESSID=', '').replaceFirst('; Path=/; HttpOnly', '');
        });

        test('get employees 1', () async {
          var request = await new HttpClient().get('127.0.0.1', 4040, '/employees/1');
          request.cookies.add(new Cookie('DARTSESSID', sessionId)..path = '/');
          var response = await request.close();
          expect(response.statusCode, 200);
          var body = await UTF8.decodeStream(response);
          expect(body, equals('employee: 1'));
        });

        test('save employees 1', () async {
          var response = await new HttpClient().put('127.0.0.1', 4040, '/employees/1').then((request) {
            request
              ..cookies.add(new Cookie('DARTSESSID', sessionId)..path = '/')
              ..write('{"id": 1,  "name": "luis"}');
            return request.close();
          });
          expect(response.statusCode, 200);
          var body = await UTF8.decodeStream(response);
          expect(body, equals('saved employee: 1, {id: 1, name: luis}'));
        });

        test('saveAll employee 1', () async {
          var response = await new HttpClient().post('127.0.0.1', 4040, '/employees').then((request) {
            request
              ..cookies.add(new Cookie('DARTSESSID', sessionId)..path = '/')
              ..writeln('{"id": 1,  "name": "lulo"}');
            return request.close();
          });
          expect(response.statusCode, 200);
          var body = await UTF8.decodeStream(response);
          expect(body, equals('{"id":1,"name":"lulo"}'));
        });
      });
    });

    //stops the server after next test
    test('end', () {
      DRAILS_SERVER.close();
    });
  });
}
