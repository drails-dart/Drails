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
 * Annotation which indicates that a method parameter should be bound to a web
 * request parameter.
 */
class RequestParam {
  final String paramName;
  const RequestParam({this.paramName: ""});
}

/**
 * Annotation that Defines what roles are allowed to execute the controller method
 */
class AuthorizeRoles {
  final List<String> roles;
  
  const AuthorizeRoles(this.roles);
}
/**
 * Annotation that Defines what roles are denied to execute the controller method
 */
class DenyRoles {
  final List<String> roles;
  
  const DenyRoles(this.roles);
}

/**
 * Function that is used to authorize access if the result is true
 */
typedef bool AuthorizeFunc(user, [List methodArguments]);

/**
 * Annotation that Defines what roles are allowed to execute the controller method
 */
class AuthorizeIf {
  final AuthorizeFunc preAuthorizeFunc;
  
  const AuthorizeIf(this.preAuthorizeFunc);
}
