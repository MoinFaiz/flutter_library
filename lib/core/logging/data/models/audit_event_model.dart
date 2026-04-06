import '../../domain/entities/audit_event.dart';

class AuditEventModel {
  final String id;
  final String timestamp;
  final String? userId;
  final String? sessionId;
  final String feature;
  final String action;
  final Map<String, dynamic>? parameters;
  final bool success;

  const AuditEventModel({
    required this.id,
    required this.timestamp,
    this.userId,
    this.sessionId,
    required this.feature,
    required this.action,
    this.parameters,
    required this.success,
  });

  factory AuditEventModel.fromEntity(AuditEvent entity) {
    return AuditEventModel(
      id: entity.id,
      timestamp: entity.timestamp.toIso8601String(),
      userId: entity.userId,
      sessionId: entity.sessionId,
      feature: entity.feature,
      action: entity.action,
      parameters: entity.parameters,
      success: entity.success,
    );
  }

  factory AuditEventModel.fromJson(Map<String, dynamic> json) {
    return AuditEventModel(
      id: json['id'] as String,
      timestamp: json['timestamp'] as String,
      userId: json['user_id'] as String?,
      sessionId: json['session_id'] as String?,
      feature: json['feature'] as String,
      action: json['action'] as String,
      parameters: json['parameters'] as Map<String, dynamic>?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      'feature': feature,
      'action': action,
      if (parameters != null) 'parameters': parameters,
      'success': success,
    };
  }

  AuditEvent toEntity() {
    return AuditEvent(
      id: id,
      timestamp: DateTime.parse(timestamp),
      userId: userId,
      sessionId: sessionId,
      feature: feature,
      action: action,
      parameters: parameters,
      success: success,
    );
  }
}
