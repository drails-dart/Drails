part of drails;

/**
 * Function that is used to authorize access if the result is true
 */
typedef bool IsAuthorized(user, AuthorizeIf me);

/**
 * Annotation that Defines what roles are allowed to execute the controller method
 */
class AuthorizeIf extends Annotation {
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
  final IsAuthorized isAuthorized = authorizeRoles;

  const AuthorizeRoles(this.roles);
}

///Function that deny access to users that don't have the specified roles
bool denyRoles(user, AuthorizeIf me) =>
    !authorizeRoles(user, me);

/**
 * Annotation that Defines what roles are denied to execute the controller method
 */
class DenyRoles extends AuthorizeRoles {
  final IsAuthorized isAuthorized = denyRoles;

  const DenyRoles(List<String> roles) : super(roles);
}
