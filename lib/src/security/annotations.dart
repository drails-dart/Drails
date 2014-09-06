part of drails;

/**
 * Function that is used to authorize access if the result is true
 */
typedef bool IsAuthorized(user, AuthorizeIf me);

/**
 * Annotation that Defines what roles are allowed to execute the controller method
 */
class AuthorizeIf {
  final IsAuthorized isAuthorized;
  
  const AuthorizeIf(this.isAuthorized);
}

/**
 * Function that allow us to authorize the access to user with specified Roles in annotation
 */
bool authorizeRoles(user, AuthorizeRoles me) => 
    user.roles.any((role) => 
        me.roles.any((meRole) => 
            meRole == role));
  

/**
 * Annotation that Defines what roles are allowed to execute the controller method
 */
class AuthorizeRoles implements AuthorizeIf {
  final List<String> roles;
  final IsAuthorized isAuthorized;
  const AuthorizeRoles(this.roles, [this.isAuthorized = authorizeRoles]);
}

///Function that deny access to users that don't have the specified roelse
bool denyRoles(user, AuthorizeIf me) => !authorizeRoles(user, me);
  
/**
 * Annotation that Defines what roles are denied to execute the controller method
 */
class DenyRoles extends AuthorizeRoles {
  const DenyRoles(List<String> roles, [IsAuthorized authorizeFunc = denyRoles]) :  super(roles, authorizeFunc) ;
}