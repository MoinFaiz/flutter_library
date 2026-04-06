import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({String? message}) : super(message ?? 'Server error occurred');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String? message}) : super(message ?? 'No internet connection');
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String? message}) : super(message ?? 'Authentication failed');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({String? message}) : super(message ?? 'Resource not found');
}

class PermissionFailure extends Failure {
  const PermissionFailure({String? message}) : super(message ?? 'Permission denied');
}
