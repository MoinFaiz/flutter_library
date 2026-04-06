import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_search_section.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_form_section.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_copies_section.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart' as domain;

class MockBookUploadBloc extends MockBloc<BookUploadEvent, BookUploadState>
    implements BookUploadBloc {}

class FakeBookUploadEvent extends Fake implements BookUploadEvent {}

class FakeBookUploadState extends Fake implements BookUploadState {}

void main() {
  group('BookUploadForm Widget Tests', () {
    late MockBookUploadBloc mockBookUploadBloc;

    setUpAll(() {
      registerFallbackValue(FakeBookUploadEvent());
      registerFallbackValue(FakeBookUploadState());
    });

    setUp(() {
      mockBookUploadBloc = MockBookUploadBloc();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<BookUploadBloc>.value(
            value: mockBookUploadBloc,
            child: const BookUploadForm(),
          ),
        ),
      );
    }

    testWidgets('displays loading indicator when in initial state', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadInitial(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays loading indicator when in loading state', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadLoading(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays form sections when in loaded state', (WidgetTester tester) async {
      // Arrange
      const loadedState = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(loadedState),
        initialState: loadedState,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(BookSearchSection), findsOneWidget);
      expect(find.byType(BookFormSection), findsOneWidget);
      expect(find.byType(BookCopiesSection), findsOneWidget);
    });

    testWidgets('shows success snackbar when success message is present', (WidgetTester tester) async {
      // Arrange
      const initialState = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
      );
      const successState = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
        successMessage: 'Book uploaded successfully!',
      );

      whenListen(
        mockBookUploadBloc,
        Stream.fromIterable([successState]),
        initialState: initialState,
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Process the state change

      // Assert
      expect(find.text('Book uploaded successfully!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, isNotNull);
    });

    testWidgets('shows error snackbar when upload error is present', (WidgetTester tester) async {
      // Arrange
      const initialState = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
      );
      const errorState = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
        uploadError: 'Failed to upload book',
      );

      whenListen(
        mockBookUploadBloc,
        Stream.fromIterable([errorState]),
        initialState: initialState,
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Process the state change

      // Assert
      expect(find.text('Failed to upload book'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, isNotNull);
    });

    testWidgets('displays error state correctly', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadError('Network error'),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('triggers retry when retry button is pressed', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadError('Network error'),
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Retry'));

      // Assert
      verify(() => mockBookUploadBloc.add(const InitializeForm())).called(1);
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Arrange
      const loadedState = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: '',
          isbn: '',
          author: '',
          description: '',
          genres: [],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(loadedState),
        initialState: loadedState,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      // The root BookUploadForm has one BlocListener, child widgets may have more
      expect(find.byType(BlocListener<BookUploadBloc, BookUploadState>), findsWidgets);
      expect(find.byType(BlocBuilder<BookUploadBloc, BookUploadState>), findsWidgets);
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });
}
