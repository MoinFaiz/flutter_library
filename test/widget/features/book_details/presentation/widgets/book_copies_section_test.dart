import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_copies_section.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';

class MockBookUploadBloc extends MockBloc<BookUploadEvent, BookUploadState>
    implements BookUploadBloc {}

void main() {
  group('BookCopiesSection Tests', () {
    late MockBookUploadBloc mockBloc;

    setUp(() {
      mockBloc = MockBookUploadBloc();
    });

    Widget createTestWidget({BookUploadState? state}) {
      when(() => mockBloc.state).thenReturn(
        state ?? const BookUploadLoaded(
          form: BookUploadForm(
            title: 'Test Book',
            isbn: '1234567890',
            author: 'Test Author',
            description: 'Test Description',
            genres: ['Fiction'],
            copies: [],
          ),
          searchResults: [],
          genres: [],
          languages: [],
          isSearching: false,
          isUploadingImage: false,
        ),
      );

      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<BookUploadBloc>(
            create: (context) => mockBloc,
            child: const BookCopiesSection(),
          ),
        ),
      );
    }

    testWidgets('displays section title and add button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Book Copies'), findsOneWidget);
      expect(find.text('Add Copy'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays helper text', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Add at least one copy of this book with images and details'), findsOneWidget);
    });

    testWidgets('does not render when state is not BookUploadLoaded', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(state: const BookUploadInitial()));

      // Assert
      expect(find.text('Book Copies'), findsNothing);
      expect(find.text('Add Copy'), findsNothing);
    });
  });
}
