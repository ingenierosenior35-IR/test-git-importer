abstract class Failure {
  final String message;
  
  Failure(this.message);
}

// General failures
class ServerFailure extends Failure {
  ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network error occurred']) : super(message);
}

// Auth failures
class AuthFailure extends Failure {
  AuthFailure([String message = 'Authentication failed']) : super(message);
}

class InvalidCredentialsFailure extends Failure {
  InvalidCredentialsFailure([String message = 'Invalid credentials']) : super(message);
}

class UserNotFoundFailure extends Failure {
  UserNotFoundFailure([String message = 'User not found']) : super(message);
}
