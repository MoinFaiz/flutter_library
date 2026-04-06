# Flutter Library App - Design System Best Practices Guide

## Overview

This guide establishes best practices for maintaining design consistency, ensuring optimal theming, and following architectural principles throughout the Flutter Library app.

---

## 1. SPACING & LAYOUT BEST PRACTICES

### The 8pt Grid System

The app uses an 8-point base unit. All spacing should be multiples of 8:

```
2pt = spaceXxs    (8 × 0.25)
4pt = spaceXs     (8 × 0.5)
8pt = spaceSm     (8 × 1.0)
12pt = spaceSm_Plus (8 × 1.5)
16pt = spaceMd    (8 × 2.0)
24pt = spaceLg    (8 × 3.0)
32pt = spaceXl    (8 × 4.0)
40pt = space2Xl   (8 × 5.0)
48pt = space3Xl   (8 × 6.0)
```

### ✅ Correct Usage Examples

```dart
// Single spacing values
Padding(
  padding: const EdgeInsets.all(AppDimensions.spaceMd),
  child: child,
)

// Asymmetric spacing
Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: AppDimensions.spaceLg,
    vertical: AppDimensions.spaceMd,
  ),
  child: child,
)

// Sized boxes for vertical spacing
const SizedBox(height: AppDimensions.spaceMd)

// Sized boxes for horizontal spacing
const SizedBox(width: AppDimensions.spaceLg)

// Border radius
BorderRadius.circular(AppDimensions.radiusMd)

// Icon sizing
Icon(
  Icons.home,
  size: AppDimensions.iconMd,
)

// List/Grid spacing
GridView(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: AppDimensions.gridColumns,
    mainAxisSpacing: AppDimensions.gridSpacing,
    crossAxisSpacing: AppDimensions.gridSpacing,
  ),
)
```

### ❌ Incorrect Usage (AVOID)

```dart
// ❌ Hardcoded values
Padding(
  padding: const EdgeInsets.all(16),  // Use AppDimensions.spaceMd
  child: child,
)

// ❌ Magic numbers
const SizedBox(height: 24)  // Use AppDimensions.spaceLg

// ❌ Direct calculations at build time
const SizedBox(height: AppDimensions.spaceMd * 2)  // Should be a constant

// ❌ Inconsistent units
Padding(
  padding: const EdgeInsets.all(15.0),  // Not a multiple of 8
  child: child,
)

// ❌ Font sizes as hardcoded
Text(
  'Hello',
  style: TextStyle(fontSize: 16.0),  // Use AppTypography
)
```

---

## 2. COLOR & THEME BEST PRACTICES

### ✅ Correct Usage Examples

```dart
// Use theme colors
Container(
  color: Theme.of(context).colorScheme.primary,
)

// Use semantic colors
Icon(
  Icons.favorite,
  color: AppColors.favoriteColor,
)

// Use color with alpha from theme
Container(
  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
)

// Use appropriate semantic color for status
Container(
  color: book.isAvailable ? AppColors.success : AppColors.error,
)

// Text color from theme
Text(
  'Hello',
  style: TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)
```

### ❌ Incorrect Usage (AVOID)

```dart
// ❌ Hardcoded hex colors
Container(
  color: Color(0xFF2196F3),  // Use Theme.of(context).colorScheme.primary
)

// ❌ Ignoring theme in color selection
Text(
  'Hello',
  style: TextStyle(
    color: Colors.black,  // Breaks in dark mode
  ),
)

// ❌ Inconsistent semantic colors
Icon(
  Icons.error,
  color: Color(0xFFFF0000),  // Use AppColors.error or theme
)

// ❌ Magic alpha values
Container(
  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.37),
)

// ❌ Color override on themed component
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,  // Already defined in AppComponentStyles
  ),
  child: Text('Button'),
)
```

---

## 3. TYPOGRAPHY BEST PRACTICES

### ✅ Correct Usage Examples

```dart
// Use defined text themes
Text(
  'Heading',
  style: Theme.of(context).textTheme.headlineSmall,
)

// Use typography constants for custom styles
Text(
  'Custom Text',
  style: AppTypography.bodyMedium.copyWith(
    color: Theme.of(context).colorScheme.primary,
  ),
)

// Create semantic text styles
Text(
  'Book Title',
  style: AppTypography.bookTitle.copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)

// Use labelSmall for badges/chips
Chip(
  label: Text(
    'Fiction',
    style: Theme.of(context).textTheme.labelSmall,
  ),
)
```

### ❌ Incorrect Usage (AVOID)

```dart
// ❌ Hardcoded font size
Text(
  'Hello',
  style: TextStyle(
    fontSize: 16.0,  // Use AppTypography or theme
    fontWeight: FontWeight.w600,
  ),
)

// ❌ Hardcoded color in text
Text(
  'Error',
  style: TextStyle(
    color: Colors.red,  // Use AppColors.error or theme
  ),
)

// ❌ Inconsistent font family
Text(
  'Hello',
  style: TextStyle(
    fontFamily: 'CustomFont',  // Use AppTypography.primaryFontFamily
  ),
)

// ❌ Ignoring line height
Text(
  'Paragraph',
  style: TextStyle(
    fontSize: 16.0,
    // Missing height for proper line spacing
  ),
)
```

