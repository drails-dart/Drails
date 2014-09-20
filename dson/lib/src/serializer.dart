part of dson;

Logger _serLog = new Logger('object_mapper_serializer');

/**
 * Serializes the [object] to a JSON string.
 */
String serialize(Object object, [bool parseString = false]) {
  _serLog.fine("Start serializing");
  
  if(object is String && !parseString) return object;
  
  return JSON.encode(objectToSerializable(object));
}

Object objectToSerializable(Object obj) {
  if (obj is String || obj is num || obj is bool || obj == null) {
    _serLog.fine("Found primetive: $obj");
    return obj;
  } else if (obj is DateTime) {
    _serLog.fine("Found DateTime: $obj");
    return obj.toIso8601String();
  } else if (obj is List) {
    _serLog.fine("Found list: $obj");
    return _serializeList(obj);
  } else if (obj is Map) {
    _serLog.fine("Found map: $obj");
    return _serializeMap(obj);
  } else {
    _serLog.fine("Found object: $obj");
    return _serializeObject(obj);
  }
}

List _serializeList(List list) {
  List newList = [];

  list.forEach((item) {
    newList.add(objectToSerializable(item));
  });

  return newList;
}

Map _serializeMap(Map map) {
  Map newMap = new Map<String,Object>();
  map.forEach((key, val) {
    if (val != null) {
      newMap[key] = objectToSerializable(val);
    }
  });

  return newMap;
}

/**
 * Runs through the Object keys by using a ClassMirror.
 */
Object _serializeObject(Object obj) {
  InstanceMirror instMirror = reflect(obj);
  ClassMirror classMirror = instMirror.type;
  _serLog.fine("Serializing class: ${_getName(classMirror.qualifiedName)}");

  Map result = new Map<String,Object>();
  
  getPublicVariablesFromClass(classMirror).forEach((sym, decl) {
      _pushField(sym, decl, instMirror, result);
  });

  _serLog.fine("Serialization completed.");
  return result;
}

/**
 * Checks the DeclarationMirror [variable] for annotations and adds
 * the value to the [result] map. If there's no [Property] annotation 
 * with a different name set it will use the name of [symbol].
 */
void _pushField(Symbol symbol, DeclarationMirror variable,
                InstanceMirror instMirror, Map<String,Object> result) {

  String fieldName = MirrorSystem.getName(symbol);
  if(fieldName.isEmpty) return;
  
  InstanceMirror field = instMirror.getField(symbol);
  Object value = field.reflectee;
  _serLog.finer("Start serializing field: ${fieldName}");
  
  // check if there is a DartsonProperty annotation
  Property prop = new GetValueOfAnnotation<Property>().fromDeclaration(variable);
  _serLog.finer("Property: ${prop}");
  
  if (prop != null && prop.name != null) {  
    _serLog.finer("Field renamed to: ${prop.name}");
    fieldName = prop.name;
  }
  
  if (value != null && !new IsAnnotation<_Ignore>().onDeclaration(variable)) {
    _serLog.finer("Serializing field: ${fieldName}");
    result[fieldName] = objectToSerializable(value);
  }
}
