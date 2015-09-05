part of drails;


String ENV = 'dev';

/// Instance of the current running server, useful to stop the server.
HttpServer DRAILS_SERVER;

/// Specifies the URI used to get the main html file
String CLIENT_URL = 'index.html';

/// Map that mantains the list of URI that could be used to serve files
Map<String, String> CLIENT_DIR = {
  'dev': '/../web/',
  'prod': '/../build/web/'
};

Map<String, bool> ENABLE_CORS = {
  'dev': true,
  'prod': false
};
