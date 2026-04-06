/// Enum for age appropriateness classification
enum AgeAppropriateness {
  children('Children (0-12)'),
  youngAdult('Young Adult (13-17)'),
  adult('Adult (18+)'),
  allAges('All Ages');

  const AgeAppropriateness(this.displayName);
  final String displayName;
}
