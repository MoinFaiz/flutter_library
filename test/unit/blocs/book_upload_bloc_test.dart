import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/search_books_for_upload_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_book_by_isbn_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_book_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_metadata_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_image_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockSearchBooksUseCase extends Mock implements SearchBooksForUploadUseCase {}
class MockGetBookByIsbnUseCase extends Mock implements GetBookByIsbnUseCase {}
class MockUploadBookUseCase extends Mock implements UploadBookUseCase {}
class MockGetGenresUseCase extends Mock implements GetGenresUseCase {}
class MockGetLanguagesUseCase extends Mock implements GetLanguagesUseCase {}
class MockUploadImageUseCase extends Mock implements UploadImageUseCase {}

// Fake classes for mocktail fallback values
class FakeBookUploadForm extends Fake implements BookUploadForm {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBookUploadForm());
  });

  group('BookUploadBloc Tests', () {
    late BookUploadBloc bookUploadBloc;
    late MockSearchBooksUseCase mockSearchBooksUseCase;
    late MockGetBookByIsbnUseCase mockGetBookByIsbnUseCase;
    late MockUploadBookUseCase mockUploadBookUseCase;
    late MockGetGenresUseCase mockGetGenresUseCase;
    late MockGetLanguagesUseCase mockGetLanguagesUseCase;
    late MockUploadImageUseCase mockUploadImageUseCase;

    setUp(() {
      mockSearchBooksUseCase = MockSearchBooksUseCase();
      mockGetBookByIsbnUseCase = MockGetBookByIsbnUseCase();
      mockUploadBookUseCase = MockUploadBookUseCase();
      mockGetGenresUseCase = MockGetGenresUseCase();
      mockGetLanguagesUseCase = MockGetLanguagesUseCase();
      mockUploadImageUseCase = MockUploadImageUseCase();
      
      bookUploadBloc = BookUploadBloc(
        searchBooksUseCase: mockSearchBooksUseCase,
        getBookByIsbnUseCase: mockGetBookByIsbnUseCase,
        uploadBookUseCase: mockUploadBookUseCase,
        uploadImageUseCase: mockUploadImageUseCase,
        getGenresUseCase: mockGetGenresUseCase,
        getLanguagesUseCase: mockGetLanguagesUseCase,
      );
    });

    tearDown(() {
      bookUploadBloc.close();
    });

    final mockBooks = [
      Book(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'Test Description',
        imageUrls: const ['test_url'],
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
          isbn: '978-1234567890',
        ),
        pricing: const BookPricing(
          salePrice: 25.99,
          rentPrice: 5.99,
        ),
        availability: const BookAvailability(
          availableForRentCount: 5,
          availableForSaleCount: 3,
          totalCopies: 8,
        ),
      ),
    ];

    test('initial state should be BookUploadInitial', () {
      expect(bookUploadBloc.state, equals(const BookUploadInitial()));
    });

    blocTest<BookUploadBloc, BookUploadState>(
      'searches for books successfully',
      build: () {
        when(() => mockSearchBooksUseCase.call(any())).thenAnswer(
          (_) async => Right(mockBooks),
        );
        when(() => mockGetGenresUseCase.call()).thenAnswer(
          (_) async => const Right(['Fiction', 'Non-Fiction']),
        );
        when(() => mockGetLanguagesUseCase.call()).thenAnswer(
          (_) async => const Right(['English', 'Spanish']),
        );
        return bookUploadBloc;
      },
      act: (bloc) async {
        bloc.add(const InitializeForm());
        // Wait for initialization to complete
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchBooks('flutter'));
      },
      expect: () => [
        const BookUploadLoading(),
        isA<BookUploadLoaded>(),
        isA<BookUploadLoaded>().having(
          (state) => state.isSearching,
          'isSearching',
          true,
        ),
        isA<BookUploadLoaded>().having(
          (state) => state.searchResults.isNotEmpty,
          'search results not empty',
          true,
        ),
      ],
      verify: (bloc) {
        verify(() => mockSearchBooksUseCase.call('flutter')).called(1);
      },
    );

    blocTest<BookUploadBloc, BookUploadState>(
      'handles search error gracefully',
      build: () {
        when(() => mockSearchBooksUseCase.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Search failed')),
        );
        when(() => mockGetGenresUseCase.call()).thenAnswer(
          (_) async => const Right(['Fiction', 'Non-Fiction']),
        );
        when(() => mockGetLanguagesUseCase.call()).thenAnswer(
          (_) async => const Right(['English', 'Spanish']),
        );
        return bookUploadBloc;
      },
      act: (bloc) async {
        bloc.add(const InitializeForm());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const SearchBooks('flutter'));
      },
      expect: () => [
        const BookUploadLoading(),
        isA<BookUploadLoaded>(),
        isA<BookUploadLoaded>().having(
          (state) => state.isSearching,
          'isSearching',
          true,
        ),
        isA<BookUploadLoaded>().having(
          (state) => state.searchError,
          'search error',
          'Search failed',
        ),
      ],
    );

    blocTest<BookUploadBloc, BookUploadState>(
      'gets book by ISBN successfully',
      build: () {
        when(() => mockGetBookByIsbnUseCase.call(any())).thenAnswer(
          (_) async => Right(mockBooks.first),
        );
        when(() => mockGetGenresUseCase.call()).thenAnswer(
          (_) async => const Right(['Fiction', 'Non-Fiction']),
        );
        when(() => mockGetLanguagesUseCase.call()).thenAnswer(
          (_) async => const Right(['English', 'Spanish']),
        );
        return bookUploadBloc;
      },
      act: (bloc) async {
        bloc.add(const InitializeForm());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const GetBookByIsbn('978-1234567890'));
      },
      expect: () => [
        const BookUploadLoading(),
        isA<BookUploadLoaded>(),
        isA<BookUploadLoaded>().having(
          (state) => state.isSearching,
          'isSearching',
          true,
        ),
        isA<BookUploadLoaded>().having(
          (state) => state.form.title,
          'title filled from ISBN',
          'Test Book',
        ),
      ],
      verify: (bloc) {
        verify(() => mockGetBookByIsbnUseCase.call('978-1234567890')).called(1);
      },
    );

    blocTest<BookUploadBloc, BookUploadState>(
      'handles ISBN lookup error gracefully',
      build: () {
        when(() => mockGetBookByIsbnUseCase.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'ISBN not found')),
        );
        when(() => mockGetGenresUseCase.call()).thenAnswer(
          (_) async => const Right(['Fiction', 'Non-Fiction']),
        );
        when(() => mockGetLanguagesUseCase.call()).thenAnswer(
          (_) async => const Right(['English', 'Spanish']),
        );
        return bookUploadBloc;
      },
      act: (bloc) async {
        bloc.add(const InitializeForm());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const GetBookByIsbn('978-1234567890'));
      },
      expect: () => [
        const BookUploadLoading(),
        isA<BookUploadLoaded>(),
        isA<BookUploadLoaded>().having(
          (state) => state.isSearching,
          'isSearching',
          true,
        ),
        isA<BookUploadLoaded>().having(
          (state) => state.searchError,
          'search error',
          'ISBN not found',
        ),
      ],
    );

    blocTest<BookUploadBloc, BookUploadState>(
      'uploads book successfully',
      build: () {
        when(() => mockUploadBookUseCase.call(any())).thenAnswer(
          (_) async => Right(mockBooks.first),
        );
        when(() => mockGetGenresUseCase.call()).thenAnswer(
          (_) async => const Right(['Fiction', 'Non-Fiction']),
        );
        when(() => mockGetLanguagesUseCase.call()).thenAnswer(
          (_) async => const Right(['English', 'Spanish']),
        );
        return bookUploadBloc;
      },
      seed: () => BookUploadLoaded(
        form: BookUploadForm(
          title: 'Test Book',
          author: 'Test Author',
          description: 'Test Description',
          isbn: '978-1234567890',
          genres: const ['Fiction'],
          copies: const [],
        ),
      ),
      act: (bloc) => bloc.add(const SubmitForm()),
      expect: () => [
        const BookUploadLoading(),
        isA<BookUploadSuccess>(),
      ],
      verify: (bloc) {
        verify(() => mockUploadBookUseCase.call(any())).called(1);
      },
    );

    blocTest<BookUploadBloc, BookUploadState>(
      'handles upload error gracefully',
      build: () {
        when(() => mockUploadBookUseCase.call(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Upload failed')),
        );
        when(() => mockGetGenresUseCase.call()).thenAnswer(
          (_) async => const Right(['Fiction', 'Non-Fiction']),
        );
        when(() => mockGetLanguagesUseCase.call()).thenAnswer(
          (_) async => const Right(['English', 'Spanish']),
        );
        return bookUploadBloc;
      },
      seed: () => BookUploadLoaded(
        form: BookUploadForm(
          title: 'Test Book',
          author: 'Test Author',
          description: 'Test Description',
          isbn: '978-1234567890',
          genres: const ['Fiction'],
          copies: const [],
        ),
      ),
      act: (bloc) => bloc.add(const SubmitForm()),
      expect: () => [
        const BookUploadLoading(),
        const BookUploadError('Upload failed'),
      ],
    );

    blocTest<BookUploadBloc, BookUploadState>(
      'resets to initial state when ResetForm is triggered',
      build: () {
        when(() => mockGetGenresUseCase.call()).thenAnswer(
          (_) async => const Right(['Fiction', 'Non-Fiction']),
        );
        when(() => mockGetLanguagesUseCase.call()).thenAnswer(
          (_) async => const Right(['English', 'Spanish']),
        );
        return bookUploadBloc;
      },
      seed: () => BookUploadLoaded(
        form: BookUploadForm(
          title: 'Test Book',
          isbn: '978-1234567890',
          author: 'Test Author',
          description: 'Test description',
          genres: const ['Fiction'],
          copies: const [],
        ),
        genres: const ['Fiction', 'Non-Fiction'],
        languages: const ['English', 'Spanish'],
      ),
      act: (bloc) => bloc.add(const ResetForm()),
      expect: () => [
        isA<BookUploadLoaded>().having(
          (state) => state.form.title,
          'title reset',
          '',
        ),
      ],
    );

    group('Field Update Events', () {
      blocTest<BookUploadBloc, BookUploadState>(
        'updates string fields correctly',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => [
          bloc.add(const UpdateStringField(field: 'title', value: 'New Title')),
          bloc.add(const UpdateStringField(field: 'isbn', value: '1234567890')),
          bloc.add(const UpdateStringField(field: 'author', value: 'New Author')),
          bloc.add(const UpdateStringField(field: 'description', value: 'New Description')),
        ],
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.form.title, 'title', 'New Title'),
          isA<BookUploadLoaded>().having((state) => state.form.isbn, 'isbn', '1234567890'),
          isA<BookUploadLoaded>().having((state) => state.form.author, 'author', 'New Author'),
          isA<BookUploadLoaded>().having((state) => state.form.description, 'description', 'New Description'),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'updates nullable string fields correctly',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => [
          bloc.add(const UpdateNullableStringField(field: 'publisher', value: 'Test Publisher')),
          bloc.add(const UpdateNullableStringField(field: 'language', value: 'English')),
        ],
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.form.publisher, 'publisher', 'Test Publisher'),
          isA<BookUploadLoaded>().having((state) => state.form.language, 'language', 'English'),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'updates int fields correctly',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => [
          bloc.add(const UpdateIntField(field: 'publishedYear', value: 2023)),
          bloc.add(const UpdateIntField(field: 'pageCount', value: 300)),
          bloc.add(const UpdateIntField(field: 'ageAppropriateness', value: 18)),
        ],
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.form.publishedYear, 'publishedYear', 2023),
          isA<BookUploadLoaded>().having((state) => state.form.pageCount, 'pageCount', 300),
          isA<BookUploadLoaded>().having((state) => state.form.ageAppropriateness, 'ageAppropriateness', 18),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'updates string list fields correctly',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const UpdateStringListField(field: 'genres', value: ['Fiction', 'Drama'])),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.form.genres, 'genres', ['Fiction', 'Drama']),
        ],
      );
    });

    group('Search and Selection Events', () {
      blocTest<BookUploadBloc, BookUploadState>(
        'clears search results when ClearSearchResults is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
          searchResults: mockBooks,
        ),
        act: (bloc) => bloc.add(const ClearSearchResults()),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.searchResults, 'search results cleared', isEmpty),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'selects book from search results when SelectBookFromSearch is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
          searchResults: mockBooks,
        ),
        act: (bloc) => bloc.add(SelectBookFromSearch(mockBooks.first)),
        expect: () => [
          isA<BookUploadLoaded>()
            .having((state) => state.form.title, 'book title set', mockBooks.first.title)
            .having((state) => state.form.isSearchResult, 'is search result', true)
            .having((state) => state.searchResults, 'search results cleared', isEmpty),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'gets book by ISBN successfully when book exists',
        build: () {
          when(() => mockGetBookByIsbnUseCase.call(any())).thenAnswer(
            (_) async => Right(mockBooks.first),
          );
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const GetBookByIsbn('1234567890')),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.isSearching, 'is searching', true),
          isA<BookUploadLoaded>()
            .having((state) => state.form.title, 'book title set', mockBooks.first.title)
            .having((state) => state.form.isSearchResult, 'is search result', true)
            .having((state) => state.isSearching, 'is searching stopped', false),
        ],
        verify: (bloc) {
          verify(() => mockGetBookByIsbnUseCase.call('1234567890')).called(1);
        },
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'updates ISBN when book not found by ISBN',
        build: () {
          when(() => mockGetBookByIsbnUseCase.call(any())).thenAnswer(
            (_) async => const Right(null),
          );
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const GetBookByIsbn('1234567890')),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.isSearching, 'is searching', true),
          isA<BookUploadLoaded>()
            .having((state) => state.form.isbn, 'isbn updated', '1234567890')
            .having((state) => state.isSearching, 'is searching stopped', false),
        ],
        verify: (bloc) {
          verify(() => mockGetBookByIsbnUseCase.call('1234567890')).called(1);
        },
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'handles error when getting book by ISBN fails',
        build: () {
          when(() => mockGetBookByIsbnUseCase.call(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'ISBN lookup failed')),
          );
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const GetBookByIsbn('invalid-isbn')),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.isSearching, 'is searching', true),
          isA<BookUploadLoaded>()
            .having((state) => state.searchError, 'search error', 'ISBN lookup failed')
            .having((state) => state.isSearching, 'is searching stopped', false),
        ],
        verify: (bloc) {
          verify(() => mockGetBookByIsbnUseCase.call('invalid-isbn')).called(1);
        },
      );
    });

    group('Copy Management Events', () {
      blocTest<BookUploadBloc, BookUploadState>(
        'adds new copy when AddNewCopy is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const AddNewCopy()),
        expect: () => [
          isA<BookUploadLoaded>()
            .having((state) => state.form.copies.length, 'copy added', 1)
            .having((state) => state.form.copies.first.condition, 'default condition', BookCondition.good),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'updates copy when UpdateCopy is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm(
            title: '',
            isbn: '',
            author: '',
            description: '',
            genres: [],
            copies: [
              BookCopy(
                imageUrls: const [],
                condition: BookCondition.good,
                isForSale: false,
                isForRent: false,
                isForDonate: false,
              ),
            ],
          ),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(UpdateCopy(
          copyIndex: 0,
          copy: BookCopy(
            imageUrls: const ['test.jpg'],
            condition: BookCondition.new_,
            isForSale: true,
            isForRent: false,
            isForDonate: false,
            expectedPrice: 25.0,
          ),
        )),
        expect: () => [
          isA<BookUploadLoaded>()
            .having((state) => state.form.copies.first.condition, 'condition updated', BookCondition.new_)
            .having((state) => state.form.copies.first.isForSale, 'is for sale updated', true)
            .having((state) => state.form.copies.first.expectedPrice, 'price updated', 25.0),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'removes copy when RemoveCopy is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm(
            title: '',
            isbn: '',
            author: '',
            description: '',
            genres: [],
            copies: [
              BookCopy(
                imageUrls: const [],
                condition: BookCondition.good,
                isForSale: false,
                isForRent: false,
                isForDonate: false,
              ),
              BookCopy(
                imageUrls: const [],
                condition: BookCondition.acceptable,
                isForSale: false,
                isForRent: false,
                isForDonate: false,
              ),
            ],
          ),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const RemoveCopy(0)),
        expect: () => [
          isA<BookUploadLoaded>()
            .having((state) => state.form.copies.length, 'copy removed', 1)
            .having((state) => state.form.copies.first.condition, 'remaining copy', BookCondition.acceptable),
        ],
      );
    });

    group('Image Management Events', () {
      blocTest<BookUploadBloc, BookUploadState>(
        'uploads image successfully when UploadImage is triggered',
        build: () {
          when(() => mockUploadImageUseCase.call(any())).thenAnswer(
            (_) async => const Right('https://example.com/image.jpg'),
          );
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const UploadImage('/path/to/image.jpg')),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.isUploadingImage, 'is uploading', true),
          isA<BookUploadLoaded>().having((state) => state.isUploadingImage, 'upload finished', false),
        ],
        verify: (bloc) {
          verify(() => mockUploadImageUseCase.call('/path/to/image.jpg')).called(1);
        },
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'handles image upload error when UploadImage fails',
        build: () {
          when(() => mockUploadImageUseCase.call(any())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Upload failed')),
          );
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const UploadImage('/path/to/image.jpg')),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.isUploadingImage, 'is uploading', true),
          isA<BookUploadLoaded>()
            .having((state) => state.uploadError, 'upload error', 'Upload failed')
            .having((state) => state.isUploadingImage, 'upload finished', false),
        ],
        verify: (bloc) {
          verify(() => mockUploadImageUseCase.call('/path/to/image.jpg')).called(1);
        },
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'uploads image for copy when UploadImageForCopy is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm(
            title: '',
            isbn: '',
            author: '',
            description: '',
            genres: [],
            copies: [
              BookCopy(
                imageUrls: const [],
                condition: BookCondition.good,
                isForSale: false,
                isForRent: false,
                isForDonate: false,
              ),
            ],
          ),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const UploadImageForCopy(copyIndex: 0, imageUrl: 'https://example.com/image.jpg')),
        expect: () => [
          isA<BookUploadLoaded>()
            .having((state) => state.form.copies.first.imageUrls.length, 'image added', 1)
            .having((state) => state.form.copies.first.imageUrls.first, 'image url', 'https://example.com/image.jpg'),
        ],
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'removes image from copy when RemoveImageFromCopy is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm(
            title: '',
            isbn: '',
            author: '',
            description: '',
            genres: [],
            copies: [
              BookCopy(
                imageUrls: const ['image1.jpg', 'image2.jpg'],
                condition: BookCondition.good,
                isForSale: false,
                isForRent: false,
                isForDonate: false,
              ),
            ],
          ),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const RemoveImageFromCopy(copyIndex: 0, imageIndex: 0)),
        expect: () => [
          isA<BookUploadLoaded>()
            .having((state) => state.form.copies.first.imageUrls.length, 'image removed', 1)
            .having((state) => state.form.copies.first.imageUrls.first, 'remaining image', 'image2.jpg'),
        ],
      );
    });

    group('Metadata Loading Events', () {
      blocTest<BookUploadBloc, BookUploadState>(
        'loads genres when LoadGenres is triggered',
        build: () {
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction', 'Mystery']),
          );
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const LoadGenres()),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.genres, 'genres updated', ['Fiction', 'Non-Fiction', 'Mystery']),
        ],
        verify: (bloc) {
          verify(() => mockGetGenresUseCase.call()).called(1);
        },
      );

      blocTest<BookUploadBloc, BookUploadState>(
        'loads languages when LoadLanguages is triggered',
        build: () {
          when(() => mockGetLanguagesUseCase.call()).thenAnswer(
            (_) async => const Right(['English', 'Spanish', 'French']),
          );
          when(() => mockGetGenresUseCase.call()).thenAnswer(
            (_) async => const Right(['Fiction', 'Non-Fiction']),
          );
          return bookUploadBloc;
        },
        seed: () => BookUploadLoaded(
          form: BookUploadForm.empty(),
          genres: const ['Fiction', 'Non-Fiction'],
          languages: const ['English', 'Spanish'],
        ),
        act: (bloc) => bloc.add(const LoadLanguages()),
        expect: () => [
          isA<BookUploadLoaded>().having((state) => state.languages, 'languages updated', ['English', 'Spanish', 'French']),
        ],
        verify: (bloc) {
          verify(() => mockGetLanguagesUseCase.call()).called(1);
        },
      );
    });
  });
}
