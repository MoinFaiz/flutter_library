# Component Extensions Quick Reference Guide

**File:** `lib/core/theme/app_component_extensions.dart`  
**Import:** `import 'package:flutter_library/core/theme/app_component_extensions.dart';`

---

## 🎨 WidgetPaddingExtension

Fluent padding methods for any widget.

### Methods

#### `withCompactPadding()`
Applies 8px horizontal, 4px vertical padding.
```dart
Text('Label').withCompactPadding()
// Equivalent to:
// Padding(
//   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//   child: Text('Label'),
// )
```

#### `withDefaultPadding()`
Applies 16px padding on all sides.
```dart
Container().withDefaultPadding()
// Equivalent to: EdgeInsets.all(16)
```

#### `withLoosePadding()`
Applies 24px padding on all sides.
```dart
Card().withLoosePadding()
// Equivalent to: EdgeInsets.all(24)
```

#### `withCardPadding()`
Applies card-specific padding (16px).
```dart
Column(...).withCardPadding()
```

#### `withPadding(EdgeInsets padding)`
Applies custom padding.
```dart
Text('Custom').withPadding(
  EdgeInsets.only(left: 12, right: 12)
)
```

---

## 🎭 ContainerDecorationExtension

Pre-built decoration styles for containers and cards.

### Methods

#### `asCard({bool isDark, EdgeInsets padding})`
Wraps widget as a styled card with shadow.
```dart
Text('Card Content').asCard()
// Adds: card decoration, shadow, default padding

// With dark theme:
MyWidget().asCard(isDark: true)

// With custom padding offset:
MyWidget().asCard(padding: EdgeInsets.all(8))
```

#### `asStatusBadge({required BadgeStatus status, EdgeInsets padding})`
Applies status badge styling with colored background.
```dart
Text('Active').asStatusBadge(status: BadgeStatus.success)
// Green background with border

Text('Error').asStatusBadge(status: BadgeStatus.error)
// Red background with border

Text('Warning').asStatusBadge(status: BadgeStatus.warning)
// Orange background with border
```

#### `withShadow({required ShadowElevation elevation})`
Applies shadow decoration.
```dart
// Small shadow (subtle)
Container().withShadow(elevation: ShadowElevation.small)

// Medium shadow (standard)
Card().withShadow(elevation: ShadowElevation.medium)

// Large shadow (prominent)
Dialog().withShadow(elevation: ShadowElevation.large)
```

#### `asFocusedElement()`
Applies focus state styling (blue border).
```dart
TextField().asFocusedElement()
// Adds: 2px blue border with radius
```

#### `asHoverElement()`
Applies hover state styling (subtle overlay).
```dart
InkWell().asHoverElement()
// Adds: Subtle blue background overlay
```

#### `asDisabledElement()`
Applies disabled state styling (faded appearance).
```dart
Button().asDisabledElement()
// Adds: Faded background color
```

---

## 📏 SpacingExtension

Vertical and horizontal spacing utilities.

### Methods

#### `addVerticalSpace(double height)`
Adds vertical space below widget.
```dart
Text('Label').addVerticalSpace(16)
// Creates: Column with Text + SizedBox(height: 16)
```

#### `addHorizontalSpace(double width)`
Adds horizontal space to the right.
```dart
Icon(Icons.star).addHorizontalSpace(8)
// Creates: Row with Icon + SizedBox(width: 8)
```

#### `withStandardSpacing()`
Wraps widget with 16px spacing on all sides.
```dart
Text('Content').withStandardSpacing()
// Equivalent to: EdgeInsets.all(16)
```

#### `withCompactSpacing()`
Wraps widget with 8px spacing on all sides.
```dart
Label().withCompactSpacing()
// Equivalent to: EdgeInsets.all(8)
```

#### `withLooseSpacing()`
Wraps widget with 24px spacing on all sides.
```dart
Section().withLooseSpacing()
// Equivalent to: EdgeInsets.all(24)
```

---

## 📝 TextSpacingExtension

Directional padding for text widgets.

### Methods

#### `withTopPadding(double padding)`
Adds top padding to text.
```dart
Text('Title').withTopPadding(16)
```

#### `withBottomPadding(double padding)`
Adds bottom padding to text.
```dart
Text('Subtitle').withBottomPadding(8)
```

#### `withLeftPadding(double padding)`
Adds left padding to text.
```dart
Text('Indented').withLeftPadding(24)
```

#### `withRightPadding(double padding)`
Adds right padding to text.
```dart
Text('Label').withRightPadding(12)
```

