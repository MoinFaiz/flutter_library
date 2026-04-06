# Book Components Documentation

This document describes the individual UI components for book-related functionality in the Flutter Library app. Each component is located in the `lib/shared/widgets/` directory and is now in its own file for better maintainability and organization.

## Components

### 1. **RatingDisplay** (`rating_display.dart`)
Displays a book's rating with a star icon and numerical value.

**Props:**
- `rating` (double): The rating value to display
- `iconSize` (double): Size of the star icon
- `iconColor` (Color?): Custom color for the star icon
- `textStyle` (TextStyle?): Custom text style for the rating
- `alignment` (MainAxisAlignment): How to align the rating within its container

**Usage:**
```dart
RatingDisplay(
  rating: 4.5,
  iconSize: 16,
  iconColor: Colors.amber,
)
```

### 2. **FavoriteButton** (`favorite_button.dart`)
Heart-shaped button for toggling favorite status.

**Props:**
- `isFavorite` (bool): Whether the item is currently favorited
- `onPressed` (VoidCallback?): Callback when button is pressed
- `iconSize` (double): Size of the heart icon
- `activeColor` (Color?): Color when favorited
- `inactiveColor` (Color?): Color when not favorited
- `showBackground` (bool): Whether to show circular background
- `backgroundColor` (Color?): Background color when showing background

**Usage:**
```dart
FavoriteButton(
  isFavorite: book.isFavorite,
  onPressed: () => onToggleFavorite(book),
  showBackground: true,
)
```

### 3. **BookCoverImage** (`book_cover_image.dart`)
Displays book cover images with loading states, error handling, and timeout management.

**Props:**
- `imageUrl` (String): URL of the book cover image
- `width` (double?): Width of the image container
- `height` (double?): Height of the image container
- `fit` (BoxFit): How the image should fit within its container
- `placeholder` (Widget?): Custom loading placeholder
- `errorWidget` (Widget?): Custom error widget
- `loadingTimeout` (Duration): Timeout for loading images

**Usage:**
```dart
BookCoverImage(
  imageUrl: book.imageUrl,
  width: 120,
  height: 160,
  fit: BoxFit.cover,
)
```

### 4. **PriceDisplay** (`price_display.dart`)
Displays book prices with support for discounts and different currencies.

**Props:**
- `price` (double): Original price
- `discountPrice` (double?): Discounted price (if applicable)
- `originalPriceStyle` (TextStyle?): Style for original price text
- `discountPriceStyle` (TextStyle?): Style for discount price text
- `currency` (String): Currency symbol (defaults to '$')

**Usage:**
```dart
PriceDisplay(
  price: 29.99,
  discountPrice: 19.99,
  currency: '\$',
)
```

### 5. **BookImageCarousel** (`book_image_carousel.dart`)
Displays multiple book images in a swipeable carousel with page indicators.

**Props:**
- `imageUrls` (List<String>): List of image URLs
- `width` (double?): Width of the carousel
- `height` (double?): Height of the carousel
- `showIndicators` (bool): Whether to show page indicators

**Usage:**
```dart
BookImageCarousel(
  imageUrls: book.imageUrls,
  width: 200,
  height: 300,
  showIndicators: true,
)
```

### 6. **BookGenreDisplay** (`book_genre_display.dart`)
Displays book genres as text or chips with optional limits.

**Props:**
- `genres` (List<String>): List of genre names
- `maxGenres` (int?): Maximum number of genres to display
- `showAsChips` (bool): Whether to display as chips or comma-separated text

**Usage:**
```dart
BookGenreDisplay(
  genres: book.genres,
  maxGenres: 3,
  showAsChips: true,
)
```

## Import Usage

### Individual Components
```dart
import 'package:flutter_library/shared/widgets/rating_display.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
```

### Barrel Import (Recommended)
```dart
import 'package:flutter_library/shared/widgets/book_components.dart';
```

## Migration from Old Files

The old files `book_components.dart` and `book_ui_components.dart` have been removed. All components are now available as individual files in the `lib/shared/widgets/` directory.

### Before:
```dart
import 'package:flutter_library/shared/widgets/book_components.dart';
```

### After:
```dart
import 'package:flutter_library/shared/widgets/book_components.dart';
```

## Benefits of New Structure

1. **Better Maintainability**: Each component is in its own file, making it easier to find and modify
2. **Improved Tree-Shaking**: Import only the components you need
3. **Better Testing**: Each component can be tested independently
4. **Cleaner Codebase**: Smaller, focused files are easier to understand
5. **Easier Collaboration**: Multiple developers can work on different components simultaneously

## Component Dependencies

All components are designed to be as independent as possible, with minimal dependencies on other components. When dependencies exist, they are clearly imported at the top of each file.

## Styling

Components use the app's theme system and can be customized through props or by overriding theme values. All components respect the current theme's color scheme and typography.
