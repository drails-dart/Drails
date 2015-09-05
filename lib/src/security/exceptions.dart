part of drails;

class NoAuthorizedError extends StateError {
  NoAuthorizedError() : super('The user is not authorized');
}