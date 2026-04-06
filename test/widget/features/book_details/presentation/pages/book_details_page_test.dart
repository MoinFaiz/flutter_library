import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_details_page.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_state.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_state.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_state.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/book_details/domain/entities/review.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:mocktail/mocktail.dart';

class MockBookDetailsBloc extends Mock implements BookDetailsBloc {}
class MockReviewsBloc extends Mock implements ReviewsBloc {}
class MockRentalStatusBloc extends Mock implements RentalStatusBloc {}

void main() {
  group('Book Details Page Widget Tests', () {
    late MockBookDetailsBloc mockBookDetailsBloc;
    late MockReviewsBloc mockReviewsBloc;
    late MockRentalStatusBloc mockRentalStatusBloc;
    late Book testBook;

    setUp(() {
      mockBookDetailsBloc = MockBookDetailsBloc();
      mockReviewsBloc = MockReviewsBloc();
      mockRentalStatusBloc = MockRentalStatusBloc();
      
      // Stub close methods to return completed futures
      when(() => mockBookDetailsBloc.close()).thenAnswer((_) => Future.value());
      when(() => mockReviewsBloc.close()).thenAnswer((_) => Future.value());
      when(() => mockRentalStatusBloc.close()).thenAnswer((_) => Future.value());
      
      testBook = Book(
        id: '1',
        title: 'Test Book Title',
        author: 'Test Author',
        description: 'This is a test book description for testing purposes.',
        imageUrls: const ['test_image_1.jpg', 'test_image_2.jpg'],
        rating: 4.5,
        publishedYear: 2023,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction', 'Mystery'],
          pageCount: 350,
          language: 'English',
          isbn: '978-1234567890',
          publisher: 'Test Publisher',
        ),
        pricing: const BookPricing(
          salePrice: 24.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 2,
          totalCopies: 5,
        ),
      );
    });

    testWidgets('should display book details correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsLoaded(book: testBook));
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(ReviewsInitial());
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusInitial());
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Book Title'), findsOneWidget);
      expect(find.text('by Test Author'), findsOneWidget);
      expect(find.text('This is a test book description for testing purposes.'), findsOneWidget);
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should display image carousel for multiple images', (WidgetTester tester) async {
      // Arrange
      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsLoaded(book: testBook));
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(ReviewsInitial());
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusInitial());
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('should display reviews section', (WidgetTester tester) async {
      // Arrange
      final mockReviews = [
        Review(
          id: '1',
          bookId: '1',
          userId: 'user1',
          userName: 'John Doe',
          reviewText: 'Great book!',
          rating: 5.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Review(
          id: '2',
          bookId: '1',
          userId: 'user2',
          userName: 'Jane Smith',
          reviewText: 'Very interesting read.',
          rating: 4.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsLoaded(book: testBook));
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(ReviewsLoaded(reviews: mockReviews));
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusInitial());
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert
      expect(find.text('Reviews'), findsWidgets);
      expect(find.text('Great book!'), findsOneWidget);
      expect(find.text('Very interesting read.'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('should show View All Reviews button when there are more than 2 reviews', (WidgetTester tester) async {
      // Arrange
      final mockReviews = List.generate(
        5,
        (index) => Review(
          id: 'review_$index',
          bookId: '1',
          userId: 'user$index',
          userName: 'User $index',
          reviewText: 'Review comment $index',
          rating: 4.0 + (index % 2),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsLoaded(book: testBook));
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(ReviewsLoaded(reviews: mockReviews));
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusInitial());
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('View All Reviews 5 reviews'), findsOneWidget);
    });

    testWidgets('should display rental status section', (WidgetTester tester) async {
      // Arrange
      final mockRentalStatus = RentalStatus(
        bookId: '1',
        status: RentalStatusType.available,
        canRenew: true,
      );

      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsLoaded(book: testBook));
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(ReviewsInitial());
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusLoaded(rentalStatus: mockRentalStatus));
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert
      expect(find.text('Rental Status'), findsWidgets);
      expect(find.text('Rent'), findsWidgets);
      expect(find.text('Buy'), findsWidgets);
    });

    testWidgets('should handle loading states correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsLoading());
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(ReviewsLoading());
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusLoading());
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should handle error states correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockBookDetailsBloc.state).thenReturn(const BookDetailsError('Failed to load book details'));
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(const ReviewsError('Failed to load reviews'));
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(const RentalStatusError('Failed to load rental status'));
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsWidgets);
      expect(find.text('Retry'), findsWidgets);
    });

    testWidgets('should show favorite button and allow toggling', (WidgetTester tester) async {
      // Arrange
      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsLoaded(book: testBook));
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockReviewsBloc.state).thenReturn(ReviewsInitial());
      when(() => mockReviewsBloc.stream).thenAnswer((_) => Stream.empty());
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusInitial());
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<BookDetailsBloc>(create: (_) => mockBookDetailsBloc),
              BlocProvider<ReviewsBloc>(create: (_) => mockReviewsBloc),
              BlocProvider<RentalStatusBloc>(create: (_) => mockRentalStatusBloc),
            ],
            child: BookDetailsPage(book: testBook),
          ),
        ),
      );

      // Assert - Check for favorite button
      expect(find.byIcon(Icons.favorite_border), findsWidgets);
    });
  });
}
