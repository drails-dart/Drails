// GENERATED CODE - DO NOT MODIFY BY HAND

part of drails_example;

// **************************************************************************
// Generator: DsonGenerator
// **************************************************************************

abstract class _$HelloControllerSerializable extends SerializableMap {
  String get someString;
  HelloService get helloService;
  void set someString(String v);
  void set helloService(HelloService v);
  String index();
  String get(int id);
  String getAll({String pageSize: '20', String pageNumber: '1'});
  String getVar(int id, String var1);
  String get2();

  operator [](Object __key) {
    switch (__key) {
      case 'someString':
        return someString;
      case 'helloService':
        return helloService;
      case 'index':
        return index;
      case 'get':
        return get;
      case 'getAll':
        return getAll;
      case 'getVar':
        return getVar;
      case 'get2':
        return get2;
    }
    throwFieldNotFoundException(__key, 'HelloController');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'someString':
        someString = __value;
        return;
      case 'helloService':
        helloService = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'HelloController');
  }

  Iterable<String> get keys => HelloControllerClassMirror.fields.keys;
}

abstract class _$HiControllerSerializable extends SerializableMap {
  String index();
  String get2();

  operator [](Object __key) {
    switch (__key) {
      case 'index':
        return index;
      case 'get2':
        return get2;
    }
    throwFieldNotFoundException(__key, 'HiController');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'HiController');
  }

  Iterable<String> get keys => HiControllerClassMirror.fields.keys;
}

abstract class _$HelloServiceSerializable extends SerializableMap {
  String sayHello();

  operator [](Object __key) {
    switch (__key) {
      case 'sayHello':
        return sayHello;
    }
    throwFieldNotFoundException(__key, 'HelloService');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'HelloService');
  }

  Iterable<String> get keys => HelloServiceClassMirror.fields.keys;
}

abstract class _$HelloServiceImplSerializable extends SerializableMap {
  String sayHello();

  operator [](Object __key) {
    switch (__key) {
      case 'sayHello':
        return sayHello;
    }
    throwFieldNotFoundException(__key, 'HelloServiceImpl');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'HelloServiceImpl');
  }

  Iterable<String> get keys => HelloServiceImplClassMirror.fields.keys;
}

abstract class _$HelloServiceImpl2Serializable extends SerializableMap {
  String sayHello();

  operator [](Object __key) {
    switch (__key) {
      case 'sayHello':
        return sayHello;
    }
    throwFieldNotFoundException(__key, 'HelloServiceImpl2');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'HelloServiceImpl2');
  }

  Iterable<String> get keys => HelloServiceImpl2ClassMirror.fields.keys;
}

abstract class _$SomeServiceSerializable extends SerializableMap {
  String someMethod();

  operator [](Object __key) {
    switch (__key) {
      case 'someMethod':
        return someMethod;
    }
    throwFieldNotFoundException(__key, 'SomeService');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'SomeService');
  }

  Iterable<String> get keys => SomeServiceClassMirror.fields.keys;
}

abstract class _$SomeServiceImplSerializable extends SerializableMap {
  String someMethod();

  operator [](Object __key) {
    switch (__key) {
      case 'someMethod':
        return someMethod;
    }
    throwFieldNotFoundException(__key, 'SomeServiceImpl');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'SomeServiceImpl');
  }

  Iterable<String> get keys => SomeServiceImplClassMirror.fields.keys;
}

abstract class _$AsyncEmployeesControllerSerializable extends SerializableMap {
  Future<Employee> get(int id);

  operator [](Object __key) {
    switch (__key) {
      case 'get':
        return get;
    }
    throwFieldNotFoundException(__key, 'AsyncEmployeesController');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'AsyncEmployeesController');
  }

  Iterable<String> get keys => AsyncEmployeesControllerClassMirror.fields.keys;
}

abstract class _$EmployeesControllerSerializable extends SerializableMap {
  String get(int id);
  String save(int id, @RequestBody Map employee);
  Map<dynamic, dynamic> saveAll(@RequestBody Map employee);

  operator [](Object __key) {
    switch (__key) {
      case 'get':
        return get;
      case 'save':
        return save;
      case 'saveAll':
        return saveAll;
    }
    throwFieldNotFoundException(__key, 'EmployeesController');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'EmployeesController');
  }

  Iterable<String> get keys => EmployeesControllerClassMirror.fields.keys;
}

abstract class _$PersonsControllerSerializable extends SerializableMap {
  Map<int, Person> get persons;
  void set persons(Map<int, Person> v);
  Person get(int id);
  List<Person> getAll();
  Person save(int id, @RequestBody Person person);
  Iterable<Person> saveAll(@RequestBody List<Person> persons);
  void delete(int id);
  void deleteAll(@RequestBody List<int> ids);

