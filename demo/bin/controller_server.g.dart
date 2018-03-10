// GENERATED CODE - DO NOT MODIFY BY HAND

part of drails_demo.controller_server.dart;

// **************************************************************************
// Generator: DsonGenerator
// **************************************************************************

abstract class _$HelloControllerSerializable extends SerializableMap {
  String get(String name);

  operator [](Object __key) {
    switch (__key) {
      case 'get':
        return get;
    }
    throwFieldNotFoundException(__key, 'HelloController');
  }

  operator []=(Object __key, __value) {
    switch (__key) {
    }
    throwFieldNotFoundException(__key, 'HelloController');
  }

  Iterable<String> get keys => HelloControllerClassMirror.fields.keys;
}

// **************************************************************************
// Generator: MirrorsGenerator
// **************************************************************************

_HelloController__Constructor([positionalParams, namedParams]) =>
    new HelloController();

const HelloControllerClassMirror =
    const ClassMirror(name: 'HelloController', constructors: const {
  '': const FunctionMirror(name: '', $call: _HelloController__Constructor)
}, methods: const {
  'get': const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'name', type: String, isRequired: true)
    ],
    name: 'get',
    returnType: String,
  )
});

// **************************************************************************
// Generator: InitMirrorsGenerator
// **************************************************************************

_initMirrors() {
  initClassMirrors({HelloController: HelloControllerClassMirror});
}
