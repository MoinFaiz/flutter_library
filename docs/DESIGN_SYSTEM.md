# Flutter Library App - Design System & Theme Standards

This document outlines the comprehensive design system and theme standards for the Flutter Library App, ensuring consistent styling and user experience across all components.

## 🎨 Design System Overview

Our design system is built on the principle of **consistency, scalability, and maintainability**. It provides:

- Standardized dimensions and spacing
- Typography scales and styles  
- Color palettes for light and dark themes
- Component-specific styling guidelines
- Reusable widget components

## 📏 Spacing & Dimensions (`AppDimensions`)

### Spacing Scale (8dp base unit)
```dart
static const double spaceXs = 4.0;   // Extra small spacing
static const double spaceSm = 8.0;   // Small spacing
static const double spaceMd = 16.0;  // Medium spacing (default)
static const double spaceLg = 24.0;  // Large spacing
static const double spaceXl = 32.0;  // Extra large spacing
static const double space2Xl = 40.0; // 2x Extra large spacing
static const double space3Xl = 48.0; // 3x Extra large spacing
```

### Border Radius Scale
```dart
static const double radiusXs = 4.0;   // Subtle rounding
static const double radiusSm = 8.0;   // Input fields, small cards
static const double radiusMd = 12.0;  // Cards, buttons (default)
static const double radiusLg = 16.0;  // Large containers
static const double radiusXl = 20.0;  // Extra large containers
static const double radiusFull = 999.0; // Fully rounded (pills, circles)
```

### Icon Sizes
```dart
static const double iconXs = 16.0;   // Small icons in lists
static const double iconSm = 20.0;   // Navigation icons
static const double iconMd = 24.0;   // Default icon size
static const double iconLg = 28.0;   // Toolbar icons
static const double iconXl = 32.0;   // Large interactive icons
static const double icon2Xl = 40.0; // Feature icons
static const double icon3Xl = 48.0; // Empty state icons
```

### Component Heights
```dart
// Buttons
static const double buttonHeightSm = 36.0;  // Compact buttons
static const double buttonHeightMd = 44.0;  // Default buttons
static const double buttonHeightLg = 52.0;  // Prominent buttons

// Inputs
static const double inputHeightSm = 40.0;   // Compact inputs
static const double inputHeightMd = 48.0;   // Default inputs
static const double inputHeightLg = 56.0;   // Large inputs
```

## 🔤 Typography (`AppTypography`)

### Typography Scale
Our typography follows a modular scale with consistent line heights and letter spacing:

```dart
// Font Sizes
static const double fontSizeXs = 12.0;   // Caption text
static const double fontSizeSm = 14.0;   // Small body text
static const double fontSizeMd = 16.0;   // Default body text
static const double fontSizeLg = 18.0;   // Large body text
static const double fontSizeXl = 20.0;   // Small headings
static const double fontSize2Xl = 24.0;  // Medium headings
static const double fontSize3Xl = 30.0;  // Large headings
static const double fontSize4Xl = 36.0;  // Display text

// Font Weights
static const FontWeight light = FontWeight.w300;
static const FontWeight regular = FontWeight.w400;
static const FontWeight medium = FontWeight.w500;
static const FontWeight semibold = FontWeight.w600;
static const FontWeight bold = FontWeight.w700;
```

### Usage Examples
```dart
// Headings
Text('Page Title', style: AppTypography.heading1);
Text('Section Title', style: AppTypography.heading3);

// Body Text
Text('Description', style: AppTypography.bodyMedium);
Text('Caption', style: AppTypography.caption);

// Buttons
Text('Button Text', style: AppTypography.buttonMedium);

// Book-specific
Text('Book Title', style: AppTypography.bookTitle);
Text('Author Name', style: AppTypography.bookAuthor);
```

## 🎨 Colors (`AppColors`)

### Light Theme Colors
```dart
// Primary Colors
static const Color primaryLight = Color(0xFF2196F3);      // Main brand color
static const Color primaryVariantLight = Color(0xFF1976D2); // Darker primary

// Secondary Colors  
static const Color secondaryLight = Color(0xFFFF5722);     // Accent color
static const Color secondaryVariantLight = Color(0xFFE64A19); // Darker secondary

// Surface Colors
static const Color backgroundLight = Color(0xFFFAFAFA);    // App background
static const Color surfaceLight = Color(0xFFFFFFFF);      // Card surfaces
```

### Dark Theme Colors
```dart
// Primary Colors
static const Color primaryDark = Color(0xFF42A5F5);       // Lighter for dark mode
static const Color primaryVariantDark = Color(0xFF1976D2);

// Surface Colors
static const Color backgroundDark = Color(0xFF121212);     // Dark background
static const Color surfaceDark = Color(0xFF1E1E1E);       // Dark surfaces
```

