/// Policy entity representing a policy document
class Policy {
  final String id;
  final String title;
  final String content;
  final DateTime lastUpdated;
  final String version;

  const Policy({
    required this.id,
    required this.title,
    required this.content,
    required this.lastUpdated,
    required this.version,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Policy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          lastUpdated == other.lastUpdated &&
          version == other.version;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      lastUpdated.hashCode ^
      version.hashCode;

  @override
  String toString() {
    return 'Policy{id: $id, title: $title, lastUpdated: $lastUpdated, version: $version}';
  }
}
