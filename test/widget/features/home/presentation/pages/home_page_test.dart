import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/home/presentation/pages/home_page.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_event.dart';
import 'package:flutter_library/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';

class MockHomeBloc extends Mock implements HomeBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

class MockNavigationService extends Mock implements NavigationService {}

class FakeHomeEvent extends Fake implements HomeEvent {}

void main() {
  group('HomePage Tests', () {
    late MockHomeBloc mockHomeBloc;
    late MockNavigationService mockNavigationService;
    late GetIt sl;

    setUp(() {
      mockHomeBloc = MockHomeBloc();
      mockNavigationService = MockNavigationService();
      registerFallbackValue(FakeHomeEvent());
      
      // Setup default behavior for add method
      when(() => mockHomeBloc.add(any())).thenReturn(null);
      
      // Setup default behavior for navigateTo method
      when(() => mockNavigationService.navigateTo<dynamic>(
        any(),
        arguments: any(named: 'arguments'),
      )).thenAnswer((_) async => null);
      
      // Setup dependency injection
      sl = GetIt.instance;
      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }
    });

    tearDown(() {
      sl.reset();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<HomeBloc>(
          create: (context) => mockHomeBloc,
          child: const HomePage(),
        ),
      );
    }

    Book createMockBook({
      String id = '1',
      String title = 'Test Book',
      String author = 'Test Author',
      bool isFavorite = false,
    }) {
      return Book(
        id: id,
        title: title,
        author: author,
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
        isFavorite: isFavorite,
        description: 'Test description',
        publishedYear: 2023,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    testWidgets('displays search header', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search books, authors, genres...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('triggers load books on init', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      verify(() => mockHomeBloc.add(LoadBooks())).called(1);
    });

    testWidgets('displays books when loaded', (WidgetTester tester) async {
      // Arrange
      final mockBooks = [
        createMockBook(id: '1', title: 'First Book'),
        createMockBook(id: '2', title: 'Second Book'),
      ];
      when(() => mockHomeBloc.state).thenReturn(HomeLoaded(books: mockBooks));
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextField), findsOneWidget); // Search should be present
    });

    testWidgets('triggers search when text changes', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextField), 'flutter');

      // Assert
      verify(() => mockHomeBloc.add(const SearchBooks('flutter'))).called(1);
    });

    testWidgets('clears search when empty text', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // First enter some text
      await tester.enterText(find.byType(TextField), 'test');
      
      // Then clear it
      await tester.enterText(find.byType(TextField), '');

      // Assert
      verify(() => mockHomeBloc.add(ClearSearch())).called(1);
    });

    testWidgets('shows clear button when text is entered', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears search when clear button is tapped', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pumpAndSettle();
      
      final clearButton = find.byIcon(Icons.clear);
      expect(clearButton, findsOneWidget);
      
      await tester.tap(clearButton);

      // Assert
      verify(() => mockHomeBloc.add(ClearSearch())).called(1);
    });

    testWidgets('supports pull to refresh', (WidgetTester tester) async {
      // Arrange
      final mockBooks = [createMockBook()];
      when(() => mockHomeBloc.state).thenReturn(HomeLoaded(books: mockBooks));
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - RefreshIndicator should be present
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('shows favorites button', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.favorite_outline), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(HomeInitial());
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays empty state correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockHomeBloc.state).thenReturn(const HomeLoaded(books: []));
      when(() => mockHomeBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextField), findsOneWidget); // Search should still be visible
    });
  });
}
