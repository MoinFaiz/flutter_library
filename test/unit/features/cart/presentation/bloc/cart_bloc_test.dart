import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_items_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_cart_total_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/get_received_requests_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/send_purchase_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/send_rental_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_request_usecase.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_event.dart';
import 'package:flutter_library/features/cart/presentation/bloc/cart_state.dart';

class MockGetCartItemsUseCase extends Mock implements GetCartItemsUseCase {}
class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}
class MockRemoveFromCartUseCase extends Mock implements RemoveFromCartUseCase {}
class MockSendRentalRequestUseCase extends Mock implements SendRentalRequestUseCase {}
class MockSendPurchaseRequestUseCase extends Mock implements SendPurchaseRequestUseCase {}
class MockGetReceivedRequestsUseCase extends Mock implements GetReceivedRequestsUseCase {}
class MockAcceptRequestUseCase extends Mock implements AcceptRequestUseCase {}
class MockRejectRequestUseCase extends Mock implements RejectRequestUseCase {}
class MockGetCartTotalUseCase extends Mock implements GetCartTotalUseCase {}

Book createMockBook() {
  return Book(
    id: 'book1',
    title: 'Test Book',
    author: 'Test Author',
    imageUrls: const ['https://example.com/image.jpg'],
    rating: 4.5,
    pricing: const BookPricing(salePrice: 29.99, rentPrice: 9.99),
    availability: const BookAvailability(
      availableForRentCount: 1,
      availableForSaleCount: 1,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      genres: ['Fiction'],
      pageCount: 200,
      language: 'English',
      ageAppropriateness: AgeAppropriateness.adult,
    ),
    isFromFriend: false,
    isFavorite: false,
    description: 'Test Description',
    publishedYear: 2025,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );
}

