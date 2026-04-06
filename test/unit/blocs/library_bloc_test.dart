import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_bloc.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_event.dart';
import 'package:flutter_library/features/library/presentation/bloc/library_state.dart';
import 'package:flutter_library/features/library/domain/usecases/get_borrowed_books_usecase.dart';
import 'package:flutter_library/features/library/domain/usecases/get_uploaded_books_usecase.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockGetBorrowedBooksUseCase extends Mock implements GetBorrowedBooksUseCase {}
class MockGetUploadedBooksUseCase extends Mock implements GetUploadedBooksUseCase {}

void main() {
  group('LibraryBloc Tests', () {
    late LibraryBloc libraryBloc;
    late MockGetBorrowedBooksUseCase mockGetBorrowedBooksUseCase;
    late MockGetUploadedBooksUseCase mockGetUploadedBooksUseCase;

    setUp(() {
      mockGetBorrowedBooksUseCase = MockGetBorrowedBooksUseCase();
      mockGetUploadedBooksUseCase = MockGetUploadedBooksUseCase();
      
      libraryBloc = LibraryBloc(
        getBorrowedBooksUseCase: mockGetBorrowedBooksUseCase,
        getUploadedBooksUseCase: mockGetUploadedBooksUseCase,
      );
    });

    tearDown(() {
      libraryBloc.close();
    });

    final mockBorrowedBooks = [
      Book(
        id: '1',
        title: 'Borrowed Book 1',
        author: 'Author 1',
        description: 'Description 1',
        imageUrls: const ['image1.jpg'],
        rating: 4.5,
        publishedYear: 2023,
        isFavorite: false,
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

    final mockUploadedBooks = [
      Book(
        id: '2',
        title: 'Uploaded Book 1',
        author: 'Author 2',
        description: 'Description 2',
        imageUrls: const ['image2.jpg'],
        rating: 4.0,
        publishedYear: 2022,
        isFavorite: false,
        isFromFriend: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: const BookMetadata(
          ageAppropriateness: AgeAppropriateness.youngAdult,
          genres: ['Science'],
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

    test('initial state should be LibraryInitial', () {
      expect(libraryBloc.state, equals(LibraryInitial()));
    });

    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryLoaded] when LoadLibrary succeeds',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockBorrowedBooks),
        );
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockUploadedBooks),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const RefreshLibrary()),
      expect: () => [
        LibraryLoading(),
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
        ),
      ],
      verify: (bloc) {
        verify(() => mockGetBorrowedBooksUseCase.call(limit: 5)).called(1);
        verify(() => mockGetUploadedBooksUseCase.call(limit: 5)).called(1);
      },
    );

    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryError] when LoadLibrary fails',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Failed to load borrowed books')),
        );
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockUploadedBooks),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const RefreshLibrary()),
      expect: () => [
        LibraryLoading(),
        const LibraryError('Failed to load borrowed books'),
      ],
    );

    blocTest<LibraryBloc, LibraryState>(
      'refreshes library when RefreshLibrary is called',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockBorrowedBooks),
        );
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockUploadedBooks),
        );
        return libraryBloc;
      },
      seed: () => LibraryLoaded(
        borrowedBooks: mockBorrowedBooks,
        uploadedBooks: mockUploadedBooks,
      ),
      act: (bloc) => bloc.add(const RefreshLibrary()),
      expect: () => [
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
          isRefreshing: true,
        ),
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
          isRefreshing: false,
        ),
      ],
    );

    // Loads only borrowed books from LibraryLoaded state
    blocTest<LibraryBloc, LibraryState>(
      'loads only borrowed books when LoadBorrowedBooks is called',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockBorrowedBooks),
        );
        return libraryBloc;
      },
      seed: () => LibraryLoaded(
        borrowedBooks: [],
        uploadedBooks: mockUploadedBooks,
      ),
      act: (bloc) => bloc.add(const LoadBorrowedBooks()),
      expect: () => [
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
        ),
      ],
      verify: (bloc) {
        verify(() => mockGetBorrowedBooksUseCase.call(limit: 5)).called(1);
      },
    );

    // Loads only borrowed books from initial state
    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryLoaded] when LoadBorrowedBooks is called from initial state',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockBorrowedBooks),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const LoadBorrowedBooks()),
      expect: () => [
        LibraryLoading(),
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: const [],
        ),
      ],
    );

    // Error when loading borrowed books from initial state
    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryError] when LoadBorrowedBooks fails from initial state',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Failed to load borrowed books')),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const LoadBorrowedBooks()),
      expect: () => [
        LibraryLoading(),
        const LibraryError('Failed to load borrowed books'),
      ],
    );

    // Loads only uploaded books from LibraryLoaded state
    blocTest<LibraryBloc, LibraryState>(
      'loads only uploaded books when LoadUploadedBooks is called',
      build: () {
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockUploadedBooks),
        );
        return libraryBloc;
      },
      seed: () => LibraryLoaded(
        borrowedBooks: mockBorrowedBooks,
        uploadedBooks: [],
      ),
      act: (bloc) => bloc.add(const LoadUploadedBooks()),
      expect: () => [
        LibraryLoaded(
          borrowedBooks: mockBorrowedBooks,
          uploadedBooks: mockUploadedBooks,
        ),
      ],
      verify: (bloc) {
        verify(() => mockGetUploadedBooksUseCase.call(limit: 5)).called(1);
      },
    );

    // Loads only uploaded books from initial state
    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryLoaded] when LoadUploadedBooks is called from initial state',
      build: () {
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockUploadedBooks),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const LoadUploadedBooks()),
      expect: () => [
        LibraryLoading(),
        LibraryLoaded(
          borrowedBooks: const [],
          uploadedBooks: mockUploadedBooks,
        ),
      ],
    );

    // Error when loading uploaded books from initial state
    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryError] when LoadUploadedBooks fails from initial state',
      build: () {
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Failed to load uploaded books')),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const LoadUploadedBooks()),
      expect: () => [
        LibraryLoading(),
        const LibraryError('Failed to load uploaded books'),
      ],
    );

    // RefreshLibrary: uploaded books fail, borrowed books succeed
    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryError] when RefreshLibrary fails to load uploaded books',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => Right(mockBorrowedBooks),
        );
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Failed to load uploaded books')),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const RefreshLibrary()),
      expect: () => [
        LibraryLoading(),
        const LibraryError('Failed to load uploaded books'),
      ],
    );

    // RefreshLibrary: both borrowed and uploaded books fail
    blocTest<LibraryBloc, LibraryState>(
      'emits [LibraryLoading, LibraryError] when RefreshLibrary fails to load both borrowed and uploaded books',
      build: () {
        when(() => mockGetBorrowedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Failed to load borrowed books')),
        );
        when(() => mockGetUploadedBooksUseCase.call(limit: 5)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Failed to load uploaded books')),
        );
        return libraryBloc;
      },
      act: (bloc) => bloc.add(const RefreshLibrary()),
      expect: () => [
        LibraryLoading(),
        const LibraryError('Failed to load borrowed books'),
      ],
    );
  });
}
