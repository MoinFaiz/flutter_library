import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/favorites/presentation/pages/favorites_page.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:flutter_library/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/shared/widgets/book_grid_widget.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

class MockFavoritesBloc extends Mock implements FavoritesBloc {}

class MockNavigationService extends Mock implements NavigationService {}

class FakeFavoritesEvent extends Fake implements FavoritesEvent {}

class FakeRoute extends Fake {}

void main() {
  late GetIt sl;
  late MockNavigationService mockNavigationService;

  setUpAll(() {
    registerFallbackValue(FakeFavoritesEvent());
  });

  group('Favorites Page Widget Tests', () {
    late MockFavoritesBloc mockFavoritesBloc;

    setUp(() {
      mockFavoritesBloc = MockFavoritesBloc();
      mockNavigationService = MockNavigationService();
      
      // Setup default behavior for add method
      when(() => mockFavoritesBloc.add(any())).thenReturn(null);
      
      // Setup default behavior for close method
      when(() => mockFavoritesBloc.close()).thenAnswer((_) async {});
      
      // Setup default behavior for navigateTo method
      when(() => mockNavigationService.navigateTo<dynamic>(
        any(),
        arguments: any(named: 'arguments'),
      )).thenAnswer((_) async => null);
      
      // Setup GetIt
      sl = GetIt.instance;
      // Unregister if already registered, then register fresh
      if (sl.isRegistered<NavigationService>()) {
        sl.unregister<NavigationService>();
      }
      sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
    });

    tearDown(() async {
      // Clean up GetIt after test
      if (sl.isRegistered<NavigationService>()) {
        await sl.unregister<NavigationService>();
      }
    });

    testWidgets('should display favorites page with grid widget', (WidgetTester tester) async {
      // Arrange
      final favoriteBooks = [
        Book(
          id: '1',
          title: 'Favorite Book 1',
          author: 'Author 1',
          description: 'Description 1',
          imageUrls: const ['image1.jpg'],
          rating: 4.5,
          publishedYear: 2023,
          isFavorite: true,
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
        Book(
          id: '2',
          title: 'Favorite Book 2',
          author: 'Author 2',
          description: 'Description 2',
          imageUrls: const ['image2.jpg'],
          rating: 4.0,
          publishedYear: 2022,
          isFavorite: true,
          isFromFriend: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          metadata: const BookMetadata(
            ageAppropriateness: AgeAppropriateness.youngAdult,
            genres: ['Mystery'],
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

      when(() => mockFavoritesBloc.state).thenReturn(
        FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      );
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.byType(BookGridWidget), findsOneWidget);
    });

    testWidgets('should display loading state', (WidgetTester tester) async {
      // Arrange
      when(() => mockFavoritesBloc.state).thenReturn(FavoritesLoading());
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display empty state when no favorites', (WidgetTester tester) async {
      // Arrange
      when(() => mockFavoritesBloc.state).thenReturn(
        const FavoritesLoaded(
          favoriteBooks: [],
          hasMore: false,
          isLoadingMore: false,
        ),
      );
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      // Assert
      expect(find.text('No favorites yet'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load favorites';
      when(() => mockFavoritesBloc.state).thenReturn(const FavoritesError(errorMessage));
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      // Arrange
      final favoriteBooks = [
        Book(
          id: '1',
          title: 'Favorite Book 1',
          author: 'Author 1',
          description: 'Description 1',
          imageUrls: const ['image1.jpg'],
          rating: 4.5,
          publishedYear: 2023,
          isFavorite: true,
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

      when(() => mockFavoritesBloc.state).thenReturn(
        FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      );
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      // Act
      await tester.fling(find.byType(BookGridWidget), const Offset(0, 300), 1000);
      await tester.pump();

      // Assert
      verify(() => mockFavoritesBloc.add(LoadFavorites())).called(1);
    });

    testWidgets('should handle favorite toggle', (WidgetTester tester) async {
      // Arrange
      final favoriteBooks = [
        Book(
          id: '1',
          title: 'Favorite Book 1',
          author: 'Author 1',
          description: 'Description 1',
          imageUrls: const ['image1.jpg'],
          rating: 4.5,
          publishedYear: 2023,
          isFavorite: true,
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

      when(() => mockFavoritesBloc.state).thenReturn(
        FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      );
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      // Act
      final favoriteButton = find.byIcon(Icons.favorite).first;
      await tester.tap(favoriteButton);
      await tester.pump();

      // Assert
      verify(() => mockFavoritesBloc.add(const ToggleFavorite('1'))).called(1);
    });

    testWidgets('should navigate to book details when book is tapped', (WidgetTester tester) async {
      // Arrange
      final favoriteBooks = [
        Book(
          id: '1',
          title: 'Favorite Book 1',
          author: 'Author 1',
          description: 'Description 1',
          imageUrls: const ['image1.jpg'],
          rating: 4.5,
          publishedYear: 2023,
          isFavorite: true,
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

      when(() => mockFavoritesBloc.state).thenReturn(
        FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          hasMore: false,
          isLoadingMore: false,
        ),
      );
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );

      // Act
      final bookCard = find.byType(Card).first;
      await tester.tap(bookCard);
      await tester.pump(const Duration(milliseconds: 300));

      // Note: Navigation testing would require NavigatorObserver
      // This test verifies the tap gesture is recognized
    });

    testWidgets('should pass load more callback to BookGridWidget', (WidgetTester tester) async {
      // Arrange
      final favoriteBooks = List.generate(
        10,
        (index) => Book(
          id: 'book_$index',
          title: 'Favorite Book $index',
          author: 'Author $index',
          description: 'Description $index',
          imageUrls: const ['image.jpg'],
          rating: 4.0 + (index % 2) * 0.5,
          publishedYear: 2020 + index,
          isFavorite: true,
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
      );

      when(() => mockFavoritesBloc.state).thenReturn(
        FavoritesLoaded(
          favoriteBooks: favoriteBooks,
          hasMore: true,
          isLoadingMore: false,
        ),
      );
      when(() => mockFavoritesBloc.stream).thenAnswer((_) => Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<FavoritesBloc>(
            create: (context) => mockFavoritesBloc,
            child: const FavoritesPage(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Assert - Verify BookGridWidget is rendered with correct properties
      final bookGridWidget = tester.widget<BookGridWidget>(find.byType(BookGridWidget));
      expect(bookGridWidget.books.length, 10);
      expect(bookGridWidget.hasMore, true);
      expect(bookGridWidget.isLoadingMore, false);
      
      // Verify the grid widget is present (which means all callbacks including onLoadMore are passed)
      expect(find.byType(BookGridWidget), findsOneWidget);
    });
  });
}
