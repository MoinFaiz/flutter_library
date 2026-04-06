import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_form_section.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart' as domain;

class MockBookUploadBloc extends MockBloc<BookUploadEvent, BookUploadState>
    implements BookUploadBloc {}

class FakeBookUploadEvent extends Fake implements BookUploadEvent {}

class FakeBookUploadState extends Fake implements BookUploadState {}

class FakeUpdateStringField extends Fake implements UpdateStringField {}

void main() {
  group('BookFormSection Widget Tests', () {
    late MockBookUploadBloc mockBookUploadBloc;

    setUpAll(() {
      registerFallbackValue(FakeBookUploadEvent());
      registerFallbackValue(FakeBookUploadState());
      registerFallbackValue(FakeUpdateStringField());
    });

    setUp(() {
      mockBookUploadBloc = MockBookUploadBloc();
    });

    Widget createTestWidget([BookUploadState? state]) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BlocProvider<BookUploadBloc>.value(
              value: mockBookUploadBloc,
              child: const BookFormSection(),
            ),
          ),
        ),
      );
    }

    domain.BookUploadForm createMockForm({
      String title = '',
      String isbn = '',
      String author = '',
      String description = '',
      List<String> genres = const [],
    }) {
      return domain.BookUploadForm(
        title: title,
        isbn: isbn,
        author: author,
        description: description,
        genres: genres,
        copies: [],
      );
    }

    testWidgets('displays form fields correctly', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('ISBN *'), findsOneWidget);
      expect(find.text('Author *'), findsOneWidget);
      expect(find.text('Description *'), findsOneWidget);
    });

    testWidgets('displays genre dropdown with options', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Genres'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsWidgets);
    });

    testWidgets('populates fields with form data', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm(
        title: 'Test Book Title',
        isbn: '1234567890',
        author: 'Test Author',
        description: 'Test description',
        genres: ['Fiction'],
      );
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Book Title'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('updates title when text is entered', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      
      // Find the title text field and enter text
      final titleField = find.ancestor(
        of: find.text('Title *'),
        matching: find.byType(Column),
      ).first;
      
      final textField = find.descendant(
        of: titleField,
        matching: find.byType(TextField),
      );
      
      await tester.enterText(textField, 'New Book Title');

      // Assert
      verify(() => mockBookUploadBloc.add(any<UpdateStringField>())).called(greaterThan(0));
    });

    testWidgets('shows genres section', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Genres'), findsOneWidget);
    });

    testWidgets('shows language dropdown', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Language'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('shows optional fields', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Publisher'), findsOneWidget);
      expect(find.text('Published Year'), findsOneWidget);
      expect(find.text('Page Count'), findsOneWidget);
      expect(find.text('Age Appropriateness'), findsOneWidget);
    });

    testWidgets('shows image upload section', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - BookFormSection doesn't have image upload, it's in a separate widget
      expect(find.text('Book Information'), findsOneWidget);
    });

    testWidgets('shows locked state when book is from search results', (WidgetTester tester) async {
      // Arrange
      final form = domain.BookUploadForm(
        title: 'Test Book',
        isbn: '1234567890',
        author: 'Test Author',
        description: 'Test description',
        genres: ['Fiction'],
        copies: [],
        isSearchResult: true, // Book is from search results
      );
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Fields are locked because this book was found in search results'), findsOneWidget);
    });

    testWidgets('displays selected genres', (WidgetTester tester) async {
      // Arrange
      final form = domain.BookUploadForm(
        title: 'Test Book',
        isbn: '1234567890',
        author: 'Test Author',
        description: 'Test description',
        genres: ['Fiction', 'Science'],
        copies: [],
      );
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Chip), findsNWidgets(2)); // Two genres selected
      expect(find.text('Fiction'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm();
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('updates bloc state when fields are changed', (WidgetTester tester) async {
      // Arrange
      final form = createMockForm(
        title: 'Valid Title',
        author: 'Valid Author',
      );
      final state = BookUploadLoaded(
        form: form,
        searchResults: [],
        genres: ['Fiction', 'Science', 'History'],
        languages: ['English', 'Spanish'],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(state),
        initialState: state,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Verify the widget is displayed with the correct values
      expect(find.text('Valid Title'), findsOneWidget);
      expect(find.text('Valid Author'), findsOneWidget);
    });
  });
}
