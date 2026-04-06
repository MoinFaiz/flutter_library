import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_bloc.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_event.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_state.dart';
import 'package:flutter_library/features/book_details/domain/usecases/get_rental_status_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/rent_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/buy_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/return_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/renew_book_usecase.dart';
import 'package:flutter_library/features/book_details/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockGetRentalStatusUseCase extends Mock implements GetRentalStatusUseCase {}
class MockRentBookUseCase extends Mock implements RentBookUseCase {}
class MockBuyBookUseCase extends Mock implements BuyBookUseCase {}
class MockReturnBookUseCase extends Mock implements ReturnBookUseCase {}
class MockRenewBookUseCase extends Mock implements RenewBookUseCase {}
class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}

void main() {
  group('RentalStatusBloc Tests', () {
    late RentalStatusBloc rentalStatusBloc;
    late MockGetRentalStatusUseCase mockGetRentalStatusUseCase;
    late MockRentBookUseCase mockRentBookUseCase;
    late MockBuyBookUseCase mockBuyBookUseCase;
    late MockReturnBookUseCase mockReturnBookUseCase;
    late MockRenewBookUseCase mockRenewBookUseCase;
    late MockRemoveFromCartUseCase mockRemoveFromCartUseCase;


    setUp(() {
      mockGetRentalStatusUseCase = MockGetRentalStatusUseCase();
      mockRentBookUseCase = MockRentBookUseCase();
      mockBuyBookUseCase = MockBuyBookUseCase();
      mockReturnBookUseCase = MockReturnBookUseCase();
      mockRenewBookUseCase = MockRenewBookUseCase();
      mockRemoveFromCartUseCase = MockRemoveFromCartUseCase();
      
      rentalStatusBloc = RentalStatusBloc(
        getRentalStatusUseCase: mockGetRentalStatusUseCase,
        rentBookUseCase: mockRentBookUseCase,
        buyBookUseCase: mockBuyBookUseCase,
        returnBookUseCase: mockReturnBookUseCase,
        renewBookUseCase: mockRenewBookUseCase,
        removeFromCartUseCase: mockRemoveFromCartUseCase,
      );
    });

    blocTest<RentalStatusBloc, RentalStatusState>(
      'emits RentalStatusError when RefreshRentalStatus fails and state is not RentalStatusLoaded',
      build: () {
        when(() => mockGetRentalStatusUseCase('1'))
            .thenAnswer((_) async => const Left(ServerFailure(message: 'refresh failed')));
        return rentalStatusBloc;
      },
      act: (bloc) => bloc.add(const RefreshRentalStatus('1')),
      expect: () => [const RentalStatusError('refresh failed')],
    );

    blocTest<RentalStatusBloc, RentalStatusState>(
      'does nothing when RentBook is called and state is not RentalStatusLoaded',
      build: () => rentalStatusBloc,
      act: (bloc) => bloc.add(const RentBook('1')),
      expect: () => [],
    );

    blocTest<RentalStatusBloc, RentalStatusState>(
      'does nothing when BuyBook is called and state is not RentalStatusLoaded',
      build: () => rentalStatusBloc,
      act: (bloc) => bloc.add(const BuyBook('1')),
      expect: () => [],
    );

    blocTest<RentalStatusBloc, RentalStatusState>(
      'does nothing when ReturnBook is called and state is not RentalStatusLoaded',
      build: () => rentalStatusBloc,
      act: (bloc) => bloc.add(const ReturnBook('1')),
      expect: () => [],
    );

    blocTest<RentalStatusBloc, RentalStatusState>(
      'does nothing when RenewBook is called and state is not RentalStatusLoaded',
      build: () => rentalStatusBloc,
      act: (bloc) => bloc.add(const RenewBook('1')),
      expect: () => [],
    );

    blocTest<RentalStatusBloc, RentalStatusState>(
      'does nothing when RemoveFromCart is called and state is not RentalStatusLoaded',
      build: () => rentalStatusBloc,
      act: (bloc) => bloc.add(const RemoveFromCart('1')),
      expect: () => [],
    );

    tearDown(() {
      rentalStatusBloc.close();
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
    );

    final mockActiveRentalStatus = RentalStatus(
      bookId: '1',
      status: RentalStatusType.rented,
      dueDate: DateTime.now().add(const Duration(days: 14)),
      rentedDate: DateTime.now(),
      canRenew: true,
    );

    test('initial state should be RentalStatusInitial', () {
      expect(rentalStatusBloc.state, const RentalStatusInitial());
    });

    group('LoadRentalStatus', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusLoading, RentalStatusLoaded] when rental status is loaded successfully',
        build: () {
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockRentalStatus));
          return rentalStatusBloc;
        },
        act: (bloc) => bloc.add(const LoadRentalStatus('1')),
        expect: () => [
          const RentalStatusLoading(),
          RentalStatusLoaded(rentalStatus: mockRentalStatus),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusLoading, RentalStatusError] when loading rental status fails',
        build: () {
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return rentalStatusBloc;
        },
        act: (bloc) => bloc.add(const LoadRentalStatus('1')),
        expect: () => [
          const RentalStatusLoading(),
          const RentalStatusError('Server error occurred'),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusLoading, RentalStatusError] when book not found',
        build: () {
          when(() => mockGetRentalStatusUseCase('invalid-id'))
              .thenAnswer((_) async => const Left(ValidationFailure('Book not found')));
          return rentalStatusBloc;
        },
        act: (bloc) => bloc.add(const LoadRentalStatus('invalid-id')),
        expect: () => [
          const RentalStatusLoading(),
          const RentalStatusError('Book not found'),
        ],
      );
    });

    group('RentBook', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusLoaded] when book is rented successfully',
        build: () {
          when(() => mockRentBookUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockActiveRentalStatus));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const RentBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockRentalStatus),
          RentalStatusLoaded(
            rentalStatus: mockActiveRentalStatus,
            actionMessage: 'Book rented successfully',
          ),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusError] when renting book fails',
        build: () {
          when(() => mockRentBookUseCase('1'))
              .thenAnswer((_) async => const Left(ValidationFailure('Book not available for rent')));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const RentBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockRentalStatus),
          const RentalStatusError('Book not available for rent'),
        ],
      );
    });

    group('BuyBook', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusLoaded] when book is bought successfully',
        build: () {
          when(() => mockBuyBookUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(const RentalStatus(
                bookId: '1',
                status: RentalStatusType.purchased,
                isPurchased: true,
              )));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const BuyBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockRentalStatus),
          RentalStatusLoaded(
            rentalStatus: const RentalStatus(
              bookId: '1',
              status: RentalStatusType.purchased,
              isPurchased: true,
            ),
            actionMessage: 'Book purchased successfully',
          ),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusError] when buying book fails',
        build: () {
          when(() => mockBuyBookUseCase('1'))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const BuyBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockRentalStatus),
          const RentalStatusError('Server error occurred'),
        ],
      );
    });

    group('ReturnBook', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusLoaded] when book is returned successfully',
        build: () {
          when(() => mockReturnBookUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          final returnedStatus = RentalStatus(
            bookId: '1',
            status: RentalStatusType.available,
            returnDate: DateTime.now(),
          );
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(returnedStatus));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockActiveRentalStatus),
        act: (bloc) => bloc.add(const ReturnBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockActiveRentalStatus),
          isA<RentalStatusLoaded>()
              .having((s) => s.rentalStatus.status, 'status', RentalStatusType.available)
              .having((s) => s.actionMessage, 'actionMessage', 'Book returned successfully'),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusError] when returning book fails',
        build: () {
          when(() => mockReturnBookUseCase('1'))
              .thenAnswer((_) async => const Left(ValidationFailure('Cannot return book at this time')));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockActiveRentalStatus),
        act: (bloc) => bloc.add(const ReturnBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockActiveRentalStatus),
          const RentalStatusError('Cannot return book at this time'),
        ],
      );
    });

    group('RenewBook', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusLoaded] when book is renewed successfully',
        build: () {
          when(() => mockRenewBookUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          final renewedStatus = RentalStatus(
            bookId: '1',
            status: RentalStatusType.rented,
            dueDate: DateTime.now().add(const Duration(days: 28)),
            canRenew: true,
          );
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(renewedStatus));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockActiveRentalStatus),
        act: (bloc) => bloc.add(const RenewBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockActiveRentalStatus),
          isA<RentalStatusLoaded>()
              .having((s) => s.rentalStatus.status, 'status', RentalStatusType.rented)
              .having((s) => s.rentalStatus.canRenew, 'canRenew', true)
              .having((s) => s.actionMessage, 'actionMessage', 'Book renewed successfully'),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusError] when renewing book fails',
        build: () {
          when(() => mockRenewBookUseCase('1'))
              .thenAnswer((_) async => const Left(ValidationFailure('Book cannot be renewed')));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockActiveRentalStatus),
        act: (bloc) => bloc.add(const RenewBook('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockActiveRentalStatus),
          const RentalStatusError('Book cannot be renewed'),
        ],
      );
    });

    group('RefreshRentalStatus', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusLoaded] when rental status is refreshed successfully',
        build: () {
          final refreshedStatus = RentalStatus(
            bookId: '1',
            status: RentalStatusType.available,
            canRenew: true, // Different from seed
          );
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(refreshedStatus));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const RefreshRentalStatus('1')),
        expect: () => [
          RentalStatusLoaded(rentalStatus: RentalStatus(
            bookId: '1',
            status: RentalStatusType.available,
            canRenew: true,
          )),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusLoaded] when refreshing rental status fails',
        build: () {
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const RefreshRentalStatus('1')),
        expect: () => [
          RentalStatusLoaded(
            rentalStatus: mockRentalStatus,
            actionMessage: 'Failed to refresh rental status: No internet connection',
          ),
        ],
      );
    });

    group('Error handling edge cases', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'handles network failure gracefully',
        build: () {
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return rentalStatusBloc;
        },
        act: (bloc) => bloc.add(const LoadRentalStatus('1')),
        expect: () => [
          const RentalStatusLoading(),
          const RentalStatusError('No internet connection'),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'handles cache failure',
        build: () {
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
          return rentalStatusBloc;
        },
        act: (bloc) => bloc.add(const LoadRentalStatus('1')),
        expect: () => [
          const RentalStatusLoading(),
          const RentalStatusError('Cache error'),
        ],
      );
    });

    group('State transitions', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'maintains rental status data correctly through state transitions',
        build: () {
          // First call during LoadRentalStatus
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockRentalStatus));
          when(() => mockRentBookUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          return rentalStatusBloc;
        },
        act: (bloc) async {
          bloc.add(const LoadRentalStatus('1'));
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Reset the mock for the second call during RentBook
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockActiveRentalStatus));
          
          bloc.add(const RentBook('1'));
        },
        expect: () => [
          const RentalStatusLoading(),
          RentalStatusLoaded(rentalStatus: mockRentalStatus),
          RentalStatusUpdating(rentalStatus: mockRentalStatus),
          RentalStatusLoaded(
            rentalStatus: mockActiveRentalStatus,
            actionMessage: 'Book rented successfully',
          ),
        ],
      );
    });

    group('Rental status validation', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'handles different rental status types correctly',
        build: () {
          final overdueStatus = RentalStatus(
            bookId: '1',
            status: RentalStatusType.overdue,
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            canRenew: false,
            lateFee: 5.00,
          );
          
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(overdueStatus));
          return rentalStatusBloc;
        },
        act: (bloc) => bloc.add(const LoadRentalStatus('1')),
        verify: (bloc) {
          final state = bloc.state;
          if (state is RentalStatusLoaded) {
            expect(state.rentalStatus.status, RentalStatusType.overdue);
            expect(state.rentalStatus.isOverdue, true);
            expect(state.rentalStatus.lateFee, 5.00);
          }
        },
      );
    });

    group('Complex scenarios', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'handles multiple rapid actions correctly',
        build: () {
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockRentalStatus));
          when(() => mockRentBookUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          return rentalStatusBloc;
        },
        act: (bloc) async {
          bloc.add(const LoadRentalStatus('1'));
          
          // Setup additional mock calls
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockRentalStatus));
              
          bloc.add(const RefreshRentalStatus('1'));
          
          // Setup mock for the getRentalStatusUseCase call after rent
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(mockActiveRentalStatus));
              
          bloc.add(const RentBook('1'));
        },
        verify: (bloc) {
          final state = bloc.state;
          expect(state, isA<RentalStatusLoaded>());
        },
      );
    });
    group('RemoveFromCart', () {
      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusLoaded] when book is removed from cart successfully',
        build: () {
          when(() => mockRemoveFromCartUseCase('1'))
              .thenAnswer((_) async => Right(mockBook));
          final removedStatus = RentalStatus(
            bookId: '1',
            status: RentalStatusType.available,
          );
          when(() => mockGetRentalStatusUseCase('1'))
              .thenAnswer((_) async => Right(removedStatus));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const RemoveFromCart('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockRentalStatus),
          isA<RentalStatusLoaded>()
              .having((s) => s.rentalStatus.status, 'status', RentalStatusType.available)
              .having((s) => s.actionMessage, 'actionMessage', 'Book removed from cart'),
        ],
      );

      blocTest<RentalStatusBloc, RentalStatusState>(
        'emits [RentalStatusUpdating, RentalStatusError] when removing from cart fails',
        build: () {
          when(() => mockRemoveFromCartUseCase('1'))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Remove failed')));
          return rentalStatusBloc;
        },
        seed: () => RentalStatusLoaded(rentalStatus: mockRentalStatus),
        act: (bloc) => bloc.add(const RemoveFromCart('1')),
        expect: () => [
          RentalStatusUpdating(rentalStatus: mockRentalStatus),
          const RentalStatusError('Remove failed'),
        ],
      );
    });
  });
}
