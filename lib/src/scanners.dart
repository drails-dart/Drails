part of drails;

/**
 * Get Value of annotations of Type [T] on [InstanceMirror]s and [DeclarationMirror]s
 */
class GetValueOfAnnotation<T> {
 final _iat = new IsAnnotation<T>();
  /**
   * Get the Instance of the Annotation of type [T] from the reflected annotated object [im]
   */
  T fromIm(InstanceMirror im) => fromAms(im.type.metadata);

  /**
   * Get the Instance of the Annotation of type [T] from the reflected annotated declaration (method or property) [obj]
   */
  T fromDm(DeclarationMirror dm) => fromAms(dm.metadata);

  /**
   * Get the Instance of the Annotation of type [T] from the list of annotations' [InstanceMirror]s
   */
  T fromAms(List<InstanceMirror> ams) {
    if (_iat.any(ams))
      return ams.singleWhere(_iat._isType).reflectee as T;
    return null;
  }

}

  
class IsAnnotation<T> {

  /**
   * Check if the Annotation of type [T] is on the reflected annotated object [im]
   */
  bool onIm(InstanceMirror im) => any(im.type.metadata);

  /**
   * Check if the Annotation of type [T] is on the reflected annotated declaration (method or property) [dm]
   */
  bool onDm(DeclarationMirror dm) => any(dm.metadata);

  /**
   * Check if any element of the list of annotations' InstanceMirrors mirros [am] is type [T]
   */
  bool any(List<InstanceMirror> ams) {
    return ams.any(_isType);
  }

  /**
   * Checks if the annotation [InstanceMirror] is type [T]
   */
  bool _isType(InstanceMirror am) => am.reflectee is T;
}


class GetObjectsAnnotatedWith<T> {

  /**
   * Scans currentMirrorSystem().isolate.rootLibrary and get the declarations that are
   * [ClassMirror] and contains any annotation [T] and returns a List of reflectees
   * of type [R]
   *
   *     //Get the list of Controllers
   *     List<_Controller> controllers = new Scanner<_Controller, Object>().scan()
   */
  Iterable fromLibraries() {

    var scannedObjects = [];

    //For each library in currentSystem().libraries:
    currentMirrorSystem().libraries.values.forEach(
      //Add all reflectees in lm.declaration.values
      (lm) => scannedObjects.addAll(lm.declarations.values
        //Where:
        .where((dm) =>
          //declarationMirror is ClassMirror
          dm is ClassMirror
          //And declarationMirror.metadata contains any instanceMirror.reflectee with type T
          && dm.metadata.any((im) => im.reflectee is T)
        ).map(// map the result from where to a Reflectee
              (dm) => (dm as ClassMirror).newInstance(const Symbol(''), []).reflectee)
    ));

    return scannedObjects;
  }
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

class ClassSearcher {

  int counter = 0; 
  
  Object getObjectThatExtend(ClassMirror injectableCm, Iterable<DeclarationMirror> declarationCms) {
    
    ClassMirror result;
    int counter2 = 0;
    for(ClassMirror cm in declarationCms) {
      _getObjectThatExtend(injectableCm, cm);
      if(counter > 0 && counter2 < counter) {
        result = cm;
        counter2 = counter;
        counter = 0;
      }
    }
    return result.newInstance(const Symbol(''), []).reflectee;
  }
  
  void _getObjectThatExtend(ClassMirror injectableCm, ClassMirror declarationCm) {
    
    if(declarationCm == reflectClass(Object)) {
      counter = 0;
      return;
    }

    counter++;
    if(!(declarationCm.superclass == injectableCm || declarationCm.superinterfaces.any((icm) => icm == injectableCm))) {
      _getObjectThatExtend(injectableCm, declarationCm.superclass);
    }
  }
}
