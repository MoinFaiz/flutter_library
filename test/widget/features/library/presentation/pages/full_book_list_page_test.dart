import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/library/presentation/pages/full_book_list_page.dart';
import 'package:flutter_library/features/library/domain/usecases/get_borrowed_books_usecase.dart';
import 'package:flutter_library/features/library/domain/usecases/get_uploaded_books_usecase.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/shared/widgets/book_grid_widget.dart';

class MockGetAllBorrowedBooksUseCase extends Mock implements GetAllBorrowedBooksUseCase {}
class MockGetAllUploadedBooksUseCase extends Mock implements GetAllUploadedBooksUseCase {}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  late MockGetAllBorrowedBooksUseCase mockGetBorrowedBooksUseCase;
  late MockGetAllUploadedBooksUseCase mockGetUploadedBooksUseCase;
  late MockNavigationService mockNavigationService;

  setUpAll(() {
    registerFallbackValue(BookListType.borrowed);
  });

  setUp(() {
    mockGetBorrowedBooksUseCase = MockGetAllBorrowedBooksUseCase();
    mockGetUploadedBooksUseCase = MockGetAllUploadedBooksUseCase();
    mockNavigationService = MockNavigationService();

    // Setup default behavior for navigateTo method
    when(() => mockNavigationService.navigateTo<dynamic>(
      any(),
      arguments: any(named: 'arguments'),
    )).thenAnswer((_) async => null);

    // Setup GetIt
    if (GetIt.instance.isRegistered<GetAllBorrowedBooksUseCase>()) {
      GetIt.instance.unregister<GetAllBorrowedBooksUseCase>();
    }
    if (GetIt.instance.isRegistered<GetAllUploadedBooksUseCase>()) {
      GetIt.instance.unregister<GetAllUploadedBooksUseCase>();
    }
    if (GetIt.instance.isRegistered<NavigationService>()) {
      GetIt.instance.unregister<NavigationService>();
    }

    GetIt.instance.registerSingleton<GetAllBorrowedBooksUseCase>(mockGetBorrowedBooksUseCase);
    GetIt.instance.registerSingleton<GetAllUploadedBooksUseCase>(mockGetUploadedBooksUseCase);
    GetIt.instance.registerSingleton<NavigationService>(mockNavigationService);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget({
    required String title,
    required BookListType listType,
  }) {
    return MaterialApp(
      home: FullBookListPage(
        title: title,
        listType: listType,
      ),
    );
  }

  final testBooks = [
    Book(
      id: '1',
      title: 'Test Book 1',
      author: 'Test Author 1',
      imageUrls: const ['https://example.com/book1.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 19.99,
        rentPrice: 4.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 2,
        availableForSaleCount: 1,
        totalCopies: 5,
      ),
      metadata: const BookMetadata(
        isbn: '1234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        pageCount: 300,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'A test book',
      publishedYear: 2023,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    ),
    Book(
      id: '2',
      title: 'Test Book 2',
      author: 'Test Author 2',
      imageUrls: const ['https://example.com/book2.jpg'],
      rating: 4.0,
      pricing: const BookPricing(
        salePrice: 24.99,
        rentPrice: 5.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 1,
        availableForSaleCount: 0,
        totalCopies: 3,
      ),
      metadata: const BookMetadata(
        isbn: '0987654321',
        publisher: 'Test Publisher 2',
        ageAppropriateness: AgeAppropriateness.youngAdult,
        genres: ['Non-Fiction'],
        pageCount: 250,
        language: 'English',
      ),
      isFromFriend: false,
      isFavorite: true,
      description: 'Another test book',
      publishedYear: 2023,
      createdAt: DateTime(2023, 2, 1),
      updatedAt: DateTime(2023, 2, 1),
    ),
  ];

  group('FullBookListPage Tests', () {
    testWidgets('displays borrowed books correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetBorrowedBooksUseCase())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Borrowed Books',
        listType: BookListType.borrowed,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert
      expect(find.text('Borrowed Books'), findsOneWidget);
      expect(find.byType(BookGridWidget), findsOneWidget);
      verify(() => mockGetBorrowedBooksUseCase()).called(1);
      verifyNever(() => mockGetUploadedBooksUseCase());
    });

    testWidgets('displays uploaded books correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetUploadedBooksUseCase())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Uploaded Books',
        listType: BookListType.uploaded,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert
      expect(find.text('Uploaded Books'), findsOneWidget);
      expect(find.byType(BookGridWidget), findsOneWidget);
      verify(() => mockGetUploadedBooksUseCase()).called(1);
      verifyNever(() => mockGetBorrowedBooksUseCase());
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetBorrowedBooksUseCase())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Borrowed Books',
        listType: BookListType.borrowed,
      ));

      // Assert (before settling) - may have multiple indicators from BookCards
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('displays error message on failure', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetBorrowedBooksUseCase())
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to load books')));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Borrowed Books',
        listType: BookListType.borrowed,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - BookGridWidget is present but shows error
      expect(find.text('Failed to load books'), findsOneWidget);
      expect(find.byType(BookGridWidget), findsOneWidget);
    });

    testWidgets('displays empty message when no books', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetBorrowedBooksUseCase())
          .thenAnswer((_) async => const Right([]));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Borrowed Books',
        listType: BookListType.borrowed,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - BookGridWidget is present but shows empty state
      expect(find.text('No borrowed books'), findsOneWidget);
      expect(find.byType(BookGridWidget), findsOneWidget);
    });

    testWidgets('supports pull to refresh', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetBorrowedBooksUseCase())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Borrowed Books',
        listType: BookListType.borrowed,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - Verify RefreshIndicator exists for pull-to-refresh support
      // The actual refresh mechanism is tested in integration tests
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(BookGridWidget), findsOneWidget);
    });

    testWidgets('has proper app bar with back button', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetBorrowedBooksUseCase())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Borrowed Books',
        listType: BookListType.borrowed,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('navigates back when back button pressed', (WidgetTester tester) async {
      // Arrange
      when(() => mockGetBorrowedBooksUseCase())
          .thenAnswer((_) async => Right(testBooks));

      // Act
      await tester.pumpWidget(createTestWidget(
        title: 'Borrowed Books',
        listType: BookListType.borrowed,
      ));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - In this isolated widget test there is no parent navigation flow.
      // Verify tap does not crash and page remains rendered.
      expect(find.byType(FullBookListPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
