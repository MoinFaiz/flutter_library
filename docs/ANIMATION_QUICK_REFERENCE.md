# 🎨 Animation & Micro-interaction Quick Reference

## Animation Constants Reference

### Curves
```dart
// lib/core/constants/app_constants.dart

static const Curve standardCurve = Curves.easeInOut;  // Balanced animations
static const Curve bouncyCurve = Curves.elasticOut;   // Playful, springy
static const Curve smoothCurve = Curves.ease;         // Gentle, smooth
static const Curve snappyCurve = Curves.easeOutCubic; // Responsive, sharp
```

### Durations
```dart
static const Duration shortDuration = Duration(milliseconds: 200);
static const Duration mediumDuration = Duration(milliseconds: 300);
static const Duration longDuration = Duration(milliseconds: 500);
static const Duration fabAnimationDuration = Duration(milliseconds: 250);
static const Duration buttonPressAnimationDuration = Duration(milliseconds: 100);
static const Duration cardHoverAnimationDuration = Duration(milliseconds: 150);
static const Duration loadingIndicatorDuration = Duration(milliseconds: 1500);
```

### Settings
```dart
static const bool enableHapticFeedback = true;
static const double shadowElevation = 4.0;
static const double subtleShadowElevation = 2.0;
```

---

## Loading Indicators Usage

### Full-Featured Loading (EnhancedLoadingIndicator)
```dart
EnhancedLoadingIndicator(
  message: 'Loading books...',
  subtitle: 'Fetching from library',
  color: Colors.blue,
  showBackground: true,
  duration: AppConstants.loadingIndicatorDuration,
)
```

### Compact Loading (CompactLoadingIndicator)
```dart
CompactLoadingIndicator(
  size: 24.0,
  strokeWidth: 2.5,
  color: Theme.of(context).colorScheme.primary,
)
```

### Skeleton Placeholder (SkeletonLoadingIndicator)
```dart
SkeletonLoadingIndicator(
  width: 100,
  height: 150,
  borderRadius: 8,
  showShimmer: true,
)
```

### Loading Wrapper (LoadingStateWrapper)
```dart
LoadingStateWrapper(
  isLoading: _isLoading,
  loadingMessage: 'Loading your books...',
  showBlur: true,
  child: BookGrid(books: _books),
)
```

---

## Button Micro-interactions

### Enhanced Button (with press/hover feedback)
```dart
ElevatedButton(
  style: AppComponentStyles.enhancedButtonStyle,
  onPressed: () {},
  child: Text('Click Me'),
)
```

**Features:**
- Press animation (elevation: 0.0)
- Hover animation (elevation: 8.0)
- Smooth color overlay transitions

### Card Interaction Button
```dart
OutlinedButton(
  style: AppComponentStyles.cardInteractionStyle,
  onPressed: () {},
  child: Text('Action'),
)
```

**Features:**
- Subtle border animation
- Minimal hover effects
- Perfect for cards

---

## Error & Empty States

### Error Widget
```dart
AppErrorWidget(
  message: 'Connection Failed',
  subtitle: 'Check your internet and try again',
  icon: Icons.wifi_off,
  errorColor: Colors.red,
  actionLabel: 'Retry',
  onRetry: _retry,
)
```

### Empty State Widget
```dart
AppEmptyStateWidget(
  title: 'No Books Yet',
  description: 'Start by adding books to your library',
  icon: Icons.library_books,
  actionLabel: 'Add Book',
  onAction: _addBook,
)
```

---

## Spacing Constants (from AppDimensions)

```dart
// Theme-based spacing
static const double spaceXxs = 2.0;
static const double spaceXs = 4.0;
static const double spaceSm = 8.0;
static const double spaceSm_Plus = 12.0;
static const double spaceMd = 16.0;
static const double spaceLg = 24.0;
static const double spaceXl = 32.0;
static const double spaceXxl = 48.0;
```

---

## Extension Methods (from AppComponentExtensions)

### Padding Extensions
```dart
widget
  .withPaddingSmall()      // 8dp padding
  .withPaddingMedium()     // 16dp padding
  .withPaddingLarge()      // 24dp padding
  .withPaddingHorizontal() // 16dp horizontal
  .withPaddingVertical()   // 16dp vertical
```