void main() {
  late CartBloc cartBloc;
  late MockGetCartItemsUseCase mockGetCartItemsUseCase;
  late MockAddToCartUseCase mockAddToCartUseCase;
  late MockRemoveFromCartUseCase mockRemoveFromCartUseCase;
  late MockSendRentalRequestUseCase mockSendRentalRequestUseCase;
  late MockSendPurchaseRequestUseCase mockSendPurchaseRequestUseCase;
  late MockGetReceivedRequestsUseCase mockGetReceivedRequestsUseCase;
  late MockAcceptRequestUseCase mockAcceptRequestUseCase;
  late MockRejectRequestUseCase mockRejectRequestUseCase;
  late MockGetCartTotalUseCase mockGetCartTotalUseCase;

  setUpAll(() {
    registerFallbackValue(AddToCartParams(bookId: '', type: CartItemType.rent));
    registerFallbackValue(SendRentalRequestParams(bookId: ''));
  });

  setUp(() {
    mockGetCartItemsUseCase = MockGetCartItemsUseCase();
    mockAddToCartUseCase = MockAddToCartUseCase();
    mockRemoveFromCartUseCase = MockRemoveFromCartUseCase();
    mockSendRentalRequestUseCase = MockSendRentalRequestUseCase();
    mockSendPurchaseRequestUseCase = MockSendPurchaseRequestUseCase();
    mockGetReceivedRequestsUseCase = MockGetReceivedRequestsUseCase();
    mockAcceptRequestUseCase = MockAcceptRequestUseCase();
    mockRejectRequestUseCase = MockRejectRequestUseCase();
    mockGetCartTotalUseCase = MockGetCartTotalUseCase();

    cartBloc = CartBloc(
      getCartItemsUseCase: mockGetCartItemsUseCase,
      addToCartUseCase: mockAddToCartUseCase,
      removeFromCartUseCase: mockRemoveFromCartUseCase,
      sendRentalRequestUseCase: mockSendRentalRequestUseCase,
      sendPurchaseRequestUseCase: mockSendPurchaseRequestUseCase,
      getReceivedRequestsUseCase: mockGetReceivedRequestsUseCase,
      acceptRequestUseCase: mockAcceptRequestUseCase,
      rejectRequestUseCase: mockRejectRequestUseCase,
      getCartTotalUseCase: mockGetCartTotalUseCase,
    );
  });

  tearDown(() {
    cartBloc.close();
  });

  group('CartBloc', () {
    test('initial state should be CartInitial', () {
      expect(cartBloc.state, equals(CartInitial()));
    });

    group('LoadCartItems', () {
      final mockCartItems = <CartItem>[];
      const mockTotal = 25.0;

      blocTest<CartBloc, CartState>(
        'emits [CartLoading, CartLoaded] when LoadCartItems succeeds',
        build: () {
          when(() => mockGetCartItemsUseCase())
              .thenAnswer((_) async => Right(mockCartItems));
          when(() => mockGetCartTotalUseCase())
              .thenAnswer((_) async => const Right(mockTotal));
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Right([]));
          return cartBloc;
        },
        act: (bloc) => bloc.add(LoadCartItems()),
        expect: () => [
          CartLoading(),
          CartLoaded(
            items: mockCartItems,
            total: mockTotal,
            receivedRequests: const [],
          ),
        ],
        verify: (_) {
          verify(() => mockGetCartItemsUseCase()).called(1);
          verify(() => mockGetCartTotalUseCase()).called(1);
          verify(() => mockGetReceivedRequestsUseCase()).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits [CartLoading, CartError] when LoadCartItems fails',
        build: () {
          when(() => mockGetCartItemsUseCase())
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Error')));
          when(() => mockGetCartTotalUseCase())
              .thenAnswer((_) async => const Right(0.0));
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Right([]));
          return cartBloc;
        },
        act: (bloc) => bloc.add(LoadCartItems()),
        expect: () => [
          CartLoading(),
          const CartError('Error'),
        ],
      );
    });

    group('RefreshCart', () {
      final mockCartItems = <CartItem>[];

      blocTest<CartBloc, CartState>(
        'triggers LoadCartItems when cart is loaded',
        build: () {
          when(() => mockGetCartItemsUseCase())
              .thenAnswer((_) async => Right(mockCartItems));
          when(() => mockGetCartTotalUseCase())
              .thenAnswer((_) async => const Right(0.0));
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Right([]));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(RefreshCart()),
        expect: () => [
          CartRefreshing(mockCartItems),
          CartLoading(),
          CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: const []),
        ],
      );
    });

    group('AddItemToCart', () {
      final mockCartItems = <CartItem>[];
      const mockTotal = 25.0;

      blocTest<CartBloc, CartState>(
        'reloads cart when AddItemToCart succeeds',
        build: () {
          when(() => mockAddToCartUseCase(any()))
              .thenAnswer((_) async => Right(CartItem(
                id: '1',
                book: createMockBook(),
                type: CartItemType.rent,
                addedAt: DateTime.now(),
              )));
          when(() => mockGetCartItemsUseCase())
              .thenAnswer((_) async => Right(mockCartItems));
          when(() => mockGetCartTotalUseCase())
              .thenAnswer((_) async => const Right(mockTotal));
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Right([]));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const AddItemToCart(bookId: 'book1', type: CartItemType.rent)),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoading(),
          CartLoaded(items: mockCartItems, total: mockTotal, receivedRequests: const []),
        ],
        verify: (_) {
          verify(() => mockAddToCartUseCase(any())).called(1);
          verify(() => mockGetCartItemsUseCase()).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits error when AddItemToCart fails',
        build: () {
          when(() => mockAddToCartUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to add')));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const AddItemToCart(bookId: 'book1', type: CartItemType.rent)),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartError('Failed to add'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
      );
    });

    group('RemoveItemFromCart', () {
      final mockCartItems = <CartItem>[];
      const mockTotal = 25.0;

      blocTest<CartBloc, CartState>(
        'reloads cart when RemoveItemFromCart succeeds',
        build: () {
          when(() => mockRemoveFromCartUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetCartItemsUseCase())
              .thenAnswer((_) async => Right(mockCartItems));
          when(() => mockGetCartTotalUseCase())
              .thenAnswer((_) async => const Right(mockTotal));
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Right([]));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const RemoveItemFromCart('item1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoading(),
          CartLoaded(items: mockCartItems, total: mockTotal, receivedRequests: const []),
        ],
        verify: (_) {
          verify(() => mockRemoveFromCartUseCase('item1')).called(1);
          verify(() => mockGetCartItemsUseCase()).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits error when RemoveItemFromCart fails',
        build: () {
          when(() => mockRemoveFromCartUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to remove')));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const RemoveItemFromCart('item1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartError('Failed to remove'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
      );
    });

    group('SendRentalRequest', () {
      final mockCartItems = <CartItem>[];

      blocTest<CartBloc, CartState>(
        'emits success when SendRentalRequest succeeds',
        build: () {
          when(() => mockSendRentalRequestUseCase(any()))
              .thenAnswer((_) async => Right(CartRequest(
                id: '1',
                bookId: 'book1',
                bookTitle: 'Test Book',
                bookAuthor: 'Test Author',
                bookImageUrl: '',
                requesterId: 'user1',
                ownerId: 'owner1',
                requestType: CartItemType.rent,
                rentalPeriodInDays: 14,
                price: 10.0,
                status: RequestStatus.pending,
                createdAt: DateTime.now(),
              )));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const SendRentalRequest(bookId: 'book1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartOperationSuccess('Rental request sent successfully'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
        verify: (_) {
          verify(() => mockSendRentalRequestUseCase(any())).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits error when SendRentalRequest fails',
        build: () {
          when(() => mockSendRentalRequestUseCase(any()))
              .thenAnswer((_) async => const Left(NetworkFailure(message: 'Network error')));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const SendRentalRequest(bookId: 'book1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartError('Network error'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
      );
    });

    group('SendPurchaseRequest', () {
      final mockCartItems = <CartItem>[];

      blocTest<CartBloc, CartState>(
        'emits success when SendPurchaseRequest succeeds',
        build: () {
          when(() => mockSendPurchaseRequestUseCase(any()))
              .thenAnswer((_) async => Right(CartRequest(
                id: '1',
                bookId: 'book1',
                bookTitle: 'Test Book',
                bookAuthor: 'Test Author',
                bookImageUrl: '',
                requesterId: 'user1',
                ownerId: 'owner1',
                requestType: CartItemType.purchase,
                rentalPeriodInDays: 0,
                price: 25.0,
                status: RequestStatus.pending,
                createdAt: DateTime.now(),
              )));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const SendPurchaseRequest('book1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartOperationSuccess('Purchase request sent successfully'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
        verify: (_) {
          verify(() => mockSendPurchaseRequestUseCase('book1')).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits error when SendPurchaseRequest fails',
        build: () {
          when(() => mockSendPurchaseRequestUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const SendPurchaseRequest('book1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartError('Server error'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
      );
    });

    group('AcceptBookRequest', () {
      final mockCartItems = <CartItem>[];
      final mockRequests = [
        CartRequest(
          id: 'req1',
          bookId: 'book1',
          bookTitle: 'Test',
          bookAuthor: 'Author',
          bookImageUrl: '',
          requesterId: 'user1',
          ownerId: 'owner1',
          requestType: CartItemType.rent,
          rentalPeriodInDays: 14,
          price: 10.0,
          status: RequestStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      blocTest<CartBloc, CartState>(
        'reloads requests when AcceptBookRequest succeeds',
        build: () {
          when(() => mockAcceptRequestUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Right([]));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: mockRequests),
        act: (bloc) => bloc.add(const AcceptBookRequest('req1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: mockRequests, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: mockRequests, isProcessing: false),
          const CartOperationSuccess('Request accepted successfully'),
        ],
        verify: (_) {
          verify(() => mockAcceptRequestUseCase('req1')).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits error when AcceptBookRequest fails',
        build: () {
          when(() => mockAcceptRequestUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to accept')));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const AcceptBookRequest('req1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartError('Failed to accept'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
      );
    });

    group('RejectBookRequest', () {
      final mockCartItems = <CartItem>[];
      final mockRequests = [
        CartRequest(
          id: 'req1',
          bookId: 'book1',
          bookTitle: 'Test',
          bookAuthor: 'Author',
          bookImageUrl: '',
          requesterId: 'user1',
          ownerId: 'owner1',
          requestType: CartItemType.rent,
          rentalPeriodInDays: 14,
          price: 10.0,
          status: RequestStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      blocTest<CartBloc, CartState>(
        'reloads requests when RejectBookRequest succeeds',
        build: () {
          when(() => mockRejectRequestUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Right([]));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: mockRequests),
        act: (bloc) => bloc.add(const RejectBookRequest('req1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: mockRequests, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: mockRequests, isProcessing: false),
          const CartOperationSuccess('Request rejected'),
        ],
        verify: (_) {
          verify(() => mockRejectRequestUseCase('req1')).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits error when RejectBookRequest fails',
        build: () {
          when(() => mockRejectRequestUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'Failed to reject')));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(const RejectBookRequest('req1')),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: true),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
          const CartError('Failed to reject'),
          CartLoaded(items: mockCartItems, total: 0.0, isProcessing: false),
        ],
      );
    });

    group('LoadReceivedRequests', () {
      final mockCartItems = <CartItem>[];
      final mockRequests = [
        CartRequest(
          id: 'req1',
          bookId: 'book1',
          bookTitle: 'Test',
          bookAuthor: 'Author',
          bookImageUrl: '',
          requesterId: 'user1',
          ownerId: 'owner1',
          requestType: CartItemType.rent,
          rentalPeriodInDays: 14,
          price: 10.0,
          status: RequestStatus.pending,
          createdAt: DateTime.now(),
        ),
      ];

      blocTest<CartBloc, CartState>(
        'updates received requests when LoadReceivedRequests succeeds',
        build: () {
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => Right(mockRequests));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(LoadReceivedRequests()),
        expect: () => [
          CartLoaded(items: mockCartItems, total: 0.0, receivedRequests: mockRequests),
        ],
        verify: (_) {
          verify(() => mockGetReceivedRequestsUseCase()).called(1);
        },
      );

      blocTest<CartBloc, CartState>(
        'emits error when LoadReceivedRequests fails',
        build: () {
          when(() => mockGetReceivedRequestsUseCase())
              .thenAnswer((_) async => const Left(NetworkFailure(message: 'Network error')));
          return cartBloc;
        },
        seed: () => CartLoaded(items: mockCartItems, total: 0.0),
        act: (bloc) => bloc.add(LoadReceivedRequests()),
        expect: () => [
          const CartError('Network error'),
        ],
      );
    });
  });
}
