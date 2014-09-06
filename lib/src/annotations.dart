part of drails;

/**
 * Annotation that indicates that the variable is going to be injected 
 * using the Type as reference
 */
const autowired = const _Autowired();

class _Autowired {
  const _Autowired();
}

const requestParam = const RequestParam();

/**
 * Annotation which indicates that a method parameter should be bound to a web
 * request body.
 */
const RequestBody = const _RequestBody();

class _RequestBody {
  const _RequestBody();
}

/**
 * Annotation that indicates that a method parameter should be bound to a web
 * request parameter.
 */
class RequestParam {
  final String paramName;
  const RequestParam({this.paramName: ""});
}

/**
 * Annotation that indicates that the controller method should be mapped to a 
 * POST request
 */
const Post = const _Post();

class _Post {
  const _Post();
}
