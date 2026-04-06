import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/book_upload/presentation/pages/add_book_page.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart' as domain;

class MockBookUploadBloc extends MockBloc<BookUploadEvent, BookUploadState>
    implements BookUploadBloc {}

class FakeBookUploadEvent extends Fake implements BookUploadEvent {}

class FakeBookUploadState extends Fake implements BookUploadState {}

void main() {
  late MockBookUploadBloc mockBookUploadBloc;

  setUpAll(() {
    registerFallbackValue(const InitializeForm());
    registerFallbackValue(const ResetForm());
    registerFallbackValue(FakeBookUploadEvent());
    registerFallbackValue(FakeBookUploadState());
  });

  setUp(() {
    mockBookUploadBloc = MockBookUploadBloc();

    // Setup GetIt
    if (GetIt.instance.isRegistered<BookUploadBloc>()) {
      GetIt.instance.unregister<BookUploadBloc>();
    }
    GetIt.instance.registerFactory<BookUploadBloc>(() => mockBookUploadBloc);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return const MaterialApp(
      home: AddBookPage(),
    );
  }

  group('AddBookPage Tests', () {
    testWidgets('renders correctly with proper structure', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadInitial(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(AddBookPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Add Book'), findsOneWidget);
    });

    testWidgets('initializes form on page creation', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadInitial(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      verify(() => mockBookUploadBloc.add(const InitializeForm())).called(1);
    });

    testWidgets('contains BookUploadForm widget', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadInitial(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(BookUploadForm), findsOneWidget);
    });

    testWidgets('shows reset button when form has data', (WidgetTester tester) async {
      // Arrange
      const stateWithData = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: 'Test Book',
          isbn: '1234567890',
          author: 'Test Author',
          description: 'Test description',
          genres: ['Fiction'],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(stateWithData),
        initialState: stateWithData,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byTooltip('Reset Form'), findsOneWidget);
    });

    testWidgets('hides reset button when form has no data', (WidgetTester tester) async {
      // Arrange
      const stateWithoutData = BookUploadLoaded(
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
        Stream<BookUploadState>.value(stateWithoutData),
        initialState: stateWithoutData,
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('triggers reset form when reset button pressed', (WidgetTester tester) async {
      // Arrange
      const stateWithData = BookUploadLoaded(
        form: domain.BookUploadForm(
          title: 'Test Book',
          isbn: '1234567890',
          author: 'Test Author',
          description: 'Test description',
          genres: ['Fiction'],
          copies: [],
        ),
        searchResults: [],
        genres: [],
        languages: [],
      );
      whenListen(
        mockBookUploadBloc,
        Stream<BookUploadState>.value(stateWithData),
        initialState: stateWithData,
      );

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.byIcon(Icons.refresh));

      // Assert
      verify(() => mockBookUploadBloc.add(const ResetForm())).called(1);
    });

    testWidgets('creates BlocProvider with correct bloc', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadInitial(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(BlocProvider<BookUploadBloc>), findsOneWidget);
    });

    testWidgets('has proper app bar title', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadInitial(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final title = appBar.title as Text;
      expect(title.data, equals('Add Book'));
    });

    testWidgets('has proper widget hierarchy', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadInitial(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(AddBookPage), findsOneWidget);
      expect(find.byType(BlocProvider<BookUploadBloc>), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(BookUploadForm), findsOneWidget);
    });

    testWidgets('handles loading state correctly', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadLoading(),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(BookUploadForm), findsOneWidget);
      expect(tester.takeException(), isNull); // No exceptions
    });

    testWidgets('handles error state correctly', (WidgetTester tester) async {
      // Arrange
      whenListen(
        mockBookUploadBloc,
        const Stream<BookUploadState>.empty(),
        initialState: const BookUploadError('Test error'),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(BookUploadForm), findsOneWidget);
      expect(tester.takeException(), isNull); // No exceptions
    });
  });
}