---

## 4. COMPONENT STYLING BEST PRACTICES

### ✅ Correct Usage Examples

```dart
// Use predefined button styles
ElevatedButton(
  onPressed: () {},
  child: Text('Submit'),
)

// Use card theme from AppTheme
Card(
  child: Padding(
    padding: const EdgeInsets.all(AppDimensions.spaceMd),
    child: child,
  ),
)

// Use icon theme
Icon(
  Icons.home,
  color: Theme.of(context).iconTheme.color,
)

// Use input decoration theme
TextField(
  decoration: InputDecoration(
    hintText: 'Enter text',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
    ),
  ),
)

// Use chip theme
Chip(
  label: Text('Tag'),
)
```

### ❌ Incorrect Usage (AVOID)

```dart
// ❌ Custom button styling without using AppComponentStyles
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Text('Submit'),
)

// ❌ Creating custom card styling
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,  // Should use Card widget with theme
    borderRadius: BorderRadius.circular(12),
    boxShadow: [...],
  ),
)

// ❌ Hardcoded icon properties
Icon(
  Icons.favorite,
  size: 24,  // Use AppDimensions.iconMd
  color: Colors.red,  // Use AppColors.favoriteColor
)
```

---

## 5. RESPONSIVE DESIGN BEST PRACTICES

### ✅ Correct Usage Examples

```dart
// Import responsive utilities
import 'package:flutter_library/core/utils/responsive_utils.dart';

// Use responsive spacing
Widget build(BuildContext context) {
  final padding = ResponsiveUtils.getResponsiveSpacing(context);
  
  return Padding(
    padding: EdgeInsets.all(padding),
    child: child,
  );
}

// Check for device type
if (MediaQuery.of(context).size.width >= AppDimensions.tabletBreakpoint) {
  // Tablet/Desktop layout
} else {
  // Mobile layout
}

// Use responsive font sizes
Text(
  'Title',
  style: TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(context),
  ),
)

// Use FittedBox for flexible sizing
FittedBox(
  child: Text('Flexible text'),
)
```

### ❌ Incorrect Usage (AVOID)

```dart
// ❌ Hardcoded responsive logic
if (MediaQuery.of(context).size.width > 600) {
  // Not using defined breakpoints
}

// ❌ Ignoring different screen sizes
SizedBox(
  width: 300,  // Fixed width won't work on all screens
  child: child,
)

// ❌ No consideration for orientation
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(16),  // Should be responsive
    child: child,
  );
}

// ❌ Assuming specific device sizes
if (MediaQuery.of(context).size.width == 375) {
  // Hardcoded for one device
}
```

---

## 6. STATE MANAGEMENT BEST PRACTICES

### ✅ Correct Usage Examples

```dart
// Use BLoC with proper events
BlocBuilder<BookBloc, BookState>(
  builder: (context, state) {
    if (state is BookLoading) {
      return const EnhancedLoadingIndicator();
    } else if (state is BookLoaded) {
      return BookListWidget(books: state.books);
    } else if (state is BookError) {
      return ErrorWidget(error: state.message);
    }
    return const SizedBox.shrink();
  },
)

// Use BlocListener for side effects
BlocListener<BookBloc, BookState>(
  listener: (context, state) {
    if (state is BookError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: child,
)

// Inject dependencies properly
context.read<BookBloc>().add(LoadBooksEvent());
```

### ❌ Incorrect Usage (AVOID)

```dart
// ❌ Ignoring states
BlocBuilder<BookBloc, BookState>(
  builder: (context, state) {
    if (state is BookLoaded) {
      return BookListWidget(books: state.books);
    }
    return SizedBox.shrink();
  },
)

// ❌ Mixing BlocListener with BlocBuilder
BlocBuilder<BookBloc, BookState>(
  builder: (context, state) {
    if (state is BookError) {
      // Showing errors in builder instead of listener
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  },
)

// ❌ Not handling loading state
// Leads to poor UX with frozen UI
```

---

## 7. ERROR HANDLING BEST PRACTICES

### ✅ Correct Usage Examples

```dart
// Use custom exceptions
class BookException implements Exception {
  final String message;
  BookException(this.message);
}

// Handle errors in BLoC
try {
  final books = await repository.getBooks();
} catch (e) {
  emit(BookError(e.toString()));
}

// Show user-friendly error messages
if (state is BookError) {
  return ErrorWidget(
    title: 'Failed to load books',
    message: state.message,
    onRetry: () => context.read<BookBloc>().add(LoadBooksEvent()),
  );
}

// Log errors appropriately
logger.error('Book loading failed: $error');
```

### ❌ Incorrect Usage (AVOID)

```dart
// ❌ Exposing raw errors to users
Text('Error: SocketException: OS Error')

// ❌ Silent failures
try {
  final books = await repository.getBooks();
} catch (e) {
  // Error ignored, UI frozen
}

// ❌ Inconsistent error handling
// Different approach in different screens
```

