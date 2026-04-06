import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/policy_model.dart';

/// Local data source for policies
abstract class PolicyLocalDataSource {
  /// Get cached policy
  Future<PolicyModel?> getCachedPolicy(String policyId);
  
  /// Cache a policy
  Future<void> cachePolicy(PolicyModel policy);
  
  /// Clear all cached policies
  Future<void> clearCache();
  
  /// Check if cache is expired
  Future<bool> isCacheExpired(String policyId);
}

/// Implementation of local data source
class PolicyLocalDataSourceImpl implements PolicyLocalDataSource {
  static const String _cachePrefix = 'policy_cache_';
  static const String _timestampPrefix = 'policy_timestamp_';
  static const Duration _cacheExpiry = Duration(days: 7); // Cache for 7 days
  
  @override
  Future<PolicyModel?> getCachedPolicy(String policyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('$_cachePrefix$policyId');
      
      if (cachedData != null) {
        final json = jsonDecode(cachedData) as Map<String, dynamic>;
        return PolicyModel.fromJson(json);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> cachePolicy(PolicyModel policy) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(policy.toJson());
      
      await prefs.setString('$_cachePrefix${policy.id}', jsonData);
      await prefs.setInt('$_timestampPrefix${policy.id}', 
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Handle cache errors silently
    }
  }
  
  @override
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys()
          .where((key) => key.startsWith(_cachePrefix) || 
                         key.startsWith(_timestampPrefix))
          .toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      // Handle errors silently
    }
  }
  
  @override
  Future<bool> isCacheExpired(String policyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('$_timestampPrefix$policyId');
      
      if (timestamp == null) {
        return true;
      }
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) > _cacheExpiry;
    } catch (e) {
      return true;
    }
  }
}