### Semantic Colors
```dart
// Status Colors
static const Color favoriteColor = Color(0xFFE91E63);     // Hearts, favorites
static const Color ratingColor = Color(0xFFFFC107);       // Stars, ratings
static const Color success = Color(0xFF4CAF50);           // Success states
static const Color warning = Color(0xFFFF9800);           // Warning states
static const Color error = Color(0xFFB00020);             // Error states
```

## ⏱️ Animation System (`AppConstants`)

Our app includes a comprehensive animation system with standardized curves and durations for consistent, professional animations.

### Animation Curves
```dart
// Standard curve - balanced, natural feel (most animations)
static const Curve standardCurve = Curves.easeInOut;

// Bouncy curve - playful, springy interactions
static const Curve bouncyCurve = Curves.elasticOut;

// Smooth curve - gentle, subtle transitions
static const Curve smoothCurve = Curves.ease;

// Snappy curve - responsive, sharp feel
static const Curve snappyCurve = Curves.easeOutCubic;
```

### Animation Durations
```dart
// Quick animations - 200ms (standard micro-interactions)
static const Duration shortDuration = Duration(milliseconds: 200);

// Medium animations - 300ms (default transitions)
static const Duration mediumDuration = Duration(milliseconds: 300);

// Long animations - 500ms (complex transitions)
static const Duration longDuration = Duration(milliseconds: 500);

// Specific animations
static const Duration fabAnimationDuration = Duration(milliseconds: 250);
static const Duration buttonPressAnimationDuration = Duration(milliseconds: 100);
static const Duration cardHoverAnimationDuration = Duration(milliseconds: 150);
static const Duration loadingIndicatorDuration = Duration(milliseconds: 1500);
```

### Micro-interaction Settings
```dart
// Enable haptic feedback on interactions
static const bool enableHapticFeedback = true;

// Standard shadow elevation for interactive elements
static const double shadowElevation = 4.0;

// Subtle shadow elevation for softer effects
static const double subtleShadowElevation = 2.0;
```

### Animation Usage Guidelines

#### Button Press Animation
```dart
ElevatedButton(
  style: AppComponentStyles.enhancedButtonStyle,
  onPressed: () {},
  child: Text('Press Me'),
)
// Features:
// - Smooth press animation (100ms)
// - Hover effect with elevated shadow
// - Standard easeInOut curve
```

#### Card Hover Animation
```dart
OutlinedButton(
  style: AppComponentStyles.cardInteractionStyle,
  onPressed: () {},
  child: Text('Hover Card'),
)
// Features:
// - Subtle border animation
// - Minimal elevation change
// - Perfect for card interactions
```

#### Loading Indicator Animation
```dart
EnhancedLoadingIndicator(
  message: 'Loading...',
  duration: AppConstants.loadingIndicatorDuration,
)
// Features:
// - Smooth scale and fade animations
// - 1500ms rotation cycle
// - Customizable colors and size
```

---

## 🧱 Component Styles (`AppComponentStyles`)

### Button Styles

#### Primary Buttons
```dart
AppButton.primary(
  text: 'Continue',
  onPressed: () {},
  size: ButtonSize.medium,  // small, medium, large
  fullWidth: true,          // Optional full width
)
```

#### Secondary Buttons
```dart
AppButton.secondary(
  text: 'Cancel', 
  onPressed: () {},
)
```

#### Text Buttons
```dart
AppButton.text(
  text: 'Skip',
  onPressed: () {},
)
```

#### Destructive Buttons
```dart
AppButton.destructive(
  text: 'Delete',
  onPressed: () {},
)
```

### Input Fields

#### Standard Input
```dart
AppTextField(
  label: 'Email',
  hintText: 'Enter your email',
  controller: emailController,
  size: InputSize.medium,  // small, medium, large
  required: true,
)
```

#### Specialized Inputs
```dart
// Email input
AppTextField.email(
  controller: emailController,
  validator: emailValidator,
)

// Password input  
AppTextField.password(
  controller: passwordController,
)

// Multiline text area
AppTextField.multiline(
  label: 'Description',
  maxLines: 5,
  controller: descriptionController,
)
```

## 📦 Standardized Widgets

### Cards
```dart
AppCard(
  padding: EdgeInsets.all(AppDimensions.spaceMd),
  onTap: () {},  // Optional tap handler
  child: YourContent(),
)
```

### List Tiles
```dart
AppListTile(
  leading: Icon(Icons.book),
  title: Text('Book Title'),
  subtitle: Text('Author Name'),
  trailing: Icon(Icons.arrow_forward),
  onTap: () {},
)
```

### Section Headers
```dart
AppSectionHeader(
  title: 'Recent Books',
  subtitle: 'Your latest activity',
  action: TextButton(
    onPressed: () {},
    child: Text('View All'),
  ),
)
```

