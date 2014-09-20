# DSON Object Mapper

The porpouse of this library is to convert Objects to JSON and JSON Objects using reflection (simillar approch to Jackson and Gson Java Object Mappers).

##JSON to Object
To convert JSON to a Dart Object you need to create a library wich contains your PODO(Pure Old Dart Object):
    
    library myclass_library;
    
    class MyNestedClass {
      String name;
    }
    
    class MyClass {
      int i, j;
      String greeting;
      MyNestedClass myNestedClass;
      int get sum => i + j;
      List<int> intList;
      List<String> stringList;
      List<MyNestedClass> myNestedClassList;
    
      MyClass();
    }

And then import it in the libray that is in charge of converting the object:
    
    import "package:DSON/ObjectMapper.dart";
    import "myclass_library.dart";
    
    main() {
    
       MyClass myObject = Reader.jsonToObject(
            '{'
                '"greeting": "hello, there",'
                '"i": 3,'
                '"j": 5,'
                '"intList": [1, 2, 3, 4, 5],'
                '"stringList": ["string1", "string2"],'
                '"myNestedClass": {'
                      '"name": "someName"'
                '},'
                '"myNestedClassList": ['
                   '{'
                     '"name": "someName1"'
                   '},{'
                     '"name": "someName2"'
                   '}'
                ']'
            '}', MyClass, "myclass_library");
    
      print(myObject.i); // prints 3
      print(myObject.j); // prints 5
      print(myObject.greeting); //prints "hello, there"
      print(myObject.myNestedClass.name); // prints "someName"
      print(myObject.myNestedClassList[0].name); // prints "someName1"
      print(myObject.myNestedClassList[1].name); // prints "someName2"
    }

##JSON to List of Objects
Basically is the same as converting JSON to an object, you just need to pass the type of the list that you want to convert:

    import "package:DSON/object_mapper.dart";
    import "myclass_library.dart";
    
    main() {
    
       var myNestedClassList = Reader.jsontoListOfObjects(
          '['
            '{'
              '"name": "someName1"'
            '},{'
              '"name": "someName2"'
            '}'
          ']', MyNestedClass, "myclass_library");
    
        print(myNestedClassList[0].name); // print "someName1"
        print(myNestedClassList[1].name); // print "someName2"
    }

Note that the class **MyNestedClass** is inside a library. This is because a class cannot be converted if it is not inside a library. 


##Object to JSON
To convert from an object to JSON you just need to declare the class, instantiate the object and convert it:

    class MyNestedClass {
      String name;
    }
    
    class MyClass {
      int i, j;
      MyNestedClass myNestedClass;
      int get sum => i + j;
    
      MyClass(this.i, this.j);
    }
    
    main() {
    
      MyClass myClass = new MyClass(3, 5)
        ..myNestedClass = (new MyNestedClass()..name = "luis");

      print(Writer.objectToJson(myClass)) //resutl: '{"i":3,"j":5,"myNestedClass":{"name":"luis"},"sum":8}'));
    }
    

