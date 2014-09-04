part of drails;

/**
 * Annotation that tells parser to ignore a variable or getter
 */
const ignore = const _Ignore();

class _Ignore {
  const _Ignore();
}

/**
 * Function used to get if the variable should be ignored
 */
typedef bool IgnoreIfFunction({var user, var orig_val, var current_val});

/**
 * Annotation that tells parser to ignore the variable if the [ignoreIfFunction] returns true
 */
class IgnoreIf {
  final IgnoreIfFunction ignoreIfFunction;
  const IgnoreIf(this.ignoreIfFunction);
}

/**
 * Annotation class to describe properties of a class member.
 */
class Property {
  final String name;
  
  const Property(this.name);
  
  String toString() => "DartsonProperty: Name: ${name}";
}