### Empty States
```dart
AppEmptyState(
  icon: Icon(Icons.book_outlined),
  title: 'No Books Found',
  message: 'Try adjusting your search criteria',
  action: AppButton.primary(
    text: 'Browse Books',
    onPressed: () {},
  ),
)
```

### Loading States
```dart
// Full-featured loading indicator
EnhancedLoadingIndicator(
  message: 'Loading your books...',
  subtitle: 'This may take a moment',
  showBackground: true,
  color: Colors.blue,
)

// Compact inline loading
CompactLoadingIndicator(
  size: 24.0,
  color: Theme.of(context).colorScheme.primary,
)

// Skeleton placeholder with shimmer
SkeletonLoadingIndicator(
  width: 100,
  height: 150,
  borderRadius: 8,
  showShimmer: true,
)

// Wrapping content with loading overlay
LoadingStateWrapper(
  isLoading: _isLoading,
  loadingMessage: 'Fetching...',
  child: BookGrid(books: _books),
)
```

### Error & Empty States
```dart
// Error state with retry action
AppErrorWidget(
  message: 'Connection Failed',
  subtitle: 'Please check your internet',
  icon: Icons.wifi_off,
  errorColor: Colors.red,
  actionLabel: 'Retry',
  onRetry: _retry,
)

// Empty state with action
AppEmptyStateWidget(
  title: 'No Books Yet',
  description: 'Start borrowing books to build your collection',
  icon: Icons.library_books,
  actionLabel: 'Browse Books',
  onAction: _browse,
)
```

## 🎯 Usage Guidelines

### Extension Methods (`AppComponentExtensions`)

The app provides fluent extension methods for easy widget styling:

#### Padding Extensions
```dart
// Fluent API for quick padding
widget.withPaddingSmall()      // 8dp padding all sides
widget.withPaddingMedium()     // 16dp padding all sides
widget.withPaddingLarge()      // 24dp padding all sides
widget.withPaddingHorizontal() // 16dp horizontal padding
widget.withPaddingVertical()   // 16dp vertical padding
```

#### Decoration Extensions
```dart
// Quick styling with extensions
container
  .withCardDecoration()        // Standard card styling
  .withShadowSmall()          // Subtle shadow
  .withShadowMedium()         // Medium shadow
  .withBorderRadius8()        // 8dp border radius
```

#### Spacing Extensions
```dart
// Add spacing between widgets
widget.withSpaceSmall()   // 8dp margin
widget.withSpaceMedium()  // 16dp margin
widget.withSpaceLarge()   // 24dp margin
widget.withSpaceX()       // Custom spacing
```

#### Text Spacing Extensions
```dart
// Text-specific spacing utilities
text
  .withLetterSpacing()     // Letter spacing
  .withLineHeight()        // Line height adjustment
```

### Utility Enums

#### Badge Status
```dart
// Status badges with semantic colors
BadgeStatus.success   // Green background
BadgeStatus.error     // Red background
BadgeStatus.warning   // Orange background
```

#### Shadow Elevation
```dart
// Shadow elevation levels
ShadowElevation.small   // Subtle shadows
ShadowElevation.medium  // Normal shadows
ShadowElevation.large   // Prominent shadows
```

### DO's ✅
- Use `AppDimensions` constants for all spacing and sizing
- Use `AppTypography` styles for all text elements
- Use `AppButton` variants instead of raw button widgets
- Use `AppTextField` for all input fields
- Use standardized `AppCard` for container elements
- Reference `AppColors` for all color needs
- Use `AppConstants` animation curves and durations
- Use extension methods from `AppComponentExtensions`
- Use `EnhancedLoadingIndicator` for loading states
- Use `AppErrorWidget` and `AppEmptyStateWidget` for state displays
- Use `AppComponentStyles` micro-interaction styles
- Keep animations under 500ms for responsiveness

### DON'Ts ❌
- Don't use hardcoded spacing values (use `AppDimensions`)
- Don't create custom button styles (use `AppButton` variants)
- Don't use raw `TextStyle` (use `AppTypography`)
- Don't use hardcoded colors (use `AppColors`)
- Don't create inline styling (use standardized components)
- Don't create custom animations (use `AppConstants` curves/durations)
- Don't use raw `CircularProgressIndicator` (use `EnhancedLoadingIndicator`)
- Don't create custom error/empty states (use standard widgets)
- Don't hardcode animation durations (use constants)
- Don't skip micro-interactions on interactive elements

### Migration Example

#### Before (Inconsistent - Hardcoded Values & No Animations)
```dart
// Different button styles throughout app
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  child: Text('Submit'),
)

// Inconsistent spacing
Padding(
  padding: EdgeInsets.all(15.0), // Random value
  child: Column(
    children: [
      SizedBox(height: 10), // Different spacing
      Text('Title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),   // More inconsistency
    ],
  ),
)

// Basic loading without animation
CircularProgressIndicator()

// Custom animation durations everywhere
Future.delayed(Duration(milliseconds: 250), () {})
```

