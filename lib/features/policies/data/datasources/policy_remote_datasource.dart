import '../models/policy_model.dart';

/// Remote data source for policies
abstract class PolicyRemoteDataSource {
  /// Fetch policy from server
  Future<PolicyModel> getPolicy(String policyId);
}

/// Implementation of remote data source
class PolicyRemoteDataSourceImpl implements PolicyRemoteDataSource {
  // This would typically use an HTTP client
  // For now, we'll simulate with static data
  
  // Static date to ensure consistency in tests
  static final DateTime _baseDate = DateTime(2025, 6, 21, 11, 42, 23);
  
  @override
  Future<PolicyModel> getPolicy(String policyId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return mock data based on policy ID
    return PolicyModel.fromJson(_getMockPolicyData(policyId));
  }
  
  Map<String, dynamic> _getMockPolicyData(String policyId) {
    
    switch (policyId) {
      case 'privacy':
        return {
          'id': 'privacy',
          'title': 'Privacy Policy',
          'content': _getPrivacyPolicyContent(),
          'lastUpdated': _baseDate.toIso8601String(),
          'version': '1.2.0',
        };
      case 'terms':
        return {
          'id': 'terms',
          'title': 'Terms & Conditions',
          'content': _getTermsConditionsContent(),
          'lastUpdated': _baseDate.toIso8601String(),
          'version': '1.1.0',
        };
      case 'shipping':
        return {
          'id': 'shipping',
          'title': 'Shipping & Delivery Policy',
          'content': _getShippingPolicyContent(),
          'lastUpdated': _baseDate.toIso8601String(),
          'version': '1.0.0',
        };
      case 'cancellation':
        return {
          'id': 'cancellation',
          'title': 'Cancellation & Refund Policy',
          'content': _getCancellationPolicyContent(),
          'lastUpdated': _baseDate.toIso8601String(),
          'version': '1.0.0',
        };
      default:
        // Return a fallback policy for unknown IDs instead of throwing
        return {
          'id': policyId, // Use the original policyId as-is (including empty string)
          'title': 'Policy Not Found',
          'content': _getFallbackPolicyContent(),
          'lastUpdated': _baseDate.toIso8601String(),
          'version': '1.0.0',
        };
    }
  }
  
  String _getPrivacyPolicyContent() {
    return '''
# Privacy Policy

## 1. Information We Collect

We collect information you provide directly to us, such as:

- Account information (name, email, phone number)
- Profile information (reading preferences, favorite genres)
- Payment information (billing address, payment method details)
- Communication data (customer service interactions)
- User-generated content (reviews, ratings, comments)

We also automatically collect device and usage information when you use our app.

## 2. How We Use Your Information

We use the information we collect to:

- Provide and maintain our services
- Process transactions and send confirmations
- Send you technical notices and security alerts
- Respond to your comments and questions
- Provide customer service and support
- Personalize your experience and content recommendations
- Analyze usage patterns to improve our services
- Comply with legal obligations

## 3. Information Sharing

We may share your information in the following situations:

- With service providers who assist in our operations
- To comply with legal obligations or government requests
- To protect our rights, privacy, safety, or property
- In connection with a business transfer or acquisition
- With your consent or at your direction

We do not sell, trade, or rent your personal information to third parties for marketing purposes.

## 4. Data Security

We implement appropriate security measures to protect your personal information:

- Encryption of data in transit and at rest
- Secure servers and databases
- Regular security audits and updates
- Limited access to personal information
- Employee training on data protection

However, no internet transmission is 100% secure, and we cannot guarantee absolute security.

## 5. Contact Us

If you have questions about this Privacy Policy:

**Email:** privacy@flutterlibrary.com  
**Phone:** +1 (555) 123-4567  
**Address:** Privacy Officer, 123 Library Street, Book City, BC 12345
''';
  }
  
  String _getTermsConditionsContent() {
    return '''
# Terms & Conditions

## 1. Acceptance of Terms

By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.

## 2. Use License

Permission is granted to temporarily download one copy of the materials on Flutter Library's application for personal, non-commercial transitory viewing only.

## 3. Disclaimer

The materials on Flutter Library's application are provided on an 'as is' basis. Flutter Library makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.

## 4. Limitations

In no event shall Flutter Library or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Flutter Library's application.

## 5. Account Terms

- You must be 13 years or older to use this service
- You must provide accurate and complete information
- You are responsible for maintaining account security
- You may not use the service for illegal purposes

## 6. Contact Information

For questions about these Terms & Conditions:

**Email:** legal@flutterlibrary.com  
**Phone:** +1 (555) 123-4567
''';
  }
  
  String _getShippingPolicyContent() {
    return '''
# Shipping & Delivery Policy

## 1. Shipping Methods

We offer the following shipping options:

### Standard Shipping
- **Delivery Time:** 5-7 business days
- **Cost:** Free for orders over \$25, otherwise \$4.99
- **Tracking:** Provided via email

### Express Shipping
- **Delivery Time:** 2-3 business days
- **Cost:** \$9.99
- **Tracking:** Real-time tracking available

### Overnight Shipping
- **Delivery Time:** 1 business day
- **Cost:** \$19.99
- **Tracking:** Real-time tracking with SMS updates

## 2. Processing Time

- Orders are processed within 1-2 business days
- Processing time is not included in shipping time
- Orders placed on weekends are processed on Monday

## 3. Shipping Restrictions

We currently ship to:
- United States (all 50 states)
- Canada
- Select international locations

## 4. Damaged or Lost Packages

- Report damaged packages within 48 hours
- We will replace or refund damaged items
- Lost packages will be investigated with carrier

## 5. Contact Us

For shipping inquiries:

**Email:** shipping@flutterlibrary.com  
**Phone:** +1 (555) 123-4567
''';
  }
  
  String _getCancellationPolicyContent() {
    return '''
# Cancellation & Refund Policy

## 1. Order Cancellation

### Before Shipping
- Orders can be cancelled free of charge before shipping
- Contact us immediately to cancel your order
- Refunds will be processed within 3-5 business days

### After Shipping
- Orders cannot be cancelled once shipped
- Please refer to our return policy below

## 2. Return Policy

### Digital Products
- Digital books and content are non-refundable
- Exceptions made for technical issues

### Physical Books
- **Return Window:** 30 days from delivery
- **Condition:** Books must be in original condition
- **Return Shipping:** Customer pays return shipping costs

## 3. Refund Process

1. Contact customer service to initiate return
2. Receive return authorization and instructions
3. Ship item back using provided label
4. Refund processed within 5-7 business days after receipt

## 4. Non-Refundable Items

- Digital downloads after access
- Personalized or customized items
- Items damaged by misuse

## 5. Exchanges

- We offer exchanges for defective items
- Size exchanges available for merchandise
- Must be initiated within 30 days

## 6. Contact Us

For cancellations and refunds:

**Email:** returns@flutterlibrary.com  
**Phone:** +1 (555) 123-4567  
**Hours:** Monday-Friday, 9 AM - 6 PM EST
''';
  }
  
  String _getFallbackPolicyContent() {
    return '''
# Policy Not Available

We apologize, but the requested policy document is currently not available.

## What you can do:

1. **Contact Support**: Reach out to our customer service team for assistance
2. **Check Back Later**: This document may be temporarily unavailable
3. **Browse Available Policies**: Visit our policy center for other documents

## Contact Information

**Email:** support@flutterlibrary.com  
**Phone:** +1 (555) 123-4567  
**Hours:** Monday-Friday, 9 AM - 6 PM EST

We appreciate your understanding and will work to resolve this issue promptly.
''';
  }
}
