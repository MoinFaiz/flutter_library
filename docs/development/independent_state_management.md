# Independent State Management for Book Details

## Overview
The book details page has been refactored to use independent state management for different concerns, allowing for better separation of concerns and independent loading of different data types.

## New Architecture

### **Separate BLoCs for Different Concerns**

1. **BookDetailsBloc** - Main book information
2. **BookReviewsBloc** - Book reviews management  
3. **RentalStatusBloc** - Rental and purchase status management

### **Independent State Management**

Each BLoC manages its own state independently:

```dart
// Book Details State
abstract class BookDetailsState extends Equatable

// Book Reviews State  
abstract class BookReviewsState extends Equatable

// Rental Status State
abstract class RentalStatusState extends Equatable
```

### **Automatic Data Loading**

When `LoadBookDetails` is triggered, all three BLoCs automatically start loading their respective data:

```dart
MultiBlocProvider(
  providers: [
    // Main book details BLoC
    BlocProvider(
      create: (context) => sl<BookDetailsBloc>()
        ..add(LoadBookDetails(book.id)),
    ),
    // Independent reviews BLoC
    BlocProvider(
      create: (context) => BookReviewsBloc()
        ..add(ReviewsEvent.LoadReviews(book.id)),
    ),
    // Independent rental status BLoC
    BlocProvider(
      create: (context) => RentalStatusBloc()
        ..add(RentalEvent.LoadRentalStatus(book.id)),
    ),
  ],
  child: BookDetailsPage(book: book),
)
```

## Benefits

### **1. Independent Loading**
- Each data type loads independently
- UI can show partial content while other data loads
- Better user experience with progressive loading

### **2. Separate Error Handling**
- Review loading failure doesn't affect book details
- Rental status errors don't impact reviews
- More granular error handling

### **3. Independent Actions**
- Adding a review doesn't interfere with rental actions
- Rental operations don't affect review state
- Clear separation of concerns

### **4. Better State Management**
- Smaller, focused state objects
- Easier to reason about state changes
- More testable code

## State Structure

### **BookReviewsState**
```dart
class BookReviewsLoaded extends BookReviewsState {
  final List<Review> reviews;
  final String? actionMessage;
}

class BookReviewsLoading extends BookReviewsState
class BookReviewsError extends BookReviewsState
class BookReviewsAdding extends BookReviewsState
```

### **RentalStatusState**
```dart
class RentalStatusLoaded extends RentalStatusState {
  final RentalStatus rentalStatus;
  final String? actionMessage;
}

class RentalStatusLoading extends RentalStatusState
class RentalStatusError extends RentalStatusState
class RentalStatusUpdating extends RentalStatusState
```

## Event Handling

### **BookReviewsEvent**
- `LoadReviews(bookId)` - Load reviews for a book
- `AddReview(bookId, reviewText, rating)` - Add a new review
- `RefreshReviews(bookId)` - Refresh reviews data

### **RentalStatusEvent**
- `LoadRentalStatus(bookId)` - Load rental status
- `RentBook(bookId)` - Rent a book
- `BuyBook(bookId)` - Purchase a book
- `ReturnBook(bookId)` - Return a rented book
- `RenewBook(bookId)` - Renew a rental
- `RemoveFromCart(bookId)` - Remove from cart
- `RefreshRentalStatus(bookId)` - Refresh rental status

## Widget Integration

### **Using Individual BLoCs**
```dart
// Listen to reviews state
BlocBuilder<BookReviewsBloc, BookReviewsState>(
  builder: (context, state) {
    if (state is BookReviewsLoaded) {
      return ReviewsList(reviews: state.reviews);
    }
    return LoadingIndicator();
  },
)

// Listen to rental status state
BlocBuilder<RentalStatusBloc, RentalStatusState>(
  builder: (context, state) {
    if (state is RentalStatusLoaded) {
      return RentalActions(status: state.rentalStatus);
    }
    return LoadingIndicator();
  },
)
```

### **Independent Actions**
```dart
// Add review
context.read<BookReviewsBloc>().add(
  ReviewsEvent.AddReview(bookId, reviewText, rating)
);

// Rent book
context.read<RentalStatusBloc>().add(
  RentalEvent.RentBook(bookId)
);
```

## Progressive Loading Example

1. **Initial Load**: Book details start loading
2. **Parallel Loading**: Reviews and rental status load simultaneously
3. **Progressive Display**: 
   - Show book info as soon as it loads
   - Show reviews when they load
   - Show rental actions when status loads
4. **Independent Updates**: Each section updates independently

## Error Handling

### **Granular Error States**
```dart
// Reviews failed but book details succeeded
if (reviewsState is BookReviewsError) {
  return ErrorMessage("Failed to load reviews");
}

// Rental status failed but other data succeeded
if (rentalState is RentalStatusError) {
  return ErrorMessage("Failed to load rental status");
}
```

### **Retry Mechanisms**
```dart
// Retry only reviews
ElevatedButton(
  onPressed: () => context.read<BookReviewsBloc>()
    .add(ReviewsEvent.LoadReviews(bookId)),
  child: Text("Retry Reviews"),
)

// Retry only rental status
ElevatedButton(
  onPressed: () => context.read<RentalStatusBloc>()
    .add(RentalEvent.LoadRentalStatus(bookId)),
  child: Text("Retry Rental Status"),
)
```

## Future Enhancements

### **Easy to Add New Features**
- Add new BLoCs for additional concerns (e.g., RelatedBooksBloc)
- Independent loading and error handling
- No impact on existing functionality

### **Performance Optimizations**
- Lazy loading for non-critical data
- Caching strategies per data type
- Background refresh for specific data

### **Testing Benefits**
- Test each BLoC independently
- Mock specific data types
- Isolated unit tests

## Implementation Status

### **✅ Completed**
- BookReviewsBloc with full state management
- RentalStatusBloc with action handling
- Independent loading in BookDetailsPageProvider
- Proper state separation and event handling

### **🔄 TODO**
- Update BookDetailsPage to use new BLoCs
- Create UI widgets for each state
- Implement actual use cases (currently using mock data)
- Add to dependency injection container

## Migration Guide

### **From Old Architecture**
```dart
// Old: Single BLoC with complex state
BookDetailsBloc()
  ..add(LoadBookDetails(bookId))
  ..add(LoadReviews(bookId))
  ..add(LoadRentalStatus(bookId))

// New: Multiple BLoCs with focused concerns
BookDetailsBloc()..add(LoadBookDetails(bookId))
BookReviewsBloc()..add(LoadReviews(bookId))
RentalStatusBloc()..add(LoadRentalStatus(bookId))
```

This architecture provides better maintainability, testability, and user experience through independent state management and progressive loading.

---

*Architecture updated: July 15, 2025*
