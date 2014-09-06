part of drails;

/**
 * Function that allow us to authorize the access to user with specified Roles in annotation
 */
bool authorizeRoles(user, [AuthorizeRoles me, List methodArguments]) => 
    user.roles.any((role) => 
        me.roles.any((meRole) => 
            meRole == role));
  

/**
 * Annotation that Defines what roles are allowed to execute the controller method
 */
class AuthorizeRoles implements AuthorizeIf {
  final List<String> roles;
  final AuthorizeFunc authorizeFunc;
  const AuthorizeRoles(this.roles, [this.authorizeFunc = authorizeRoles]);
}

bool denyRoles(user, [AuthorizeIf me, List methodArguments]) => !authorizeRoles(user, me, methodArguments);
  
/**
 * Annotation that Defines what roles are denied to execute the controller method
 */
class DenyRoles implements AuthorizeIf {
  final List<String> roles;
  final AuthorizeFunc authorizeFunc;
  
  const DenyRoles(this.roles, [this.authorizeFunc = denyRoles]);
}

/**
 * Function that is used to authorize access if the result is true
 */
typedef bool AuthorizeFunc(user, [AuthorizeIf me, List methodArguments]);

/**
 * Annotation that Defines what roles are allowed to execute the controller method
 */
class AuthorizeIf {
  final AuthorizeFunc authorizeFunc;
  
  const AuthorizeIf(this.authorizeFunc);
}
