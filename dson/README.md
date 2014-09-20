# dson

dson is a dart library which converts Dart Objects into their JSON representation. It helps you keep your code clean of `fromJSON` and `toJSON` functions by using dart:mirrors reflection. **It works after dart2js compiling.**

This library is a fork from [dartson](https://github.com/eredo/dartson). I removed transformers and add datetime parsing and other minor changes.

## Serializing objects in dart

```dart
library example;

import 'package:dson/dson.dart';

@MirrorsUsed(targets:const['example'],override:'*')
import 'dart:mirrors';

class EntityClass {
  String name;
  
  @Property(name:"renamed")
  bool otherName;
  
  @ignore
  String notVisible;
  
  // private members are never serialized
  String _private = "name";
  
  String get doGetter => _private;
}

void main() {
  EntityClass object = new EntityClass()
    ..name = "test";
    ..otherName = "blub";
    ..notVisible = "hallo";
  
  String jsonString = serialize(object);
  print(jsonString);
  // will return: '{"name":"test","renamed":"blub","doGetter":"name"}'
}
```

## Parsing json to dart object

```dart
library example;

import 'package:dson/dson.dart';

@MirrorsUsed(targets:const['example'],override:'*')
import 'dart:mirrors';

class EntityClass {
  String name;
  String _setted;
  
  @dsonProperty(name:"renamed")
  bool otherName;
  
  @dsonProperty(ignore:true)
  String notVisible;
  
  List<EntityClass> children;
  
  set setted(String s) => _setted = s;
  String get setted => _setted;
}

void main() {
  EntityClass object = parse('{"name":"test","renamed":"blub","notVisible":"it is", "setted": "awesome"}', EntityClass);
  
  print(object.name); // > test
  print(object.otherName); // > blub
  print(object.notVisible); // > it is
  print(object.setted); // > awesome
  
  // to parse a list of items use [parseList]
  List<EntityClass> list = parseList('[{"name":"test", "children": [{"name":"child1"},{"name":"child2"}]},{"name":"test2"}]', EntityClass);
  print(list.length); // > 2
  print(list[0].name); // > test
  print(list[0].children[0].name); // > child1
}
```

## Mapping Maps and Lists to dart objects
Frameworks like Angular.dart come with several HTTP services which already transform the HTTP response to a map using JSON.encode. To use those encoded Maps or Lists use `map` and `mapList`.

```dart
library example;

import 'package:dson/dson.dart';

@MirrorsUsed(targets:const['example'],override:'*')
import 'dart:mirrors';

class EntityClass {
  String name;
  String _setted;
  
  @dsonProperty(name:"renamed")
  bool otherName;
  
  @dsonProperty(ignore:true)
  String notVisible;
  
  List<EntityClass> children;
  
  set setted(String s) => _setted = s;
  String get setted => _setted;
}

void main() {
  EntityClass object = map({"name":"test","renamed":"blub","notVisible":"it is", "setted": "awesome"}, EntityClass);  
  print(object.name); // > test
  print(object.otherName); // > blub
  print(object.notVisible); // > it is
  print(object.setted); // > awesome
  
  // to parse a list of items use [parseList]
  List<EntityClass> list = mapList([{"name":"test", "children": [{"name":"child1"},{"name":"child2"}]},{"name":"test2"}], EntityClass);
  print(list.length); // > 2
  print(list[0].name); // > test
  print(list[0].children[0].name); // > child1
}
```

## TODO

- Handle recrusive errors
