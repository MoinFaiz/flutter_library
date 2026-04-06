/// String utility extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  /// Title case conversion
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// Check if string is email
  bool get isEmail {
    if (isEmpty || contains('..') || startsWith('.') || contains('.@') || contains('@.')) {
      return false;
    }
    return RegExp(r'^[\w\-\.\+]+@([\w-]+\.)+[\w-]{2,6}$').hasMatch(this);
  }
  
  /// Check if string is phone number
  bool get isPhoneNumber {
    if (startsWith('+')) {
      // International format: +XX minimum (3 chars total)
      return RegExp(r'^\+[1-9]\d{0,14}$').hasMatch(this) && length >= 3;
    } else {
      // National format: XX minimum (2 chars total)
      return RegExp(r'^[1-9]\d{1,14}$').hasMatch(this);
    }
  }
  
  /// Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }
  
  /// Check if string is valid URL
  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      // Accept URLs with valid schemes or domain-like patterns
      if (uri.hasScheme) {
        if (uri.scheme == 'file' || uri.scheme == 'mailto') {
          return true;
        }
        return uri.hasAuthority && uri.host.isNotEmpty;
      } else {
        // Check if it looks like a domain (contains at least one dot)
        return contains('.') && !startsWith('.') && !endsWith('.');
      }
    } catch (e) {
      return false;
    }
  }
  
  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }
}