---

## 🎯 Enums

### BadgeStatus
Used with `asStatusBadge()` method.

```dart
enum BadgeStatus {
  success,   // Green styling
  error,     // Red styling
  warning,   // Orange styling
}
```

### ShadowElevation
Used with `withShadow()` method.

```dart
enum ShadowElevation {
  small,     // Subtle shadow (blurRadius: 3)
  medium,    // Standard shadow (blurRadius: 8)
  large,     // Prominent shadow (blurRadius: 16)
}
```

---

## 💡 USAGE EXAMPLES

### Example 1: Simple Card
```dart
// Without extensions:
Container(
  decoration: AppComponentStyles.cardDecoration,
  padding: EdgeInsets.all(AppDimensions.spaceMd),
  child: Text('Hello'),
)

// With extensions:
Text('Hello').withDefaultPadding().asCard()
```

### Example 2: Status Badge
```dart
// Without extensions:
Container(
  decoration: AppComponentStyles.statusBadgeDecoration,
  padding: AppComponentStyles.compactPadding,
  child: Text('Active'),
)

// With extensions:
Text('Active').asStatusBadge(status: BadgeStatus.success)
```

### Example 3: Complex Layout
```dart
Column(
  children: [
    Text('Title')
        .withTopPadding(16)
        .asCard(),
    const SizedBox(height: 16),
    Text('Content')
        .withDefaultPadding()
        .withShadow(elevation: ShadowElevation.medium),
    const SizedBox(height: 8),
    ElevatedButton(
      onPressed: () {},
      child: Text('Action'),
    ).withCompactSpacing(),
  ],
)

// Simplified with extensions:
Column(
  children: [
    Text('Title').withTopPadding(16).asCard(),
    Text('Content')
        .withDefaultPadding()
        .withShadow(elevation: ShadowElevation.medium),
    ElevatedButton(
      onPressed: () {},
      child: Text('Action'),
    ).withCompactSpacing(),
  ],
)
```

### Example 4: Interactive Elements
```dart
InkWell(
  onTap: () {},
  child: Container(
    decoration: AppComponentStyles.cardDecoration,
    child: Text('Tap me').withDefaultPadding(),
  ),
)

// With extensions:
InkWell(
  onTap: () {},
  child: Text('Tap me')
      .withDefaultPadding()
      .asCard()
      .asHoverElement(),
)
```

---

## ⚡ PERFORMANCE TIPS

1. **Chaining:** Extensions can be chained for cleaner code
   ```dart
   // ✅ Good: Chainable
   Text('Label')
       .withDefaultPadding()
       .asCard()
       .withShadow(elevation: ShadowElevation.medium)
   ```

2. **Prefer Pre-built Decorations:** Use predefined styles over custom styling
   ```dart
   // ✅ Good: Pre-built
   Widget().asStatusBadge(status: BadgeStatus.success)
   
   // ❌ Avoid: Custom creation
   Container(decoration: BoxDecoration(...))
   ```

3. **Use Enums for Type Safety:**
   ```dart
   // ✅ Good: Type-safe
   .withShadow(elevation: ShadowElevation.medium)
   
   // ❌ Avoid: Magic values
   .withShadow(elevation: 2)
   ```

---

## 🔗 RELATED REFERENCES

- **AppComponentStyles:** `lib/core/theme/app_component_styles.dart`
- **AppDimensions:** `lib/core/theme/app_dimensions.dart`
- **AppColors:** `lib/core/theme/app_colors.dart`

---

## 📚 BEST PRACTICES

### ✅ DO

```dart
// Use extensions for cleaner code
Text('Label').withDefaultPadding()

// Chain multiple extensions
MyWidget().withDefaultPadding().asCard().withShadow()

// Use enums for parameters
.asStatusBadge(status: BadgeStatus.success)

// Use predefined decorations
.asCard(), .asStatusBadge(), .withShadow()
```

### ❌ DON'T

```dart
// Don't mix extension and manual approaches
Text('Label').withDefaultPadding() // extension
    .asCard()  // extension
    // ❌ then manually add padding
    .withPadding(EdgeInsets.all(8))  // redundant

// Don't hardcode values
.withPadding(EdgeInsets.all(16))  // use withDefaultPadding() instead

// Don't use string literals
.asStatusBadge(status: 'success')  // use enum instead

// Don't create custom decorations
BoxDecoration(...)  // use .asCard() instead
```

---

**Happy building with extensions!** 🎉
