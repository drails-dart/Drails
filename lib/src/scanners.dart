part of drails;

/**
 * Get Value of annotations of Type [T] on [InstanceMirror]s and [DeclarationMirror]s
 */
class GetValueOfAnnotation<T> {
 final _iat = new IsAnnotation<T>();
  /**
   * Get the Instance of the Annotation of type [T] from the reflected annotated object [im]
   */
  T fromInstance(InstanceMirror im) => fromAnnotations(im.type.metadata);

  /**
   * Get the Instance of the Annotation of type [T] from the reflected annotated declaration (method or property) [obj]
   */
  T fromDeclaration(DeclarationMirror dm) => fromAnnotations(dm.metadata);

  /**
   * Get the Instance of the Annotation of type [T] from the list of annotations' [InstanceMirror]s
   */
  T fromAnnotations(List<InstanceMirror> ams) {
    if (_iat.anyOf(ams))
      return ams.singleWhere(_iat._isType).reflectee as T;
    return null;
  }

}

/**
 * Check if Annotation is on [InstanceMirror] or [DeclarationMirror]
 */
class IsAnnotation<T> {

  /**
   * Check if the Annotation of type [T] is on the reflected annotated object [im]
   */
  bool onInstance(InstanceMirror im) => anyOf(im.type.metadata);

  /**
   * Check if the Annotation of type [T] is on the reflected annotated declaration (method or property) [dm]
   */
  bool onDeclaration(DeclarationMirror dm) => anyOf(dm.metadata);

  /**
   * Check if any element of the list of annotations' InstanceMirrors mirros [am] is type [T]
   */
  bool anyOf(List<InstanceMirror> ams) {
    return ams.any(_isType);
  }

  /**
   * Checks if the annotation [InstanceMirror] is type [T]
   */
  bool _isType(InstanceMirror am) => am.reflectee is T;
}

/**
 * Get Declarations (methods and variables) annotated with [T] and are type [DM]
 */
class GetDeclarationsAnnotatedWith<T, DM> {
  /**
   * Get the iterable of [DeclarationMirror] that are annotated with [T]
   */
  Iterable<DM> from(InstanceMirror im) =>
      new List<DM>.from(im.type.declarations.values
          .where((declartionMirror) => 
              declartionMirror is DM
              && declartionMirror.metadata.any((am) => am.reflectee is T)));

}

/**
 * Get List of methods annotated with [T]
 */
class GetMethodsAnnotatedWith<T> {
  /**
   * Get List of methods annotated with [T] from the InstanceMirror [im]
   */
  Iterable<MethodMirror> from(InstanceMirror im) => new GetDeclarationsAnnotatedWith<T, MethodMirror>().from(im);
}
/**
 * Get List of variables annotated with [T]
 */
class GetVariablesAnnotatedWith<T> {
  /**
   * Get List of variables annotated with [T] from the InstanceMirror [im]
   */
  Iterable<VariableMirror> from(InstanceMirror im) => new GetDeclarationsAnnotatedWith<T, VariableMirror>().from(im);
}
/**
 * Get the list of [MethodMirrors] from [ClassMirror] cm
 */
Iterable<MethodMirror> getMethodMirrorsFromClass(ClassMirror cm) {
  var methodMirrors = [];

  if (cm.superclass != reflectClass(Object)) {
    methodMirrors.addAll(getMethodMirrorsFromClass(cm.superclass));
  }

  return methodMirrors..addAll(
      cm.declarations.values.where((dm) => 
        dm is MethodMirror && (dm as MethodMirror).isRegularMethod));
}

/**
 * Gets the object that extends the [injectableCm] from [declarationCms]
 */
Object getObjectThatExtend(ClassMirror injectableCm, Iterable<DeclarationMirror> declarationCms) {
  ClassMirror result;
  int counter = 0, counter2 = 0;
  for(ClassMirror cm in declarationCms) {
    counter = _getExtensionLevel(injectableCm, cm, counter);
    if(counter > 0 && counter2 < counter) {
      result = cm;
      counter2 = counter;
      counter = 0;
    }
  }
  
  return result.newInstance(const Symbol(''), []).reflectee;
}

/**
 * Get the level value that a [declarationCm] extends the [injectableCm], for example:
 * 
 * If we have next Abstract class:
 *
 *     abstract class SomeService {
 *       String someMethod();
 *     }
 * 
 * The Extension level of the next service is 1
 *
 *     class SomeServiceImpl implements SomeService {
 *       String someMethod() => 'someMethod';
 *     }
 * 
 * And the Extension level of the next service is 2
 *
 *     class SomeServiceImpl2 extens SomeServiceImpl {
 *       String someMethod() => super.someMethod() + '2';
 *     }
 */
int _getExtensionLevel(ClassMirror injectableCm, ClassMirror declarationCm, int counter) {
  
  if(declarationCm == reflectClass(Object)) {
    return counter = 0;
    
  }

  counter++;
  if(!(declarationCm.superclass == injectableCm || declarationCm.superinterfaces.any((icm) => icm == injectableCm))) {
    counter = _getExtensionLevel(injectableCm, declarationCm.superclass, counter);
  }
  
  return counter;
}
