import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_event.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/book_details_state.dart';
import 'package:flutter_library/features/book_details/domain/usecases/rent_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/buy_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/return_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/renew_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_rental_status_usecase.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/home/domain/usecases/get_book_by_id_usecase.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockGetBookByIdUseCase extends Mock implements GetBookByIdUseCase {}
class MockRentBookUseCase extends Mock implements RentBookUseCase {}
class MockBuyBookUseCase extends Mock implements BuyBookUseCase {}
class MockReturnBookUseCase extends Mock implements ReturnBookUseCase {}
class MockRenewBookUseCase extends Mock implements RenewBookUseCase {}
class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}
class MockGetRentalStatusUseCase extends Mock implements GetRentalStatusUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

void main() {
  group('BookDetailsBloc Tests', () {
    late BookDetailsBloc bookDetailsBloc;
    late MockGetBookByIdUseCase mockGetBookByIdUseCase;
    late MockRentBookUseCase mockRentBookUseCase;
    late MockBuyBookUseCase mockBuyBookUseCase;
    late MockReturnBookUseCase mockReturnBookUseCase;
    late MockRenewBookUseCase mockRenewBookUseCase;
    late MockRemoveFromCartUseCase mockRemoveFromCartUseCase;
    late MockGetRentalStatusUseCase mockGetRentalStatusUseCase;
    late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;

    setUp(() {
      mockGetBookByIdUseCase = MockGetBookByIdUseCase();
      mockRentBookUseCase = MockRentBookUseCase();
      mockBuyBookUseCase = MockBuyBookUseCase();
      mockReturnBookUseCase = MockReturnBookUseCase();
      mockRenewBookUseCase = MockRenewBookUseCase();
      mockRemoveFromCartUseCase = MockRemoveFromCartUseCase();
      mockGetRentalStatusUseCase = MockGetRentalStatusUseCase();
      mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
      
      bookDetailsBloc = BookDetailsBloc(
        getBookByIdUseCase: mockGetBookByIdUseCase,
        rentBookUseCase: mockRentBookUseCase,
        buyBookUseCase: mockBuyBookUseCase,
        returnBookUseCase: mockReturnBookUseCase,
        renewBookUseCase: mockRenewBookUseCase,
        removeFromCartUseCase: mockRemoveFromCartUseCase,
        getRentalStatusUseCase: mockGetRentalStatusUseCase,
        toggleFavoriteUseCase: mockToggleFavoriteUseCase,
      );
    });

    tearDown(() {
      bookDetailsBloc.close();
    });

    final mockBook = Book(
      id: '1',
      title: 'Test Book',
      author: 'Test Author',
      imageUrls: ['https://example.com/cover.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 19.99,
        rentPrice: 9.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 5,
        availableForSaleCount: 3,
        totalCopies: 10,
      ),
      metadata: const BookMetadata(
        isbn: '9781234567890',
        publisher: 'Test Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        language: 'English',
        pageCount: 300,
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'A test book description',
      publishedYear: 2023,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockRentalStatus = RentalStatus(
      bookId: '1',
      status: RentalStatusType.available,
      canRenew: false,
      isInCart: false,
      isPurchased: false,
    );

    test('initial state should be BookDetailsInitial', () {
      expect(bookDetailsBloc.state, BookDetailsInitial());
    });

    group('LoadBookDetails', () {
      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits [BookDetailsLoading, BookDetailsLoaded] when book is loaded successfully',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('1')),
        expect: () => [
          BookDetailsLoading(),
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: false,
          ),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits [BookDetailsLoading, BookDetailsError] when loading book fails',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('1')),
        expect: () => [
          BookDetailsLoading(),
          const BookDetailsError('Server error occurred'),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits [BookDetailsLoading, BookDetailsError] when book not found',
        build: () {
          when(() => mockGetBookByIdUseCase('invalid-id'))
              .thenAnswer((_) async => const Left(ValidationFailure('Book not found')));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('invalid-id')),
        expect: () => [
          BookDetailsLoading(),
          const BookDetailsError('Book not found'),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits [BookDetailsLoading, BookDetailsError] when book repository returns null',
        build: () {
          when(() => mockGetBookByIdUseCase('null-book-id'))
              .thenAnswer((_) async => const Right(null));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('null-book-id')),
        expect: () => [
          BookDetailsLoading(),
          const BookDetailsError('Book not found'),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits [BookDetailsLoading, BookDetailsError] when exception is thrown',
        build: () {
          when(() => mockGetBookByIdUseCase('exception-id'))
              .thenThrow(Exception('Database connection error'));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('exception-id')),
        expect: () => [
          BookDetailsLoading(),
          predicate<BookDetailsError>((state) => 
            state.message.contains('Failed to load book details') &&
            state.message.contains('Database connection error')
          ),
        ],
      );
    });

    group('RefreshBookDetails', () {
      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits loading state then loaded state when refresh succeeds',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockRentalStatus));
          return bookDetailsBloc;
        },
        seed: () => BookDetailsLoaded(
          book: mockBook,
          isLoadingRentalStatus: false,
        ),
        act: (bloc) => bloc.add(const RefreshBookDetails('1')),
        expect: () => [
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: true,
          ),
          BookDetailsLoaded(
            book: mockBook,
            rentalStatus: mockRentalStatus,
            isLoadingRentalStatus: false,
          ),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits loading then error states when refreshing book fails',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => const Left(NetworkFailure()));
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockRentalStatus));
          return bookDetailsBloc;
        },
        seed: () => BookDetailsLoaded(
          book: mockBook,
          isLoadingRentalStatus: false,
        ),
        act: (bloc) => bloc.add(const RefreshBookDetails('1')),
        expect: () => [
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: true,
          ),
          const BookDetailsError('No internet connection'),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'emits error when book not found during refresh',
        build: () {
          when(() => mockGetBookByIdUseCase('invalid-id'))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetRentalStatusUseCase('invalid-id'))
              .thenAnswer((_) async => Right(mockRentalStatus));
          return bookDetailsBloc;
        },
        seed: () => BookDetailsLoaded(
          book: mockBook,
          isLoadingRentalStatus: false,
        ),
        act: (bloc) => bloc.add(const RefreshBookDetails('invalid-id')),
        expect: () => [
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: true,
          ),
          const BookDetailsError('Book not found'),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'handles partial failure in rental status during refresh',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return bookDetailsBloc;
        },
        seed: () => BookDetailsLoaded(
          book: mockBook,
          rentalStatus: mockRentalStatus,
          isLoadingRentalStatus: false,
        ),
        act: (bloc) => bloc.add(const RefreshBookDetails('1')),
        expect: () => [
          BookDetailsLoaded(
            book: mockBook,
            rentalStatus: mockRentalStatus,
            isLoadingRentalStatus: true,
          ),
          BookDetailsLoaded(
            book: mockBook,
            rentalStatus: mockRentalStatus, // Keeps previous rental status on failure
            isLoadingRentalStatus: false,
          ),
        ],
      );
    });

    group('ToggleFavorite', () {
      blocTest<BookDetailsBloc, BookDetailsState>(
        'updates book favorite status when toggle succeeds',
        build: () {
          when(() => mockToggleFavoriteUseCase('1'))
              .thenAnswer((_) async => const Right(true));
          return bookDetailsBloc;
        },
        seed: () => BookDetailsLoaded(
          book: mockBook,
          isLoadingRentalStatus: false,
        ),
        act: (bloc) => bloc.add(const ToggleFavorite('1')),
        expect: () => [
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: false,
            isPerformingAction: true,
          ),
          BookDetailsLoaded(
            book: mockBook.copyWith(isFavorite: true),
            isLoadingRentalStatus: false,
            isPerformingAction: false,
            actionMessage: 'Added to favorites',
          ),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'shows error message when toggle favorite fails',
        build: () {
          when(() => mockToggleFavoriteUseCase('1'))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return bookDetailsBloc;
        },
        seed: () => BookDetailsLoaded(
          book: mockBook,
          isLoadingRentalStatus: false,
        ),
        act: (bloc) => bloc.add(const ToggleFavorite('1')),
        expect: () => [
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: false,
            isPerformingAction: true,
          ),
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: false,
            isPerformingAction: false,
            actionMessage: 'Failed to toggle favorite: Server error occurred',
          ),
        ],
      );
    });

    group('Error handling edge cases', () {
      blocTest<BookDetailsBloc, BookDetailsState>(
        'handles network failure gracefully',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('1')),
        expect: () => [
          BookDetailsLoading(),
          const BookDetailsError('No internet connection'),
        ],
      );

      blocTest<BookDetailsBloc, BookDetailsState>(
        'handles cache failure',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('1')),
        expect: () => [
          BookDetailsLoading(),
          const BookDetailsError('Cache error'),
        ],
      );
    });

    group('State transitions', () {
      blocTest<BookDetailsBloc, BookDetailsState>(
        'maintains book data correctly through state transitions',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          when(() => mockToggleFavoriteUseCase('1'))
              .thenAnswer((_) async => const Right(true));
          return bookDetailsBloc;
        },
        act: (bloc) async {
          bloc.add(const LoadBookDetails('1'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const ToggleFavorite('1'));
        },
        expect: () => [
          BookDetailsLoading(),
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: false,
          ),
          BookDetailsLoaded(
            book: mockBook,
            isLoadingRentalStatus: false,
            isPerformingAction: true,
          ),
          BookDetailsLoaded(
            book: mockBook.copyWith(isFavorite: true),
            isLoadingRentalStatus: false,
            isPerformingAction: false,
            actionMessage: 'Added to favorites',
          ),
        ],
      );
    });

    group('Book availability', () {
      blocTest<BookDetailsBloc, BookDetailsState>(
        'loads book with no available copies',
        build: () {
          final unavailableBook = mockBook.copyWith(
            availability: const BookAvailability(
              availableForRentCount: 0,
              availableForSaleCount: 0,
              totalCopies: 10,
            ),
          );
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => Right(unavailableBook));
          return bookDetailsBloc;
        },
        act: (bloc) => bloc.add(const LoadBookDetails('1')),
        verify: (bloc) {
          final state = bloc.state;
          if (state is BookDetailsLoaded) {
            expect(state.book.availability.totalAvailable, 0);
            expect(state.book.id, '1');
            expect(state.book.availability.isOutOfStock, true);
          }
        },
      );
    });

    group('Complex scenarios', () {
      blocTest<BookDetailsBloc, BookDetailsState>(
        'handles multiple rapid state changes correctly',
        build: () {
          when(() => mockGetBookByIdUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          when(() => mockToggleFavoriteUseCase('1'))
              .thenAnswer((_) async => const Right(true));
          return bookDetailsBloc;
        },
        act: (bloc) async {
          bloc.add(const LoadBookDetails('1'));
          bloc.add(const RefreshBookDetails('1'));
          bloc.add(const ToggleFavorite('1'));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<BookDetailsLoaded>());
        },
      );
    });
  });
}