  operator [](Object __key) {
    switch (__key) {
      case 'persons':
        return persons;
      case 'get':
        return get;
      case 'getAll':
        return getAll;
      case 'save':
        return save;
      case 'saveAll':
        return saveAll;
      case 'delete':
        return delete;
      case 'deleteAll':
        return deleteAll;
    }
    throwFieldNotFoundException(__key, 'PersonsController');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
      case 'persons':
        persons = __value;
        return;
    }
    throwFieldNotFoundException(__key, 'PersonsController');
  }

  Iterable<String> get keys => PersonsControllerClassMirror.fields.keys;
}

// **************************************************************************
// Generator: MirrorsGenerator
// **************************************************************************

const loginFunctionMirror = const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'httpSession', type: HttpSession, isRequired: true)
    ],
    namedParameters: const {
      'username': const DeclarationMirror(
          name: 'username', type: String, isNamed: true),
      'password':
          const DeclarationMirror(name: 'password', type: String, isNamed: true)
    },
    name: 'login',
    returnType: dynamic,
    annotations: const [const Path(r''), POST]);
_HelloController__Constructor([positionalParams, namedParams]) =>
    new HelloController();

const $$HelloController_fields_someString =
    const DeclarationMirror(name: 'someString', type: String);
const $$HelloController_fields_helloService = const DeclarationMirror(
    name: 'helloService', type: HelloService, annotations: const [autowired]);

const HelloControllerClassMirror =
    const ClassMirror(name: 'HelloController', constructors: const {
  '': const FunctionMirror(name: '', $call: _HelloController__Constructor)
}, fields: const {
  'someString': $$HelloController_fields_someString,
  'helloService': $$HelloController_fields_helloService
}, getters: const [
  'someString',
  'helloService'
], setters: const [
  'someString',
  'helloService'
], methods: const {
  'index': const FunctionMirror(
    name: 'index',
    returnType: String,
  ),
  'get': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'id', type: int, isRequired: true)
    ],
    name: 'get',
    returnType: String,
  ),
  'getAll': const FunctionMirror(
    namedParameters: const {
      'pageSize': const DeclarationMirror(
          name: 'pageSize', type: String, isNamed: true),
      'pageNumber': const DeclarationMirror(
          name: 'pageNumber', type: String, isNamed: true)
    },
    name: 'getAll',
    returnType: String,
  ),
  'getVar': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'id', type: int, isRequired: true),
      const DeclarationMirror(name: 'var1', type: String, isRequired: true)
    ],
    name: 'getVar',
    returnType: String,
  ),
  'get2': const FunctionMirror(
    name: 'get2',
    returnType: String,
  )
});
_HiController__Constructor([positionalParams, namedParams]) =>
    new HiController();

const HiControllerClassMirror =
    const ClassMirror(name: 'HiController', constructors: const {
  '': const FunctionMirror(name: '', $call: _HiController__Constructor)
}, methods: const {
  'index': const FunctionMirror(
    name: 'index',
    returnType: String,
  ),
  'get2': const FunctionMirror(
    name: 'get2',
    returnType: String,
  )
});

const HelloServiceClassMirror = const ClassMirror(
    name: 'HelloService',
    methods: const {
      'sayHello': const FunctionMirror(
        name: 'sayHello',
        returnType: String,
      )
    },
    isAbstract: true);
_HelloServiceImpl__Constructor([positionalParams, namedParams]) =>
    new HelloServiceImpl();

const HelloServiceImplClassMirror = const ClassMirror(
    name: 'HelloServiceImpl',
    constructors: const {
      '': const FunctionMirror(name: '', $call: _HelloServiceImpl__Constructor)
    },
    methods: const {
      'sayHello': const FunctionMirror(
        name: 'sayHello',
        returnType: String,
      )
    },
    superclass: HelloService);
_HelloServiceImpl2__Constructor([positionalParams, namedParams]) =>
    new HelloServiceImpl2();

const HelloServiceImpl2ClassMirror = const ClassMirror(
    name: 'HelloServiceImpl2',
    constructors: const {
      '': const FunctionMirror(name: '', $call: _HelloServiceImpl2__Constructor)
    },
    methods: const {
      'sayHello': const FunctionMirror(
        name: 'sayHello',
        returnType: String,
      )
    },
    superclass: HelloServiceImpl);

const SomeServiceClassMirror = const ClassMirror(
    name: 'SomeService',
    methods: const {
      'someMethod': const FunctionMirror(
        name: 'someMethod',
        returnType: String,
      )
    },
    isAbstract: true);
_SomeServiceImpl__Constructor([positionalParams, namedParams]) =>
    new SomeServiceImpl();

