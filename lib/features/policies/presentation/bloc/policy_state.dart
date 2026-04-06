import '../../domain/entities/policy.dart';

/// Policy state
abstract class PolicyState {}

/// Initial state
class PolicyInitial extends PolicyState {}

/// Loading state
class PolicyLoading extends PolicyState {}

/// Loaded state
class PolicyLoaded extends PolicyState {
  final Policy policy;
  
  PolicyLoaded(this.policy);
}

/// Error state
class PolicyError extends PolicyState {
  final String message;
  
  PolicyError(this.message);
}
