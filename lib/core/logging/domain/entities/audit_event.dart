import 'package:equatable/equatable.dart';

/// Represents a user action for audit tracking
class AuditEvent extends Equatable {
  final String id;
  final DateTime timestamp;
  final String? userId;
  final String? sessionId;
  final String feature;
  final String action;
  final Map<String, dynamic>? parameters;
  final bool success;

  const AuditEvent({
    required this.id,
    required this.timestamp,
    this.userId,
    this.sessionId,
    required this.feature,
    required this.action,
    this.parameters,
    this.success = true,
  });

  @override
  List<Object?> get props => [
        id,
        timestamp,
        userId,
        sessionId,
        feature,
        action,
        parameters,
        success,
      ];
}