---

## 8. TESTING BEST PRACTICES

### ✅ Correct Testing Approach

```dart
// Test theme consistency
void main() {
  test('should have consistent spacing', () {
    expect(AppDimensions.spaceMd, equals(16.0));
    expect(AppDimensions.spaceSm, equals(8.0));
  });

  test('should have light and dark variants', () {
    expect(AppTheme.lightTheme.brightness, equals(Brightness.light));
    expect(AppTheme.darkTheme.brightness, equals(Brightness.dark));
  });
}

// Test widget rendering with theme
testWidgets('widget should render with theme colors', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: MyWidget(),
      ),
    ),
  );
  
  expect(find.byType(MyWidget), findsOneWidget);
});

// Test responsiveness
testWidgets('widget should be responsive', (tester) async {
  addTearDown(tester.binding.window.physicalSizeTestValue);
  
  tester.binding.window.physicalSizeTestValue = const Size(400, 800);
  addTearDown(addTearDown);
  
  await tester.pumpWidget(MyApp());
  expect(find.byType(MobileLayout), findsOneWidget);
});
```

---

## 9. DOCUMENTATION BEST PRACTICES

### ✅ Correct Documentation

```dart
/// Widget for displaying a book card with cover image and title.
/// 
/// This widget uses the theme-based design system to ensure consistency
/// across light and dark modes.
/// 
/// Parameters:
///   - [book]: The book data to display
///   - [onTap]: Callback when the card is tapped
///   - [showRating]: Whether to show the rating (default: true)
/// 
/// Example:
/// ```dart
/// BookCard(
///   book: myBook,
///   onTap: () => Navigator.pushNamed(context, '/book-details'),
///   showRating: true,
/// )
/// ```
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool showRating;
  
  const BookCard({
    required this.book,
    this.onTap,
    this.showRating = true,
  });
  
  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

### ❌ Incorrect Documentation

```dart
// ❌ Missing documentation
class BookCard extends StatelessWidget {
  final Book book;
  // ...
}

// ❌ Incomplete documentation
/// This is a card widget.
class BookCard extends StatelessWidget {
  // ...
}
```

---

## 10. CHECKLIST FOR NEW FEATURES

Before adding any new UI component:

- [ ] **Spacing**: Using AppDimensions for all spacing
- [ ] **Colors**: Using theme colors, not hardcoded hex values
- [ ] **Typography**: Using AppTypography or theme text styles
- [ ] **Components**: Using standardized AppComponentStyles
- [ ] **Theme**: Works in both light and dark modes
- [ ] **Responsive**: Tested on multiple screen sizes
- [ ] **Accessibility**: Touch targets >= 48dp, good contrast
- [ ] **Error States**: Proper error handling and UI feedback
- [ ] **Loading States**: Shows loading indicator, not frozen
- [ ] **Empty States**: Clear empty state with CTA
- [ ] **Tested**: Unit and widget tests included
- [ ] **Documented**: Code and usage examples documented

---

## 11. COMMON MISTAKES & FIXES

| Issue | ❌ Wrong | ✅ Correct |
|-------|---------|-----------|
| Spacing | `SizedBox(height: 16)` | `SizedBox(height: AppDimensions.spaceMd)` |
| Colors | `Color(0xFF2196F3)` | `Theme.of(context).colorScheme.primary` |
| Font Size | `fontSize: 16.0` | `style: AppTypography.bodyMedium` |
| Border Radius | `BorderRadius.circular(8)` | `BorderRadius.circular(AppDimensions.radiusSm)` |
| Button Style | Custom `styleFrom` | Use `AppComponentStyles` |
| Icon Size | `size: 24` | `size: AppDimensions.iconMd` |
| Padding | `padding: EdgeInsets.all(16)` | `padding: const EdgeInsets.all(AppDimensions.spaceMd)` |
| Text Color | `color: Colors.black` | `color: Theme.of(context).colorScheme.onSurface` |

---

## 12. PERFORMANCE CONSIDERATIONS

### ✅ Good Practices

- Use const constructors where possible
- Cache expensive computations
- Use const for dimension/color values
- Implement proper image caching
- Use ListView/GridView.builder for large lists

### ❌ Avoid

- Rebuilding entire trees
- Non-const widgets without reason
- Unoptimized images
- Overlapping paint operations

---

## Resources & References

1. **Material Design 3**: https://m3.material.io/
2. **Flutter Best Practices**: https://flutter.dev/docs/testing/best-practices
3. **Responsive Design**: https://flutter.dev/docs/development/ui/layout/responsive
4. **State Management**: https://bloclibrary.dev/

---

## Summary

By following these best practices, you'll ensure:

✅ **Consistency** - Uniform appearance across the app  
✅ **Maintainability** - Easy to update and modify  
✅ **Scalability** - Simple to add new features  
✅ **Accessibility** - Works for all users  
✅ **Performance** - Fast and smooth experience  
✅ **Theming** - Seamless light/dark mode switching

---

**Last Updated:** November 5, 2025  
**Status:** Active Guidelines
