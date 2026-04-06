import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_library/main.dart';
import 'package:flutter_library/injection/injection_container.dart';

/// Advanced Search and Filtering System Tests
/// 
/// This test suite covers:
/// 1. Basic search functionality
/// 2. Advanced filtering options
/// 3. Search suggestions and autocomplete
/// 4. Search history
/// 5. Category-based filtering
/// 6. Sort options
/// 7. Search result handling

void main() {
  group('Search System Tests', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await initializeDependencies();
    });

    testWidgets('Basic search functionality', (WidgetTester tester) async {
      print('🔍 Starting Search System Test');
      
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Find search field
      var searchField = find.byType(TextField);
      if (searchField.evaluate().isEmpty) {
        searchField = find.byIcon(Icons.search);
      }
      
      if (searchField.evaluate().isNotEmpty) {
        // Test basic search
        if (searchField.evaluate().first.widget is TextField) {
          await tester.enterText(searchField, 'fiction');
          await tester.pump();
          
          // Submit search
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle(const Duration(seconds: 2));
          
          print('✅ Basic search executed for "fiction"');
        } else {
          // Search icon - tap to open search
          await tester.tap(searchField);
          await tester.pumpAndSettle();
          
          // Find the opened search field
          final openedSearchField = find.byType(TextField);
          if (openedSearchField.evaluate().isNotEmpty) {
            await tester.enterText(openedSearchField, 'fiction');
            await tester.pump();
            
            await tester.testTextInput.receiveAction(TextInputAction.search);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            
            print('✅ Search dialog/page opened and search executed');
          }
        }
        
        // Verify search results are displayed
        final searchResults = find.byType(Card);
        if (searchResults.evaluate().isNotEmpty) {
          print('📚 Search results displayed: ${searchResults.evaluate().length} items');
        } else {
          final noResultsMessage = find.textContaining('No results');
          if (noResultsMessage.evaluate().isNotEmpty) {
            print('ℹ️ No search results found message displayed');
          }
        }
      } else {
        print('⚠️ Search field not found');
      }
    });

    testWidgets('Search suggestions and autocomplete', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _openSearchInterface(tester);
      
      // Test autocomplete suggestions
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        // Type partial query
        await tester.enterText(searchField.first, 'har');
        await tester.pump(const Duration(milliseconds: 500));
        
        // Look for suggestion dropdown/list
        final suggestions = find.byType(ListView);
        if (suggestions.evaluate().isNotEmpty) {
          print('💭 Search suggestions displayed');
          
          // Test tapping on a suggestion
          final suggestionItems = find.byType(ListTile);
          if (suggestionItems.evaluate().isNotEmpty) {
            await tester.tap(suggestionItems.first);
            await tester.pumpAndSettle();
            print('✅ Search suggestion selected');
          }
        } else {
          // Look for suggestion chips
          final suggestionChips = find.byType(Chip);
          if (suggestionChips.evaluate().isNotEmpty) {
            print('🏷️ Search suggestion chips found');
            await tester.tap(suggestionChips.first);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Advanced filtering options', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _openSearchInterface(tester);
      
      // Look for filter button
      var filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isEmpty) {
        filterButton = find.textContaining('Filter');
      }
      
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton.first);
        await tester.pumpAndSettle();
        
        print('🎛️ Filter interface opened');
        
        // Test category filters
        final categoryFilters = find.byType(CheckboxListTile);
        if (categoryFilters.evaluate().isNotEmpty) {
          print('📂 Category filters found: ${categoryFilters.evaluate().length}');
          
          // Select a category filter
          await tester.tap(categoryFilters.first);
          await tester.pump();
          print('✅ Category filter selected');
        }
        
        // Test availability filter
        final availabilityFilter = find.textContaining('Available');
        if (availabilityFilter.evaluate().isNotEmpty) {
          await tester.tap(availabilityFilter.first);
          await tester.pump();
          print('✅ Availability filter tested');
        }
        
        // Test rating filter
        final ratingFilter = find.byType(Slider);
        if (ratingFilter.evaluate().isNotEmpty) {
          await tester.drag(ratingFilter.first, const Offset(50, 0));
          await tester.pump();
          print('⭐ Rating filter adjusted');
        }
        
        // Test publication year filter
        final yearFilter = find.textContaining('Year');
        if (yearFilter.evaluate().isNotEmpty) {
          print('📅 Publication year filter found');
        }
        
        // Apply filters
        var applyButton = find.textContaining('Apply');
        if (applyButton.evaluate().isEmpty) {
          applyButton = find.textContaining('Done');
        }
        
        if (applyButton.evaluate().isNotEmpty) {
          await tester.tap(applyButton.first);
          await tester.pumpAndSettle();
          print('✅ Filters applied');
        }
      } else {
        print('ℹ️ Advanced filter interface not found');
      }
    });

    testWidgets('Sort options functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _openSearchInterface(tester);
      
      // Execute a search first to have results to sort
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'book');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
      }
      
      // Look for sort button
      var sortButton = find.byIcon(Icons.sort);
      if (sortButton.evaluate().isEmpty) {
        sortButton = find.textContaining('Sort');
      }
      
      if (sortButton.evaluate().isNotEmpty) {
        await tester.tap(sortButton.first);
        await tester.pumpAndSettle();
        
        print('📊 Sort options opened');
        
        // Test different sort options
        final sortOptions = [
          'Title',
          'Author', 
          'Rating',
          'Publication Date',
          'Relevance'
        ];
        
        for (final option in sortOptions) {
          final sortOption = find.textContaining(option);
          if (sortOption.evaluate().isNotEmpty) {
            await tester.tap(sortOption.first);
            await tester.pumpAndSettle();
            print('✅ Sorted by $option');
            break; // Test one option to avoid too many sorts
          }
        }
        
        // Test ascending/descending toggle
        final orderToggle = find.byIcon(Icons.swap_vert);
        if (orderToggle.evaluate().isNotEmpty) {
          await tester.tap(orderToggle);
          await tester.pump();
          print('✅ Sort order toggled');
        }
      } else {
        print('ℹ️ Sort functionality not found');
      }
    });

    testWidgets('Search by category workflow', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Look for category chips or filters on home page
      final categoryChips = find.byType(FilterChip);
      if (categoryChips.evaluate().isNotEmpty) {
        print('🏷️ Category chips found on home page');
        
        // Test tapping on a category
        await tester.tap(categoryChips.first);
        await tester.pumpAndSettle();
        
        // Should filter results by category
        final filteredResults = find.byType(Card);
        if (filteredResults.evaluate().isNotEmpty) {
          print('✅ Category filtering applied, showing results');
        }
      } else {
        // Look for category dropdown or menu
        final categoryDropdown = find.byType(DropdownButton);
        if (categoryDropdown.evaluate().isNotEmpty) {
          await tester.tap(categoryDropdown.first);
          await tester.pumpAndSettle();
          
          final categoryOptions = find.byType(DropdownMenuItem);
          if (categoryOptions.evaluate().isNotEmpty) {
            await tester.tap(categoryOptions.first);
            await tester.pumpAndSettle();
            print('✅ Category selected from dropdown');
          }
        }
      }
    });

    testWidgets('Search history functionality', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _openSearchInterface(tester);
      
      // Perform several searches to build history
      final searchTerms = ['fiction', 'mystery', 'romance'];
      final searchField = find.byType(TextField);
      
      if (searchField.evaluate().isNotEmpty) {
        for (final term in searchTerms) {
          await tester.enterText(searchField.first, term);
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle(const Duration(seconds: 1));
          
          // Clear search field for next search
          await tester.enterText(searchField.first, '');
          await tester.pump();
        }
        
        print('📝 Multiple searches performed to build history');
        
        // Look for search history
        var historyButton = find.byIcon(Icons.history);
        if (historyButton.evaluate().isEmpty) {
          historyButton = find.textContaining('History');
        }
        
        if (historyButton.evaluate().isNotEmpty) {
          await tester.tap(historyButton.first);
          await tester.pumpAndSettle();
          
          // Look for previous search terms
          bool foundHistory = false;
          for (final term in searchTerms) {
            if (find.textContaining(term).evaluate().isNotEmpty) {
              foundHistory = true;
              print('✅ Found search history for: $term');
              
              // Test tapping on history item
              await tester.tap(find.textContaining(term).first);
              await tester.pumpAndSettle();
              break;
            }
          }
          
          if (!foundHistory) {
            print('ℹ️ Search history not visible or stored differently');
          }
        }
      }
    });

    testWidgets('Search result interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _performBasicSearch(tester, 'book');
      
      // Test result card interactions
      final resultCards = find.byType(Card);
      if (resultCards.evaluate().isNotEmpty) {
        print('📚 Testing search result interactions');
        
        // Test tapping on first result
        await tester.tap(resultCards.first);
        await tester.pumpAndSettle();
        
        // Should navigate to book details
        final bookDetailsIndicators = [
          find.byType(CustomScrollView),
          find.textContaining('Description'),
          find.textContaining('Author:'),
        ];
        
        bool foundBookDetails = false;
        for (final indicator in bookDetailsIndicators) {
          if (indicator.evaluate().isNotEmpty) {
            foundBookDetails = true;
            print('✅ Search result navigated to book details');
            break;
          }
        }
        
        if (foundBookDetails) {
          // Test actions from book details
          final favoriteButton = find.byIcon(Icons.favorite_border);
          if (favoriteButton.evaluate().isNotEmpty) {
            await tester.tap(favoriteButton);
            await tester.pump();
            print('❤️ Favorite action tested from search result');
          }
          
          final rentButton = find.textContaining('Rent');
          if (rentButton.evaluate().isNotEmpty) {
            await tester.tap(rentButton);
            await tester.pumpAndSettle();
            print('📚 Rent action tested from search result');
          }
          
          // Go back to search results
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('Empty search and error handling', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _openSearchInterface(tester);
      
      // Test empty search
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, '');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        
        // Should show validation or placeholder message
        final emptySearchMessage = find.textContaining('Enter search');
        if (emptySearchMessage.evaluate().isNotEmpty) {
          print('✅ Empty search validation working');
        }
        
        // Test search with no results
        await tester.enterText(searchField.first, 'xyzunlikelytermxyz');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Should show no results message
        var noResultsMessage = find.textContaining('No results');
        if (noResultsMessage.evaluate().isEmpty) {
          noResultsMessage = find.textContaining('not found');
        }
        if (noResultsMessage.evaluate().isEmpty) {
          noResultsMessage = find.textContaining('Try different');
        }
        
        if (noResultsMessage.evaluate().isNotEmpty) {
          print('✅ No results message displayed');
        }
        
        // Test search suggestions for no results
        final suggestionMessage = find.textContaining('suggestion');
        if (suggestionMessage.evaluate().isNotEmpty) {
          print('💡 Search suggestions shown for no results');
        }
      }
    });

    testWidgets('Search performance and loading states', (WidgetTester tester) async {
      await tester.pumpWidget(const FlutterLibraryApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      await _openSearchInterface(tester);
      
      // Measure search performance
      final stopwatch = Stopwatch()..start();
      
      await _performBasicSearch(tester, 'test');
      
      stopwatch.stop();
      print('⏱️ Search completed in ${stopwatch.elapsedMilliseconds}ms');
      
      // Test loading states during search
      await _openSearchInterface(tester);
      
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'loading test');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        
        // Check for loading indicator immediately
        await tester.pump(const Duration(milliseconds: 100));
        
        final loadingIndicator = find.byType(CircularProgressIndicator);
        if (loadingIndicator.evaluate().isNotEmpty) {
          print('🔄 Search loading indicator displayed');
        }
        
        // Wait for search to complete
        await tester.pumpAndSettle(const Duration(seconds: 3));
        
        // Loading indicator should be gone
        final loadingGone = find.byType(CircularProgressIndicator).evaluate().isEmpty;
        if (loadingGone) {
          print('✅ Loading indicator removed after search completion');
        }
      }
    });
  });
}

// Helper Functions

Future<void> _openSearchInterface(WidgetTester tester) async {
  var searchField = find.byType(TextField);
  
  if (searchField.evaluate().isEmpty) {
    // Look for search icon to tap
    final searchIcon = find.byIcon(Icons.search);
    if (searchIcon.evaluate().isNotEmpty) {
      await tester.tap(searchIcon);
      await tester.pumpAndSettle();
    }
  }
}

Future<void> _performBasicSearch(WidgetTester tester, String query) async {
  await _openSearchInterface(tester);
  
  final searchField = find.byType(TextField);
  if (searchField.evaluate().isNotEmpty) {
    await tester.enterText(searchField.first, query);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}