### Spacing Extensions
```dart
widget
  .withSpaceSmall()   // 8dp space
  .withSpaceMedium()  // 16dp space
  .withSpaceLarge()   // 24dp space
  .withSpaceX()       // Custom space
```

### Decoration Extensions
```dart
container
  .withCardDecoration()      // Standard card
  .withShadowSmall()         // Subtle shadow
  .withShadowMedium()        // Medium shadow
  .withBorderRadius8()       // Rounded corners
```

---

## Best Practices

### Animation Guidelines
- ✅ Use `standardCurve` for most animations
- ✅ Use `bouncyCurve` for playful interactions
- ✅ Keep animations under 500ms
- ✅ Use appropriate duration for feedback type

### Button Interactions
- ✅ Always provide visual feedback
- ✅ Use elevation changes for depth
- ✅ Keep press animations under 100ms
- ✅ Use `enhancedButtonStyle` for primary actions

### Loading States
- ✅ Show message for operations > 1 second
- ✅ Use `LoadingStateWrapper` for content
- ✅ Allow cancellation when possible
- ✅ Provide error recovery option

### Empty States
- ✅ Always show friendly messaging
- ✅ Include action to resolve state
- ✅ Use appropriate icon
- ✅ Offer helpful suggestions

---

## Performance Tips

### Animations
```dart
// ✅ Good: Reuse animation controller
if (!_animationController.isAnimating) {
  _animationController.forward();
}

// ✅ Good: Dispose properly
@override
void dispose() {
  _animationController.dispose();
  super.dispose();
}
```

### Loading Indicators
```dart
// ✅ Good: Use compact version for small spaces
// ✅ Good: Cache skeleton dimensions
// ✅ Good: Cleanup animation on dispose
```

---

## Color Usage with Themes

### In Light Theme
- Primary: Vibrant blue
- Secondary: Soft purple
- Error: Coral red

### In Dark Theme
- Primary: Bright cyan
- Secondary: Light purple
- Error: Light coral

---

## Integration Examples

### Complete Loading Flow
```dart
class BooksPage extends StatefulWidget {
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  bool _isLoading = true;
  List<Book> _books = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _books = await _repository.getBooks();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading
    if (_isLoading && _books.isEmpty) {
      return EnhancedLoadingIndicator(
        message: 'Loading your books...',
      );
    }

    // Show error
    if (_error != null && _books.isEmpty) {
      return AppErrorWidget(
        message: 'Failed to load books',
        actionLabel: 'Retry',
        onRetry: _loadBooks,
      );
    }

    // Show empty
    if (_books.isEmpty) {
      return AppEmptyStateWidget(
        title: 'No Books Yet',
        actionLabel: 'Add Book',
        onAction: () => _navigateToAdd(),
      );
    }

    // Show content with pull-to-refresh
    return RefreshIndicator(
      onRefresh: _loadBooks,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.spaceMd,
          mainAxisSpacing: AppDimensions.spaceMd,
        ),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          return BookCard(book: _books[index]);
        },
      ),
    );
  }
}
```

---

## Common Patterns

### Pattern 1: Async Button
```dart
ElevatedButton(
  style: AppComponentStyles.enhancedButtonStyle,
  onPressed: _isLoading ? null : () => _performAction(),
  child: _isLoading
    ? CompactLoadingIndicator()
    : Text('Submit'),
)
```

### Pattern 2: Interactive Card
```dart
GestureDetector(
  onTap: () => _onCardTap(),
  child: Container(
    decoration: AppComponentStyles.interactiveCardDecoration,
    child: BookTile(book: book),
  ),
)
```

### Pattern 3: Error Recovery
```dart
if (_error != null)
  AppErrorWidget(
    message: _error!,
    actionLabel: 'Retry',
    onRetry: _retryOperation,
  )
else
  MainContent(),
```

---

**Reference Date:** November 5, 2025  
**Last Updated:** Phase 3 Completion  
**Status:** ✅ Current & Active
