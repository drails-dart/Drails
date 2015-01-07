part of dson;

Logger _serLog = new Logger('object_mapper_serializer');

Map<Object, Map> _serializedStack = {};

bool isPrimitive(var value) => value is String || value is num || value is bool || value == null;

bool isSuperPrimitive(var value) => isPrimitive(value) || value is DateTime || value is List || value is Map;

/**
 * Serializes the [object] to a JSON string.
 */
String serialize(Object object, {bool parseString: false, var depth}) {
  _serLog.fine("Start serializing");

  if (object is String && !parseString) return object;

  var result = JSON.encode(objectToSerializable(object, depth: depth));

  _serializedStack.clear();

  return result;
}

Object objectToSerializable(Object obj, {var depth, String fieldName}) {
  if (isPrimitive(obj)) {
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
    return _serializeObject(obj, depth);
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
  Map newMap = new Map<String, Object>();
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
Object _serializeObject(Object obj, var depth) {
  InstanceMirror instMirror = reflect(obj);
  ClassMirror classMirror = instMirror.type;
  _serLog.fine("Serializing class: ${_getName(classMirror.qualifiedName)}");

  Map result = new Map<String, dynamic>();

  if (_serializedStack[obj] == null) {
    getPublicVariablesFromClass(classMirror).forEach((sym, decl) {
      _pushField(sym, decl, instMirror, result, depth);
    });
    
    if (getPublicVariablesFromClass(classMirror)[#id] == null && _isCiclical(obj, instMirror)) {
      result['hashcode'] = obj.hashCode;
    }

    _serializedStack[obj] = result;
  } else {
    result = _serializedStack[obj];
  }

  _serLog.fine("Serialization completed.");
  return result;
}

/**
 * Checks the DeclarationMirror [variable] for annotations and adds
 * the value to the [result] map. If there's no [Property] annotation 
 * with a different name set it will use the name of [symbol].
 */
void _pushField(Symbol symbol, DeclarationMirror variable, InstanceMirror instMirror, Map<String, dynamic> result, var depth) {

  String fieldName = MirrorSystem.getName(symbol);
  if (fieldName.isEmpty) return;

  InstanceMirror field = instMirror.getField(symbol);
  Object value = field.reflectee;
  _serLog.finer("Start serializing field: ${fieldName}");

  // check if there is a DartsonProperty annotation
  Property prop = new GetValueOfAnnotation<Property>().fromDeclaration(variable);
  _serLog.finest("Property Annotation: ${prop}");

  if (prop != null && prop.name != null) {
    _serLog.finer("Field renamed to: ${prop.name}");
    fieldName = prop.name;
  }

  if (depth is List) {
    depth = depth.firstWhere((e) => //
    e == fieldName || e is Map && e.keys.contains(fieldName), orElse: () => null);
  }

  if (depth is Map) depth = depth[fieldName];

  _serLog.finer("depth: $depth");

  //If the value is not null and the annotation @ignore is not on variable declaration
  if (value != null && !new IsAnnotation<_Ignore>().onDeclaration(variable)) {

    _serLog.finer("Serializing field: ${fieldName}");

//    bool isNotCiclical = isSuperPrimitive(value) || !new IsAnnotation<Ciclical>().onInstance(field);
    if (depth != null || !_isCiclical(value, field)) {
      result[fieldName] = objectToSerializable(value, depth: depth is List || depth is Map ? depth : null);
//      if (getPublicVariablesFromClass(field.type)[#id] == null && !isNotCiclical) {
//        result[fieldName]['hashcode'] = field.reflectee.hashCode;
//      }
    } else {
      if (getPublicVariablesFromClass(field.type)[#id] != null) {
        var _aux;
        result[fieldName] = {
          //TODO REPLACE FOR: 'id': field.getField(#id).reflectee ?? -field.reflectee.hashCode
          'id': (_aux = field.getField(#id).reflectee) != null ? _aux : -field.reflectee.hashCode
        };
      } else {
        result[fieldName] = {
          'hashcode': field.reflectee.hashCode
        };
      }

    }
  }
}

_isCiclical(value, InstanceMirror im) => !isSuperPrimitive(value) && new IsAnnotation<Cyclical>().onInstance(im);