#### After (Standardized & Animated)
```dart
// Consistent button using AppComponentStyles
ElevatedButton(
  style: AppComponentStyles.enhancedButtonStyle,
  onPressed: () {},
  child: Text('Submit'),
)

// Consistent spacing using AppDimensions & extensions
Padding(
  padding: EdgeInsets.all(AppDimensions.spaceMd),
  child: Column(
    children: [
      SizedBox(height: AppDimensions.spaceMd),
      Text('Title', style: AppTypography.heading4),
      SizedBox(height: AppDimensions.spaceSm),
    ],
  ).withCardDecoration(), // Extension method
)

// Professional loading animation
EnhancedLoadingIndicator(
  message: 'Loading...',
  duration: AppConstants.loadingIndicatorDuration,
)

// Centralized animation constants
Future.delayed(AppConstants.shortDuration, () {})
```

## 🔄 Theme Switching & Animation Support

The app automatically adapts between light and dark themes with smooth animations:

```dart
// Components automatically adapt to theme
ElevatedButton(
  style: AppComponentStyles.enhancedButtonStyle,
  child: Text('Button'), // Uses appropriate colors for current theme
)
AppCard(child: content)            // Uses theme-appropriate card styling
AppTextField(label: 'Input')       // Uses theme-appropriate input styling

// Animations use standardized curves and durations
// All transitions are smooth and consistent across themes
```

### Animation & Theme Integration
```dart
// Use animations with theme-aware colors
ScaleTransition(
  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
    CurvedAnimation(
      parent: _controller,
      curve: AppConstants.standardCurve, // Consistent curve
    ),
  ),
  child: Container(
    color: Theme.of(context).colorScheme.primary, // Theme-aware
    child: Text('Animated', style: AppTypography.heading3),
  ),
)
```

## 📱 Responsive Considerations

All dimensions are designed to work across different screen sizes with animation support:
- Base spacing unit (8dp) scales appropriately
- Components have minimum touch targets (44dp)
- Text remains readable at different densities
- Icons maintain appropriate sizing ratios
- Animations remain smooth on all devices (60fps target)
- Micro-interactions provide responsive feedback

## ⚡ Performance Guidelines

### Animation Performance
```dart
// ✅ Good - Reuse animation controller
if (!_animationController.isAnimating) {
  _animationController.forward();
}

// ✅ Good - Dispose properly
@override
void dispose() {
  _animationController.dispose();
  super.dispose();
}

// ✅ Good - Use appropriate durations
// Keep animations under 500ms for responsiveness
duration: AppConstants.mediumDuration, // 300ms
```

### Loading States
- Use `CompactLoadingIndicator` for small spaces
- Use `EnhancedLoadingIndicator` for prominent loading
- Cache skeleton dimensions to avoid rebuilds
- Cleanup animations on dispose

### Micro-interactions
- Animations enhance user feedback, don't distract
- Use haptic feedback (AppConstants.enableHapticFeedback)
- Keep animations under 100-150ms for button presses
- Use appropriate elevation changes for depth

## 🚀 Benefits

1. **Consistency**: Uniform look, feel, and animations across the entire app
2. **Maintainability**: Changes to the design system propagate automatically
3. **Developer Experience**: Easy to implement new features with existing patterns
4. **Accessibility**: Built-in considerations for touch targets and contrast
5. **Performance**: Standardized components and animations reduce widget rebuilds
6. **Scalability**: Easy to extend and modify the design system
7. **Polish**: Professional animations and micro-interactions enhance UX
8. **Responsive**: All components work beautifully across screen sizes

## 📋 Component Checklist

When creating new UI components, ensure:
- [ ] Uses `AppDimensions` for spacing and sizing
- [ ] Uses `AppTypography` for text styles
- [ ] Uses `AppColors` for colors
- [ ] Uses `AppConstants` for animation curves/durations
- [ ] Uses extension methods from `AppComponentExtensions` where appropriate
- [ ] Adapts to light/dark themes automatically
- [ ] Follows existing component patterns
- [ ] Includes micro-interactions for interactive elements
- [ ] Maintains accessibility standards
- [ ] Is documented with usage examples

## 📚 Animation Reference

For detailed animation constants and patterns, see:
- **[Animation Quick Reference](ANIMATION_QUICK_REFERENCE.md)** - Complete animation guide
- **[Phase 3 Completion Summary](PHASE_3_COMPLETION_SUMMARY.md)** - Implementation details

This design system ensures that the Flutter Library App maintains a professional, consistent, and scalable user interface with delightful animations and micro-interactions that adapt beautifully to both light and dark themes.