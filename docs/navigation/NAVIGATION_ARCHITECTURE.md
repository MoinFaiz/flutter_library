# Navigation Architecture Documentation

## Overview

This document outlines the navigation architecture for the Flutter Library application following clean architecture principles and modular design.

## Navigation Structure

### Main Navigation Flow

```
App Launch
    ↓
MainNavigationScaffold (Bottom Navigation)
    ├── Home Tab (Index 0)
    ├── Add Book (Index 1 - Navigates to separate page)
    └── Library Tab (Index 2)
```

### Secondary Navigation

```
Home Page
    ├── Search → Stay on Home
    ├── Favorites → Navigate to FavoritesPage
    └── Book Tap → Navigate to BookDetailsPage

Library Page
    └── Settings → Navigate to SettingsPage

Any Page
    └── Book Tap → Navigate to BookDetailsPage
```

## Architecture Components

### 1. Core Navigation Layer

- **`NavigationService`** - Interface defining navigation contracts
- **`NavigationServiceImpl`** - Implementation using Flutter Navigator
- **`AppRoutes`** - Route definitions and constants
- **`RouteGenerator`** - Route handling and page creation

### 2. Navigation Service Interface

```dart
abstract class NavigationService {
  Future<T?> navigateTo<T>(String routeName, {Object? arguments});
  Future<T?> navigateToAndReplace<T>(String routeName, {Object? arguments});
  Future<T?> navigateToAndClearStack<T>(String routeName, {Object? arguments});
  void goBack<T>([T? result]);
  bool canGoBack();
  String? getCurrentRouteName();
  Future<T?> showDialogCustom<T>({required Widget child, bool barrierDismissible});
  Future<T?> showBottomSheetCustom<T>({required Widget child, bool isScrollControlled});
}
```

### 3. Route Definitions

```dart
class AppRoutes {
  static const String main = '/';
  static const String home = '/home';
  static const String addBook = '/add-book';
  static const String library = '/library';
  static const String favorites = '/favorites';
  static const String bookDetails = '/book-details';
  static const String settings = '/settings';
}
```

## Navigation Patterns

### 1. Bottom Navigation Behavior

- **Home & Library**: Stay within the scaffold (IndexedStack)
- **Add Book**: Navigate to a separate page with back button

### 2. Secondary Navigation

- **Push Navigation**: Used for pages that should have back buttons
  - Favorites page
  - Book details page
  - Settings page
  - Add book page

### 3. Page-Specific Navigation

- **Home Page**: 
  - Search stays on the same page
  - Favorites button navigates to FavoritesPage
  - Book taps navigate to BookDetailsPage

- **Library Page**:
  - Settings button navigates to SettingsPage
  - No back button (tab-based navigation)

## Dependency Injection

### Navigation Service Registration

```dart
// In injection_container.dart
sl.registerLazySingleton<NavigationService>(
  () => NavigationServiceImpl(),
);
```

### Usage in Components

```dart
class MyPage extends StatelessWidget {
  final NavigationService _navigationService = sl<NavigationService>();
  
  void _navigateToDetails() {
    _navigationService.navigateTo(AppRoutes.bookDetails, arguments: book);
  }
}
```

## BLoC Provider Management

### Route-Level Providers

Pages that require BLoC providers are wrapped at the route level:

```dart
case AppRoutes.favorites:
  return _buildRoute(
    BlocProvider(
      create: (context) => sl<FavoritesBloc>(),
      child: const FavoritesPage(),
    ),
    settings,
  );
```

### Feature-Level Providers

Some features maintain their own providers:

```dart
// HomePageProvider wraps HomePage with HomeBloc
class HomePageProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HomeBloc>(),
      child: const HomePage(),
    );
  }
}
```

## Benefits

### 1. Modularity
- Each feature manages its own navigation logic
- Navigation service can be easily mocked for testing
- Clean separation of concerns

### 2. Maintainability
- Centralized route management
- Type-safe navigation with route constants
- Easy to add new routes and navigation patterns

### 3. Testability
- Navigation service interface allows for easy mocking
- Individual components can be tested in isolation
- Navigation logic is separated from UI logic

### 4. Scalability
- Easy to add new navigation patterns
- Support for complex navigation flows
- Flexible provider management

## Best Practices

### 1. Navigation Helpers

Create navigation helpers for complex navigation:

```dart
class BookDetailsNavigation {
  static Future<void> navigateToBookDetails(BuildContext context, Book book) {
    final NavigationService navigationService = sl<NavigationService>();
    return navigationService.navigateTo(AppRoutes.bookDetails, arguments: book);
  }
}
```

### 2. Error Handling

Route generator includes error handling for missing routes:

```dart
default:
  return _buildErrorRoute('Route not found', settings);
```

### 3. Argument Validation

Routes validate their arguments:

```dart
case AppRoutes.bookDetails:
  if (args is Book) {
    return _buildRoute(_BookDetailsPlaceholder(book: args), settings);
  }
  return _buildErrorRoute('Book data is required', settings);
```

## Future Enhancements

### 1. Deep Linking
- Support for URL-based navigation
- Handle external app links

### 2. Navigation Analytics
- Track navigation patterns
- Monitor user flows

### 3. Advanced Navigation
- Tab-based navigation within features
- Nested navigation stacks
- Custom transition animations

## Migration Guide

### From Direct Navigation

**Before:**
```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (context) => SomePage()),
);
```

**After:**
```dart
final NavigationService navigationService = sl<NavigationService>();
navigationService.navigateTo(AppRoutes.somePage);
```

### From MaterialApp.routes

**Before:**
```dart
MaterialApp(
  routes: {
    '/home': (context) => HomePage(),
    '/details': (context) => DetailsPage(),
  },
);
```

**After:**
```dart
MaterialApp(
  navigatorKey: NavigationServiceImpl.navigatorKey,
  initialRoute: AppRoutes.main,
  onGenerateRoute: RouteGenerator.generateRoute,
);
```

This navigation architecture provides a solid foundation for the Flutter Library application, ensuring maintainability, testability, and scalability as the application grows.
