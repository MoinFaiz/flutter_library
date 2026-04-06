import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_search_section.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';

class MockBookUploadBloc extends Mock implements BookUploadBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

void main() {
  late MockBookUploadBloc mockBookUploadBloc;

  setUpAll(() {
    registerFallbackValue(const SearchBooks('test'));
  });

  setUp(() {
    mockBookUploadBloc = MockBookUploadBloc();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<BookUploadBloc>(
          create: (context) => mockBookUploadBloc,
          child: const BookSearchSection(),
        ),
      ),
    );
  }

  group('BookSearchSection Tests', () {
    testWidgets('shows nothing when not in loaded state', (WidgetTester tester) async {
      // Arrange
      when(() => mockBookUploadBloc.state).thenReturn(const BookUploadInitial());
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Search for Existing Book'), findsNothing);
    });

    testWidgets('displays search interface when loaded', (WidgetTester tester) async {
      // Arrange
      final loadedState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(loadedState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Search for Existing Book'), findsOneWidget);
      expect(find.text('Search by title or ISBN to check if the book already exists'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('shows search input with proper hints', (WidgetTester tester) async {
      // Arrange
      final loadedState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(loadedState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Enter book title or ISBN'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('triggers search on text submission', (WidgetTester tester) async {
      // Arrange
      final loadedState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(loadedState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextField), 'Test Book');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Assert
      verify(() => mockBookUploadBloc.add(const SearchBooks('Test Book'))).called(1);
    });

    testWidgets('triggers search on button press', (WidgetTester tester) async {
      // Arrange
      final loadedState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(loadedState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextField), 'Test ISBN');
      await tester.tap(find.text('Search'));

      // Assert
      verify(() => mockBookUploadBloc.add(const SearchBooks('Test ISBN'))).called(1);
    });

    testWidgets('disables search button when searching', (WidgetTester tester) async {
      // Arrange
      final searchingState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: true,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(searchingState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final searchButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Search'),
      );
      expect(searchButton.onPressed, isNull);
    });

    testWidgets('shows loading indicator when searching', (WidgetTester tester) async {
      // Arrange
      final searchingState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: true,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(searchingState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays search results when available', (WidgetTester tester) async {
      // Arrange
      final testBook = Book(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        imageUrls: const ['https://example.com/book.jpg'],
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
      );

      final stateWithResults = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: [testBook],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(stateWithResults);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('shows no results message when search returns empty', (WidgetTester tester) async {
      // Arrange
      final stateWithNoResults = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(stateWithNoResults);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('No books found'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Arrange
      final loadedState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(loadedState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('does not search with empty text', (WidgetTester tester) async {
      // Arrange
      final loadedState = BookUploadLoaded(
        form: BookUploadForm.empty(),
        searchResults: const [],
        genres: const [],
        languages: const [],
        isSearching: false,
        isUploadingImage: false,
      );
      when(() => mockBookUploadBloc.state).thenReturn(loadedState);
      when(() => mockBookUploadBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Assert
      verifyNever(() => mockBookUploadBloc.add(any()));
    });
  });
}
