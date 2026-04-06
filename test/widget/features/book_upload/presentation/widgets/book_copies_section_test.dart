import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart' as domain;
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_copies_section.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookUploadBloc extends Mock implements BookUploadBloc {}

void main() {
  late MockBookUploadBloc mockBloc;

  setUp(() {
    mockBloc = MockBookUploadBloc();
    registerFallbackValue(const AddNewCopy());
    registerFallbackValue(const RemoveCopy(0));
    registerFallbackValue(UpdateCopy(
      copyIndex: 0,
      copy: BookCopy(
        id: '1',
        condition: BookCondition.good,
        imageUrls: const [],
        isForSale: false,
        isForRent: false,
        isForDonate: false,
        expectedPrice: 0,
      ),
    ));
  });

  Widget createWidgetUnderTest(BookUploadState state) {
    when(() => mockBloc.state).thenReturn(state);
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(state));

    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: BlocProvider<BookUploadBloc>.value(
            value: mockBloc,
            child: const BookCopiesSection(),
          ),
        ),
      ),
    );
  }

  group('BookCopiesSection Widget Tests', () {
    testWidgets('renders nothing when state is not BookUploadLoaded',
        (WidgetTester tester) async {
      // Arrange
      const state = BookUploadInitial();

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.byType(Card), findsNothing);
      expect(find.text('Book Copies'), findsNothing);
    });

    testWidgets('renders empty state when no copies exist',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: const domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Book Copies'), findsOneWidget);
      expect(find.text('Add Copy'), findsOneWidget);
      expect(find.text('No copies added yet'), findsOneWidget);
      expect(find.text('Add at least one copy to continue'), findsOneWidget);
      expect(find.byIcon(Icons.library_books), findsOneWidget);
    });

    testWidgets('renders Add Copy button', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: const domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Add Copy'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('triggers AddNewCopy event when Add Copy button is tapped',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: const domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.text('Add Copy'));
      await tester.pump();

      // Assert
      verify(() => mockBloc.add(const AddNewCopy())).called(1);
    });

    testWidgets('renders list of copies when copies exist',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 15.99,
            ),
            BookCopy(
              id: '2',
              condition: BookCondition.likeNew,
              imageUrls: const [],
              isForSale: false,
              isForRent: true,
              isForDonate: false,
              expectedPrice: 5.99,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Copy 1'), findsOneWidget);
      expect(find.text('Copy 2'), findsOneWidget);
      expect(find.text('No copies added yet'), findsNothing);
    });

    testWidgets('renders condition dropdown for each copy',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Condition'), findsOneWidget);
      expect(
          find.widgetWithText(DropdownButtonFormField<BookCondition>, 'Good'),
          findsOneWidget);
    });

    testWidgets('updates copy condition when dropdown value changes',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.byType(DropdownButtonFormField<BookCondition>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Like New').last);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockBloc.add(any(that: isA<UpdateCopy>()))).called(1);
    });

    testWidgets('renders availability checkboxes', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: true,
              isForRent: true,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Availability'), findsOneWidget);
      expect(find.text('For Sale'), findsOneWidget);
      expect(find.text('For Rent'), findsOneWidget);
      expect(find.text('For Donation'), findsOneWidget);
    });

    testWidgets('toggles For Sale checkbox', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.widgetWithText(CheckboxListTile, 'For Sale'));
      await tester.pump();

      // Assert
      verify(() => mockBloc.add(any(that: isA<UpdateCopy>()))).called(1);
    });

    testWidgets('toggles For Rent checkbox', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.widgetWithText(CheckboxListTile, 'For Rent'));
      await tester.pump();

      // Assert
      verify(() => mockBloc.add(any(that: isA<UpdateCopy>()))).called(1);
    });

    testWidgets('toggles For Donation checkbox', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.widgetWithText(CheckboxListTile, 'For Donation'));
      await tester.pump();

      // Assert
      verify(() => mockBloc.add(any(that: isA<UpdateCopy>()))).called(1);
    });

    testWidgets('displays sale price field when isForSale is true',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 15.99,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Sale Price'), findsOneWidget);
    });

    testWidgets('displays rent price field when isForRent is true',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: true,
              isForDonate: false,
              expectedPrice: 5.99,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Rent Price'), findsOneWidget);
    });

    testWidgets('displays both price fields when both flags are true',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: true,
              isForRent: true,
              isForDonate: false,
              expectedPrice: 15.99,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Sale Price'), findsOneWidget);
      expect(find.text('Rent Price'), findsOneWidget);
    });

    testWidgets('renders notes field', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Add any additional notes about this copy'), findsOneWidget);
    });

    testWidgets('renders delete button for each copy',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byTooltip('Remove Copy'), findsOneWidget);
    });

    testWidgets('shows remove copy dialog when delete button is tapped',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('renders images section', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Images'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('renders existing images', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [
                'https://example.com/image1.jpg',
                'https://example.com/image2.jpg',
              ],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.byType(Image), findsNWidgets(2));
    });

    testWidgets('shows image picker dialog when add image is tapped',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));
      await tester.tap(find.byIcon(Icons.add_photo_alternate));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('renders remove icon for each image',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [
                'https://example.com/image1.jpg',
              ],
              isForSale: false,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('multiple copies are rendered correctly',
        (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: [
            BookCopy(
              id: '1',
              condition: BookCondition.good,
              imageUrls: const [],
              isForSale: true,
              isForRent: false,
              isForDonate: false,
              expectedPrice: 15.99,
            ),
            BookCopy(
              id: '2',
              condition: BookCondition.likeNew,
              imageUrls: const [],
              isForSale: false,
              isForRent: true,
              isForDonate: false,
              expectedPrice: 5.99,
            ),
            BookCopy(
              id: '3',
              condition: BookCondition.acceptable,
              imageUrls: const [],
              isForSale: false,
              isForRent: false,
              isForDonate: true,
              expectedPrice: 0,
            ),
          ],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(find.text('Copy 1'), findsOneWidget);
      expect(find.text('Copy 2'), findsOneWidget);
      expect(find.text('Copy 3'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsNWidgets(3));
    });

    testWidgets('renders description text', (WidgetTester tester) async {
      // Arrange
      final state = BookUploadLoaded(
        form: const domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(state));

      // Assert
      expect(
          find.text(
              'Add at least one copy of this book with images and details'),
          findsOneWidget);
    });
  });
}
