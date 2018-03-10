part of drails;

/**
 * Annotation which indicates that a method parameter should be bound to a web
 * request body.
 */
const RequestBody = const _RequestBody();

class _RequestBody extends Annotation {
  const _RequestBody();
}


const requestParam = const RequestParam();

/**
 * Annotation that indicates that a method parameter should be bound to a web
 * request parameter.
 */
class RequestParam extends Annotation {
  final String paramName;

  const RequestParam({this.paramName: ""});
}

/// This annotation indicates the controller path.
class Path extends Annotation {
  const Path([this.url]);

  final String url;
}

/// This annotation indicates that the controller method or global function should be mapped to a
/// GET request being the url the name of the method.
const Get GET = const Get();

/// This annotation indicates that the controller method or global function should be mapped to a
/// GET request being the url the name of the method or the value passed to [url] parameter.
class Get extends Path {
  const Get([String url]) : super(url);
}

/// This annotation indicates that the controller method or global function should be mapped to a
/// POST request being the url the name of the method.
const Post POST = const Post();

/// This annotation indicates that the controller method or global function should be mapped to a
/// POST request being the url the name of the method or the value passed to [url] parameter.
class Post extends Path {
  const Post([String url]) : super(url);
}

/// This annotation indicates that the controller method or global function should be mapped to a
/// PUT request being the url the name of the method.
const Put PUT = const Put();

/// This annotation indicates that the controller method or global function should be mapped to a
/// PUT request being the url the name of the method or the value passed to [url] parameter.
class Put extends Path {
  const Put([String url]) : super(url);
}

/// This annotation indicates that the controller method or global function should be mapped to a
/// DELETE request being the url the name of the method.
const Delete DELETE = const Delete();

/// This annotation indicates that the controller method or global function should be mapped to a
/// DELETE request being the url the name of the method or the value passed to [url] parameter.
class Delete extends Path {
  const Delete([String url]) : super(url);
}
