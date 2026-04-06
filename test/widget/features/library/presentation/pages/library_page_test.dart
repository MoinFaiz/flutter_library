import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/library/presentation/pages/library_page.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_state.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_event.dart';
import 'package:flutter_library/features/library/presentation/widgets/horizontal_book_list.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

class MockLibraryBloc extends Mock implements LibraryBloc {
  @override
  Future<void> close() => Future.value();
}

class MockNavigationService extends Mock implements NavigationService {}

class FakeLibraryEvent extends Fake implements LibraryEvent {}

void main() {
  late GetIt sl;
  late MockNavigationService mockNavigationService;

  setUpAll(() {
    registerFallbackValue(FakeLibraryEvent());
  });

  group('Library Page Widget Tests', () {
    late MockLibraryBloc mockLibraryBloc;

    setUp(() {
      mockLibraryBloc = MockLibraryBloc();
      mockNavigationService = MockNavigationService();

      // Setup default behavior for add method
      when(() => mockLibraryBloc.add(any())).thenReturn(null);

      // Setup default behavior for navigateTo method
      when(() => mockNavigationService.navigateTo<dynamic>(
        any(),
        arguments: any(named: 'arguments'),
      )).thenAnswer((_) async => null);

      // Setup GetIt
      sl = GetIt.instance;
      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }
    });

    tearDown(() {
      sl.reset();
    });

    final mockBorrowedBooks = [
      Book(
        id: '1',
        title: 'Borrowed Book 1',
        author: 'Author 1',
        description: 'Description 1',
        imageUrls: const ['image1.jpg'],
        rating: 4.5,
        publishedYear: 2023,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction'],
          pageCount: 300,
          language: 'English',
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
      ),
    ];

    final mockUploadedBooks = [
      Book(
        id: '2',
        title: 'Uploaded Book 1',
        author: 'Author 2',
        description: 'Description 2',
        imageUrls: const ['image2.jpg'],
        rating: 4.0,
        publishedYear: 2022,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.youngAdult,
          genres: ['Science'],
          pageCount: 250,
          language: 'English',
        ),
        pricing: const BookPricing(
          salePrice: 19.99,
          rentPrice: 4.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 2,
          availableForSaleCount: 1,
          totalCopies: 3,
        ),
      ),
    ];

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<LibraryBloc>(
          create: (context) => mockLibraryBloc,
          child: const LibraryPage(),
        ),
      );
    }

    testWidgets('should display library page with sections', (WidgetTester tester) async {
      // Arrange
      when(() => mockLibraryBloc.state).thenReturn(
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
        ),
      );
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 300));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(AppConstants.borrowedBooksTitle), findsOneWidget);
      expect(find.text(AppConstants.myUploadedBooksTitle), findsOneWidget);
      expect(find.byType(HorizontalBookList), findsNWidgets(2));
    });

    testWidgets('should display loading state', (WidgetTester tester) async {
      // Arrange
      when(() => mockLibraryBloc.state).thenReturn(LibraryLoading());
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load library';
      when(() => mockLibraryBloc.state).thenReturn(const LibraryError(errorMessage));
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text(AppConstants.tryAgainButton), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should display borrowed books section', (WidgetTester tester) async {
      // Arrange
      when(() => mockLibraryBloc.state).thenReturn(
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
        ),
      );
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text(AppConstants.borrowedBooksTitle), findsOneWidget);
      expect(find.text('Borrowed Book 1'), findsOneWidget);
    });

    testWidgets('should display uploaded books section', (WidgetTester tester) async {
      // Arrange
      when(() => mockLibraryBloc.state).thenReturn(
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
        ),
      );
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text(AppConstants.myUploadedBooksTitle), findsOneWidget);
      expect(find.text('Uploaded Book 1'), findsOneWidget);
    });

    testWidgets('should display empty state when no books', (WidgetTester tester) async {
      // Arrange
      when(() => mockLibraryBloc.state).thenReturn(
        const LibraryLoaded(
          borrowedBooks: [],
          uploadedBooks: [],
        ),
      );
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - HorizontalBookList shows "No books yet" when empty
      expect(find.text(AppConstants.noBooksYetTitle), findsNWidgets(2)); // One for borrowed, one for uploaded
    });

    testWidgets('should load library data on init', (WidgetTester tester) async {
      // Arrange
      when(() => mockLibraryBloc.state).thenReturn(LibraryInitial());
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - LibraryPage loads both borrowed and uploaded books on init
      verify(() => mockLibraryBloc.add(const LoadBorrowedBooks())).called(1);
      verify(() => mockLibraryBloc.add(const LoadUploadedBooks())).called(1);
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      // Arrange
      when(() => mockLibraryBloc.state).thenReturn(
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
        ),
      );
      when(() => mockLibraryBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 300));
      
      // Clear initial load interactions
      clearInteractions(mockLibraryBloc);
      
      // Find RefreshIndicator and trigger refresh using drag
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - LibraryPage sends RefreshLibrary event
      verify(() => mockLibraryBloc.add(const RefreshLibrary())).called(1);
    });
  });
}
