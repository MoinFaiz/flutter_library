# App Bar Usage Guidelines

## Tab vs. Route Distinction

### **Tab Pages (No AppBar)**
These pages are displayed in the bottom navigation's IndexedStack:
- **HomePage** - Tab index 0
- **LibraryPage** - Tab index 1

### **Route Pages (Use AppBar)**
These pages are accessed via navigation routes:
- **AddBookPage** - Route: `/add-book` (opened from Add button)
- **FavoritesPage** - Route: `/favorites`
- **BookDetailsPage** - Route: `/book-details` (custom SliverAppBar)
- **SettingsPage** - Route: `/settings`

## Standard Pattern (Use for most pages)

For most pages, use Flutter's standard `AppBar`:

```dart
appBar: AppBar(
  title: const Text('Page Title'),
  // Flutter automatically handles back button
  actions: [
    // Optional action buttons
  ],
),
```

### Examples:
- **AddBookPage**: Standard AppBar with reset action + automatic back button
- **FavoritesPage**: Simple title with automatic back button
- **SettingsPage**: Simple title with automatic back button

## No AppBar Pattern (Use for main tabs)

For pages that open as tabs in bottom navigation, don't use AppBar:

```dart
body: SafeArea(
  child: Column(
    children: [
      // Custom header if needed
      _buildHeader(context),
      // Page content
      Expanded(child: content),
    ],
  ),
),
```

### Examples:
- **HomePage**: Custom search header (no AppBar)
- **LibraryPage**: No header, just content (no AppBar)

## Custom Pattern (Use only when needed)

### BookDetailsAppBar (SliverAppBar)
This is the **only** page that uses a custom app bar because:
1. **Expandable image carousel**: Shows book images in a collapsible header
2. **Scroll integration**: Works with CustomScrollView for smooth scrolling
3. **Rich visual experience**: Essential for book detail UX

```dart
// Used in CustomScrollView
CustomScrollView(
  slivers: [
    BookDetailsAppBar(
      book: book,
      onBack: () => Navigator.of(context).pop(),
      onFavoriteToggle: () => _toggleFavorite(book.id),
    ),
    SliverToBoxAdapter(child: content),
  ],
)
```

## Benefits of This Approach

1. **Consistency**: All pages use standard AppBar except where truly needed
2. **Simplicity**: Flutter handles back button logic automatically  
3. **Maintainability**: Standard patterns are easier to update
4. **User Experience**: Consistent navigation behavior across the app

## Migration Complete

✅ **FavoritesPage**: Now uses standard AppBar (removed manual back button)
✅ **SettingsPage**: Already uses standard AppBar
✅ **AddBookPage**: Now uses standard AppBar (changed from tab to route)
✅ **HomePage**: Already uses custom header (no AppBar for tab navigation)
✅ **LibraryPage**: Now has no header (removed header, no AppBar for tab navigation)
✅ **BookDetailsPage**: Documented why custom SliverAppBar is needed
✅ **CommonAppBar**: Removed unused wrapper class - use standard AppBar instead

The app now has consistent app bar usage across all pages using Flutter's standard AppBar!
