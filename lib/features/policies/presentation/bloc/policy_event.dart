/// Policy events
abstract class PolicyEvent {}

/// Load policy event
class LoadPolicy extends PolicyEvent {
  final String policyId;
  
  LoadPolicy(this.policyId);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadPolicy &&
          runtimeType == other.runtimeType &&
          policyId == other.policyId;
  
  @override
  int get hashCode => policyId.hashCode;
}

/// Refresh policy event
class RefreshPolicy extends PolicyEvent {
  final String policyId;
  
  RefreshPolicy(this.policyId);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshPolicy &&
          runtimeType == other.runtimeType &&
          policyId == other.policyId;
  
  @override
  int get hashCode => policyId.hashCode;
}
