import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_details_page_provider.dart';
import 'package:flutter_library/features/book_details/presentation/pages/book_details_page.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/reviews_state.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_state.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_state.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

// Mock classes
class MockBookDetailsBloc extends Mock implements BookDetailsBloc {}
class MockReviewsBloc extends Mock implements ReviewsBloc {}
class MockRentalStatusBloc extends Mock implements RentalStatusBloc {}

final sl = GetIt.instance;

void main() {
  group('BookDetailsPageProvider', () {
    late MockBookDetailsBloc mockBookDetailsBloc;
    late MockReviewsBloc mockReviewsBloc;
    late MockRentalStatusBloc mockRentalStatusBloc;
    late Book testBook;

    setUp(() {
      // Reset GetIt
      sl.reset();
      
      mockBookDetailsBloc = MockBookDetailsBloc();
      mockReviewsBloc = MockReviewsBloc();
      mockRentalStatusBloc = MockRentalStatusBloc();
      
      // Register mocks in GetIt
      sl.registerFactory<BookDetailsBloc>(() => mockBookDetailsBloc);
      sl.registerFactory<ReviewsBloc>(() => mockReviewsBloc);
      sl.registerFactory<RentalStatusBloc>(() => mockRentalStatusBloc);
      
      testBook = Book(
        id: 'test-book-id',
        title: 'Test Book',
        author: 'Test Author',
        imageUrls: const ['test_cover.jpg'],
        rating: 4.5,
        pricing: const BookPricing(
          salePrice: 25.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 5,
          availableForSaleCount: 3,
          totalCopies: 8,
        ),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'Test description',
        publishedYear: 2023,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      when(() => mockBookDetailsBloc.state).thenReturn(BookDetailsInitial());
      when(() => mockBookDetailsBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBookDetailsBloc.close()).thenAnswer((_) async {});
      when(() => mockReviewsBloc.state).thenReturn(ReviewsInitial());
      when(() => mockReviewsBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockReviewsBloc.close()).thenAnswer((_) async {});
      when(() => mockRentalStatusBloc.state).thenReturn(RentalStatusInitial());
      when(() => mockRentalStatusBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockRentalStatusBloc.close()).thenAnswer((_) async {});
    });
    
    tearDown(() {
      sl.reset();
    });

    testWidgets('creates MultiBlocProvider with all required blocs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailsPageProvider(book: testBook),
        ),
      );

      expect(find.byType(MultiBlocProvider), findsOneWidget);
      expect(find.byType(BookDetailsPage), findsOneWidget);
    });

    testWidgets('provides all required blocs to BookDetailsPage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailsPageProvider(book: testBook),
        ),
      );

      final bookDetailsPageFinder = find.byType(BookDetailsPage);
      expect(bookDetailsPageFinder, findsOneWidget);

      final context = tester.element(bookDetailsPageFinder);
      final bookDetailsBloc = BlocProvider.of<BookDetailsBloc>(context);
      final reviewsBloc = BlocProvider.of<ReviewsBloc>(context);
      final rentalStatusBloc = BlocProvider.of<RentalStatusBloc>(context);
      
      expect(bookDetailsBloc, isNotNull);
      expect(reviewsBloc, isNotNull);
      expect(rentalStatusBloc, isNotNull);
    });

    testWidgets('passes book to BookDetailsPage', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailsPageProvider(book: testBook),
        ),
      );

      final bookDetailsPageFinder = find.byType(BookDetailsPage);
      expect(bookDetailsPageFinder, findsOneWidget);
      
      final bookDetailsPageWidget = tester.widget<BookDetailsPage>(bookDetailsPageFinder);
      expect(bookDetailsPageWidget.book, equals(testBook));
    });

    testWidgets('renders without throwing exceptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BookDetailsPageProvider(book: testBook),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