const SomeServiceImplClassMirror =
    const ClassMirror(name: 'SomeServiceImpl', constructors: const {
  '': const FunctionMirror(name: '', $call: _SomeServiceImpl__Constructor)
}, methods: const {
  'someMethod': const FunctionMirror(
    name: 'someMethod',
    returnType: String,
  )
}, superinterfaces: const [
  SomeService
]);
_AsyncEmployeesController__Constructor([positionalParams, namedParams]) =>
    new AsyncEmployeesController();

const AsyncEmployeesControllerClassMirror =
    const ClassMirror(name: 'AsyncEmployeesController', constructors: const {
  '': const FunctionMirror(
      name: '', $call: _AsyncEmployeesController__Constructor)
}, methods: const {
  'get': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'id', type: int, isRequired: true)
    ],
    name: 'get',
    returnType: const [Future, Employee],
  )
});
_EmployeesController__Constructor([positionalParams, namedParams]) =>
    new EmployeesController();

const EmployeesControllerClassMirror =
    const ClassMirror(name: 'EmployeesController', constructors: const {
  '': const FunctionMirror(name: '', $call: _EmployeesController__Constructor)
}, annotations: const [
  const AuthorizeIf(hasRolePublicOrAdmin)
], methods: const {
  'get': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'id', type: int, isRequired: true)
    ],
    name: 'get',
    returnType: String,
  ),
  'save': const FunctionMirror(
      positionalParameters: const [
        const DeclarationMirror(name: 'id', type: int, isRequired: true),
        const DeclarationMirror(
            name: 'employee',
            type: const [
              Map,
              const [dynamic, dynamic]
            ],
            isRequired: true,
            annotations: const [RequestBody])
      ],
      name: 'save',
      returnType: String,
      annotations: const [
        const AuthorizeRoles(const [r'ADMIN'])
      ]),
  'saveAll': const FunctionMirror(
      positionalParameters: const [
        const DeclarationMirror(
            name: 'employee',
            type: const [
              Map,
              const [dynamic, dynamic]
            ],
            isRequired: true,
            annotations: const [RequestBody])
      ],
      name: 'saveAll',
      returnType: const [
        Map,
        const [dynamic, dynamic]
      ],
      annotations: const [
        const DenyRoles(const [r'PUBLIC'])
      ])
});
_PersonsController__Constructor([positionalParams, namedParams]) =>
    new PersonsController();

const $$PersonsController_fields_lastId =
    const DeclarationMirror(name: 'lastId', type: int);
const $$PersonsController_fields_persons =
    const DeclarationMirror(name: 'persons', type: const [
  Map,
  const [int, Person]
]);

const PersonsControllerClassMirror =
    const ClassMirror(name: 'PersonsController', constructors: const {
  '': const FunctionMirror(name: '', $call: _PersonsController__Constructor)
}, fields: const {
  'persons': $$PersonsController_fields_persons
}, getters: const [
  'persons'
], setters: const [
  'persons'
], methods: const {
  'get': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'id', type: int, isRequired: true)
    ],
    name: 'get',
    returnType: Person,
  ),
  'getAll': const FunctionMirror(
    name: 'getAll',
    returnType: const [List, Person],
  ),
  'save': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'id', type: int, isRequired: true),
      const DeclarationMirror(
          name: 'person',
          type: Person,
          isRequired: true,
          annotations: const [RequestBody])
    ],
    name: 'save',
    returnType: Person,
  ),
  'saveAll': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'persons',
          type: const [List, Person],
          isRequired: true,
          annotations: const [RequestBody])
    ],
    name: 'saveAll',
    returnType: const [Iterable, Person],
  ),
  'delete': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'id', type: int, isRequired: true)
    ],
    name: 'delete',
    returnType: null,
  ),
  'deleteAll': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(
          name: 'ids',
          type: const [List, int],
          isRequired: true,
          annotations: const [RequestBody])
    ],
    name: 'deleteAll',
    returnType: null,
  )
});

// **************************************************************************
// Generator: InitMirrorsGenerator
// **************************************************************************

_initMirrors() {
  initClassMirrors({
    HelloController: HelloControllerClassMirror,
    HiController: HiControllerClassMirror,
    HelloService: HelloServiceClassMirror,
    HelloServiceImpl: HelloServiceImplClassMirror,
    HelloServiceImpl2: HelloServiceImpl2ClassMirror,
    SomeService: SomeServiceClassMirror,
    SomeServiceImpl: SomeServiceImplClassMirror,
    AsyncEmployeesController: AsyncEmployeesControllerClassMirror,
    EmployeesController: EmployeesControllerClassMirror,
    PersonsController: PersonsControllerClassMirror,
    Employee: EmployeeClassMirror,
    User: UserClassMirror,
    UserMixin: UserMixinClassMirror,
    Person: PersonClassMirror
  });
  initFunctionMirrors({login: loginFunctionMirror});
}
