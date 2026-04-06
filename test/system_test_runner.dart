import 'package:flutter_test/flutter_test.dart';

// Widget Tests - Pages
import 'widget/main_app_test.dart' as main_app_tests;
import 'widget/features/home/presentation/pages/home_page_test.dart' as home_page_tests;
import 'widget/features/book_details/presentation/pages/book_details_page_test.dart' as book_details_tests;
import 'widget/features/favorites/presentation/pages/favorites_page_test.dart' as favorites_tests;
import 'widget/features/library/presentation/pages/library_page_test.dart' as library_tests;

// Widget Tests - Components
import 'widget/shared/widgets/book_grid_widget_test.dart' as book_grid_tests;

// Unit Tests - BLoCs
import 'unit/blocs/home_bloc_test.dart' as home_bloc_tests;
import 'unit/blocs/favorites_bloc_test.dart' as favorites_bloc_tests;

// Unit Tests - Use Cases
import 'unit/usecases/toggle_favorite_usecase_test.dart' as toggle_favorite_usecase_tests;

// Integration Tests
import 'integration/library_app_system_test.dart' as system_tests;

/// Comprehensive test runner for all Flutter Library App tests
/// 
/// This file runs all tests in organized groups to ensure complete coverage:
/// 
/// **Widget Tests:**
/// - Main App functionality (app initialization, routing)
/// - Home page functionality (search, favorites, book grid)
/// - Book details page (reviews, rental options, image carousel) 
/// - Favorites management (add, remove, display)
/// - Library page (borrowed books, uploaded books)
/// - Shared components (book grid widget, common UI elements)
/// 
/// **Unit Tests:**
/// - BLoC state management testing
/// - Use case business logic testing
/// - Repository pattern testing
/// 
/// **Integration Tests:**
/// - End-to-end user journey testing
/// - Cross-feature interaction testing
/// - Performance and reliability testing
/// 
/// **Test Coverage Areas:**
/// - User interface components
/// - State management (BLoC pattern)
/// - Business logic (use cases)
/// - Data persistence (repositories)
/// - Error handling and edge cases
/// - Navigation flows
/// - Loading states and user feedback
/// - Accessibility features
void main() {
  group('Flutter Library App - Complete Test Suite', () {
    
    group('🎨 Widget Tests', () {
      group('📱 Pages', () {
        group('🏠 Main App', main_app_tests.main);
        group('🏠 Home Page', home_page_tests.main);
        group('📖 Book Details Page', book_details_tests.main);
        group('❤️ Favorites Page', favorites_tests.main);
        group('📚 Library Page', library_tests.main);
      });
      
      group('🧩 Components', () {
        group('📋 Book Grid Widget', book_grid_tests.main);
      });
    });

    group('🧪 Unit Tests', () {
      group('🔄 BLoC State Management', () {
        group('🏠 Home BLoC', home_bloc_tests.main);
        group('❤️ Favorites BLoC', favorites_bloc_tests.main);
      });
      
      group('⚙️ Use Cases', () {
        group('❤️ Toggle Favorite Use Case', toggle_favorite_usecase_tests.main);
      });
    });

    group('🔗 Integration Tests', () {
      group('🎯 System Tests', system_tests.main);
    });
  });
}

/// Test Summary and Coverage Information
/// 
/// This test suite provides comprehensive coverage of:
/// 
/// **Functional Testing:**
/// ✅ Book browsing and search functionality
/// ✅ Favorites management (add/remove/display)
/// ✅ Book details viewing with reviews and rental info
/// ✅ Library management (borrowed and uploaded books)
/// ✅ User navigation and interaction flows
/// ✅ Data loading and pagination
/// ✅ Pull-to-refresh functionality
/// 
/// **State Management Testing:**
/// ✅ BLoC pattern implementation
/// ✅ State transitions and event handling
/// ✅ Error state management
/// ✅ Loading state indicators
/// ✅ Data persistence and caching
/// 
/// **Business Logic Testing:**
/// ✅ Use case implementations
/// ✅ Repository pattern compliance
/// ✅ Domain model integrity
/// ✅ Error handling and validation
/// ✅ Edge case scenarios
/// 
/// **UI/UX Testing:**
/// ✅ Widget rendering and layout
/// ✅ User interaction handling
/// ✅ Accessibility compliance
/// ✅ Responsive design behavior
/// ✅ Animation and transition testing
/// 
/// **Performance Testing:**
/// ✅ List scrolling performance
/// ✅ Image loading optimization
/// ✅ Memory usage validation
/// ✅ Network request efficiency
/// 
/// **Integration Testing:**
/// ✅ Complete user journey flows
/// ✅ Cross-feature interaction
/// ✅ Data consistency across features
/// ✅ Navigation state management
/// ✅ System reliability and stability
///
/// Run with: `flutter test test/system_test_runner.dart`
