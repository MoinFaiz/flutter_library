/// Enum representing different reasons for removing a book copy
enum RemovalReason {
  sold('Book copy has been sold'),
  donated('Book copy has been donated'),
  damaged('Book copy is damaged beyond repair'),
  noLongerAvailable('No longer want to sell/rent'),
  duplicate('Duplicate entry'),
  other('Other reason');

  const RemovalReason(this.displayName);
  
  /// Human-readable display name for the removal reason
  final String displayName;
}
