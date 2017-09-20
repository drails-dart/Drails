// GENERATED CODE - DO NOT MODIFY BY HAND

part of drails_demo.simple_server;

// **************************************************************************
// Generator: MirrorsGenerator
// **************************************************************************

const helloFunctionMirror = const FunctionMirror(
    positionalParameters: const [
      const DeclarationMirror(name: 'name', type: String, isRequired: true)
    ],
    name: 'hello',
    returnType: String,
    annotations: const [GET]);

// **************************************************************************
// Generator: InitMirrorsGenerator
// **************************************************************************

_initMirrors() {
  initClassMirrors({});
  initFunctionMirrors({hello: helloFunctionMirror});
}
