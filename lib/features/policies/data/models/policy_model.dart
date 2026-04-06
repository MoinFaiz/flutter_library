import '../../domain/entities/policy.dart';

/// Policy model for data layer
class PolicyModel extends Policy {
  const PolicyModel({
    required super.id,
    required super.title,
    required super.content,
    required super.lastUpdated,
    required super.version,
  });

  /// Create PolicyModel from JSON
  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      version: json['version'] as String,
    );
  }

  /// Convert PolicyModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'lastUpdated': lastUpdated.toIso8601String(),
      'version': version,
    };
  }

  /// Convert to domain entity
  Policy toEntity() {
    return Policy(
      id: id,
      title: title,
      content: content,
      lastUpdated: lastUpdated,
      version: version,
    );
  }

  /// Create PolicyModel from domain entity
  factory PolicyModel.fromEntity(Policy policy) {
    return PolicyModel(
      id: policy.id,
      title: policy.title,
      content: policy.content,
      lastUpdated: policy.lastUpdated,
      version: policy.version,
    );
  }
}
