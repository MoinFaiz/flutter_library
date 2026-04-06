import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/shared/widgets/book_list_item.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';
import 'package:flutter_library/shared/widgets/book_genre_display.dart';
import 'package:flutter_library/shared/widgets/favorite_button.dart';
import 'package:flutter_library/shared/widgets/rating_display.dart';

void main() {
  group('BookListItem Widget Tests', () {
    late Book testBook;

    setUp(() {
      testBook = Book(
        id: '1',
        title: 'Test Book Title',
        author: 'Test Author',
        imageUrls: ['https://example.com/book.jpg'],
        rating: 4.5,
        pricing: const BookPricing(
          salePrice: 19.99,
          rentPrice: 3.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 3,
          availableForSaleCount: 2,
          totalCopies: 10,
        ),
        metadata: const BookMetadata(
          isbn: '1234567890',
          ageAppropriateness: AgeAppropriateness.adult,
          genres: ['Fiction', 'Mystery', 'Thriller'],
          pageCount: 250,
          language: 'English',
        ),
        isFromFriend: false,
        isFavorite: false,
        description: 'Test book description',
        publishedYear: 2023,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );
    });

    Widget createBookListItem({
      Book? book,
      VoidCallback? onTap,
      VoidCallback? onFavoriteToggle,
      bool showFavoriteButton = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: BookListItem(
            book: book ?? testBook,
            onTap: onTap,
            onFavoriteToggle: onFavoriteToggle,
            showFavoriteButton: showFavoriteButton,
          ),
        ),
      );
    }

    testWidgets('should display book information correctly', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.text('Test Book Title'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('should display book cover image', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(BookCoverImage), findsOneWidget);
    });

    testWidgets('should display book genres', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(BookGenreDisplay), findsOneWidget);
    });

    testWidgets('should display rating', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(RatingDisplay), findsOneWidget);
    });

    testWidgets('should show favorite button by default', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(FavoriteButton), findsOneWidget);
    });

    testWidgets('should hide favorite button when showFavoriteButton is false', (tester) async {
      await tester.pumpWidget(createBookListItem(
        showFavoriteButton: false,
      ));

      expect(find.byType(FavoriteButton), findsNothing);
    });

    testWidgets('should handle tap events', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createBookListItem(
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('should handle favorite toggle', (tester) async {
      bool favoriteToggled = false;
      await tester.pumpWidget(createBookListItem(
        onFavoriteToggle: () => favoriteToggled = true,
      ));

      await tester.tap(find.byType(FavoriteButton));
      expect(favoriteToggled, isTrue);
    });

    testWidgets('should be wrapped in a Card', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should use ListTile for layout', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('should have proper card margins', (tester) async {
      await tester.pumpWidget(createBookListItem());

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, isNotNull);
    });

    testWidgets('should truncate long titles', (tester) async {
      final longTitleBook = testBook.copyWith(
        title: 'This is a very long book title that should be truncated properly to prevent overflow',
      );
      
      await tester.pumpWidget(createBookListItem(book: longTitleBook));

      final titleText = tester.widget<Text>(find.text(longTitleBook.title));
      expect(titleText.maxLines, equals(2));
      expect(titleText.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should display author in subtitle', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('should have proper subtitle layout', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(Column), findsOneWidget);
      
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });

    testWidgets('should show spacing in subtitle', (tester) async {
      await tester.pumpWidget(createBookListItem());

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should handle book without image', (tester) async {
      final bookWithoutImage = testBook.copyWith(imageUrls: []);
      await tester.pumpWidget(createBookListItem(book: bookWithoutImage));

      expect(find.byType(BookCoverImage), findsOneWidget);
      expect(find.byType(BookListItem), findsOneWidget);
    });

    testWidgets('should handle book with multiple genres', (tester) async {
      await tester.pumpWidget(createBookListItem());

      final genreDisplay = tester.widget<BookGenreDisplay>(find.byType(BookGenreDisplay));
      expect(genreDisplay.maxGenres, equals(3));
    });

    testWidgets('should display favorite book correctly', (tester) async {
      final favoriteBook = testBook.copyWith(isFavorite: true);
      await tester.pumpWidget(createBookListItem(book: favoriteBook));

      final favoriteButton = tester.widget<FavoriteButton>(find.byType(FavoriteButton));
      expect(favoriteButton.isFavorite, isTrue);
    });

    testWidgets('should handle zero rating', (tester) async {
      final noRatingBook = testBook.copyWith(rating: 0.0);
      await tester.pumpWidget(createBookListItem(book: noRatingBook));

      expect(find.byType(RatingDisplay), findsOneWidget);
    });

    testWidgets('should work with different themes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: BookListItem(
              book: testBook,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byType(BookListItem), findsOneWidget);
    });

    testWidgets('should handle special characters in title and author', (tester) async {
      final specialCharBook = testBook.copyWith(
        title: 'Título con Ñoño & Special Characters! 📚',
        author: 'José María Hernández-González',
      );
      
      await tester.pumpWidget(createBookListItem(book: specialCharBook));

      expect(find.text('Título con Ñoño & Special Characters! 📚'), findsOneWidget);
      expect(find.text('José María Hernández-González'), findsOneWidget);
    });

    testWidgets('should handle very short title', (tester) async {
      final shortTitleBook = testBook.copyWith(title: 'A');
      await tester.pumpWidget(createBookListItem(book: shortTitleBook));

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('should handle empty author name', (tester) async {
      final noAuthorBook = testBook.copyWith(author: '');
      await tester.pumpWidget(createBookListItem(book: noAuthorBook));

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should maintain proper image dimensions', (tester) async {
      await tester.pumpWidget(createBookListItem());

      final bookCoverImage = tester.widget<BookCoverImage>(find.byType(BookCoverImage));
      expect(bookCoverImage.width, equals(42));
      expect(bookCoverImage.height, equals(56));
    });

    testWidgets('should handle rapid state changes', (tester) async {
      bool isFavorite = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            final book = testBook.copyWith(isFavorite: isFavorite);
            return MaterialApp(
              home: Scaffold(
                body: BookListItem(
                  book: book,
                  onFavoriteToggle: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();
      await tester.tap(find.byType(FavoriteButton));
      await tester.pump();

      expect(find.byType(BookListItem), findsOneWidget);
    });

    testWidgets('should work in list view', (tester) async {
      final books = List.generate(3, (index) => testBook.copyWith(
        id: index.toString(),
        title: 'Book $index',
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) => BookListItem(
                book: books[index],
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BookListItem), findsNWidgets(3));
      expect(find.text('Book 0'), findsOneWidget);
      expect(find.text('Book 1'), findsOneWidget);
      expect(find.text('Book 2'), findsOneWidget);
    });

    testWidgets('should handle constrained width layouts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: BookListItem(
                book: testBook,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BookListItem), findsOneWidget);
    });

    testWidgets('should be semantically accessible', (tester) async {
      await tester.pumpWidget(createBookListItem());

      // Should be tappable
      expect(find.byType(ListTile), findsOneWidget);
      
      // Should have readable text
      expect(find.text('Test Book Title'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
    });

    testWidgets('should handle null callbacks gracefully', (tester) async {
      await tester.pumpWidget(createBookListItem(
        onTap: null,
        onFavoriteToggle: null,
      ));

      expect(find.byType(BookListItem), findsOneWidget);
    });

    testWidgets('should maintain proper visual hierarchy', (tester) async {
      await tester.pumpWidget(createBookListItem());

      // Title should be in the title position
      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.title, isA<Text>());
      expect(listTile.subtitle, isA<Column>());
      expect(listTile.leading, isA<SizedBox>());
      expect(listTile.trailing, isA<FavoriteButton>());
    });
  });
}
