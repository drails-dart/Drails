part of drails;

/**
 * Annotation which indicates that a method parameter should be bound to a web
 * request body.
 */
const RequestBody = const _RequestBody();

class _RequestBody {
  const _RequestBody();
}



const requestParam = const RequestParam();

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
const post = const Post();

class Post extends _Path{
  const Post([String url]) : super(url);
}

class Get extends _Path {
  const Get(String url) : super(url);
}

class _Path {
  const _Path([this.url]);

  final String url;
}
