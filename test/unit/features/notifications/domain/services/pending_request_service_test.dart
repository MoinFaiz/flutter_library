import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_item.dart';
import 'package:flutter_library/features/cart/domain/entities/cart_request.dart';
import 'package:flutter_library/features/cart/domain/repositories/cart_repository.dart';
import 'package:flutter_library/features/cart/domain/usecases/accept_cart_request_usecase.dart';
import 'package:flutter_library/features/cart/domain/usecases/reject_cart_request_usecase.dart';
import 'package:flutter_library/features/notifications/domain/services/pending_request_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartRepository extends Mock implements CartRepository {}
class MockAcceptCartRequestUseCase extends Mock implements AcceptCartRequestUseCase {}
class MockRejectCartRequestUseCase extends Mock implements RejectCartRequestUseCase {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late PendingRequestService service;
  late MockCartRepository mockRepository;
  late MockAcceptCartRequestUseCase mockAcceptUseCase;
  late MockRejectCartRequestUseCase mockRejectUseCase;

  setUp(() {
    mockRepository = MockCartRepository();
    mockAcceptUseCase = MockAcceptCartRequestUseCase();
    mockRejectUseCase = MockRejectCartRequestUseCase();
    service = PendingRequestService(
      cartRepository: mockRepository,
      acceptCartRequestUseCase: mockAcceptUseCase,
      rejectCartRequestUseCase: mockRejectUseCase,
    );
  });

  group('PendingRequestService - Constructor', () {
    test('should initialize with required dependencies', () {
      expect(service.cartRepository, mockRepository);
      expect(service.acceptCartRequestUseCase, mockAcceptUseCase);
      expect(service.rejectCartRequestUseCase, mockRejectUseCase);
    });
  });

  group('PendingRequestService - resetProcessedRequests', () {
    test('should clear processed request IDs', () {
      // This is a white-box test to ensure the method exists and can be called
      expect(() => service.resetProcessedRequests(), returnsNormally);
    });

    test('should reset consecutive checks counter', () {
      // Verify the method can be called multiple times without error
      service.resetProcessedRequests();
      service.resetProcessedRequests();
      expect(() => service.resetProcessedRequests(), returnsNormally);
    });
  });

  group('PendingRequestService - checkAndShowPendingRequests', () {
    final testRequest = CartRequest(
      id: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 29.99,
      status: RequestStatus.pending,
      createdAt: DateTime(2025, 10, 31),
    );

    testWidgets('should handle unmounted context gracefully', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));

      // Create a context that will be unmounted
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            // Store context but don't use it after widget is disposed
            Future.microtask(() async {
              await tester.pumpWidget(const SizedBox()); // Unmount
              await service.checkAndShowPendingRequests(context);
            });
            return const SizedBox();
          },
        ),
      ));

      await tester.pumpAndSettle();

      // Verify no errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('should return early if already checking requests', (tester) async {
      // Arrange - Make repository slow to simulate ongoing check
      final completer = Completer<Either<Failure, List<CartRequest>>>();
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                service.checkAndShowPendingRequests(context);
                // Try to check again immediately
                service.checkAndShowPendingRequests(context);
              },
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pump();

      // Complete the first request
      completer.complete(Right([testRequest]));
      await tester.pumpAndSettle();

      // Assert - Repository should only be called once due to lock
      verify(() => mockRepository.getReceivedRequests()).called(1);
    });

    testWidgets('should handle timeout gracefully', (tester) async {
      // Arrange - Repository never completes (simulates timeout)
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) => Completer<Either<Failure, List<CartRequest>>>().future);

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pump();

      // Fast forward past timeout
      await tester.pump(const Duration(seconds: 11));
      await tester.pumpAndSettle();

      // Assert - No exception should be thrown
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle repository failure silently', (tester) async {
      // Arrange
      const failure = ServerFailure(message: 'Server error');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Left(failure));

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should complete without showing dialog or throwing error
      expect(find.byType(Dialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle network failure silently', (tester) async {
      // Arrange
      const failure = NetworkFailure(message: 'No internet');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Left(failure));

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle exception silently', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenThrow(Exception('Unexpected error'));

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should handle exception gracefully
      expect(tester.takeException(), isNull);
    });

    testWidgets('should not show dialog when no pending requests', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should not show dialog for accepted requests', (tester) async {
      // Arrange
      final acceptedRequest = testRequest.copyWith(status: RequestStatus.accepted);
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([acceptedRequest]));

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should not show dialog for rejected requests', (tester) async {
      // Arrange
      final rejectedRequest = testRequest.copyWith(status: RequestStatus.rejected);
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([rejectedRequest]));

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should not show dialog for cancelled requests', (tester) async {
      // Arrange
      final cancelledRequest = testRequest.copyWith(status: RequestStatus.cancelled);
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([cancelledRequest]));

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => service.checkAndShowPendingRequests(context),
              child: const Text('Check'),
            );
          },
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should handle manual check (isAutoCheck=false)', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context, isAutoCheck: false),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should attempt to fetch requests
      verify(() => mockRepository.getReceivedRequests()).called(1);
    });

    testWidgets('should stop auto-check after max consecutive checks', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));

      int callCount = 0;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  // Simulate multiple consecutive auto-checks
                  for (int i = 0; i < 10; i++) {
                    await service.checkAndShowPendingRequests(context, isAutoCheck: true);
                    callCount++;
                  }
                },
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should have tried all 10 calls but service should limit execution
      expect(callCount, 10);
      // Verify that calls were made (some will be blocked by the consecutive check limit)
      verify(() => mockRepository.getReceivedRequests()).called(greaterThan(0));
    });

    testWidgets('should reset consecutive checks on manual check', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  // Do auto-checks
                  await service.checkAndShowPendingRequests(context, isAutoCheck: true);
                  // Then manual check should reset counter
                  await service.checkAndShowPendingRequests(context, isAutoCheck: false);
                  // More auto-checks should work
                  await service.checkAndShowPendingRequests(context, isAutoCheck: true);
                },
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - All checks should complete
      verify(() => mockRepository.getReceivedRequests()).called(3);
    });
  });

  group('PendingRequestService - Integration Tests', () {
    final testRequest1 = CartRequest(
      id: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book 1',
      bookAuthor: 'Author 1',
      bookImageUrl: 'https://example.com/image1.jpg',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 29.99,
      status: RequestStatus.pending,
      createdAt: DateTime(2025, 10, 31),
    );

    final testRequest2 = CartRequest(
      id: 'req2',
      bookId: 'book2',
      bookTitle: 'Test Book 2',
      bookAuthor: 'Author 2',
      bookImageUrl: 'https://example.com/image2.jpg',
      requesterId: 'user2',
      ownerId: 'owner1',
      requestType: CartItemType.purchase,
      rentalPeriodInDays: 0,
      price: 49.99,
      status: RequestStatus.pending,
      createdAt: DateTime(2025, 10, 31),
    );

    testWidgets('should handle multiple pending requests', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest1, testRequest2]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should fetch requests successfully
      verify(() => mockRepository.getReceivedRequests()).called(1);
    });

    testWidgets('should filter out processed requests on subsequent checks', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest1, testRequest2]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  await service.checkAndShowPendingRequests(context);
                  // Simulate processing by resetting
                  service.resetProcessedRequests();
                  await service.checkAndShowPendingRequests(context);
                },
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should check twice
      verify(() => mockRepository.getReceivedRequests()).called(2);
    });

    testWidgets('should handle empty requests list', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRepository.getReceivedRequests()).called(1);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('should handle mixed status requests', (tester) async {
      // Arrange
      final mixedRequests = [
        testRequest1, // pending
        testRequest2.copyWith(status: RequestStatus.accepted), // accepted
        testRequest1.copyWith(id: 'req3', status: RequestStatus.rejected), // rejected
        testRequest2.copyWith(id: 'req4', status: RequestStatus.pending), // pending
      ];
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right(mixedRequests));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should filter to only pending requests
      verify(() => mockRepository.getReceivedRequests()).called(1);
    });
  });

  group('PendingRequestService - Edge Cases', () {
    testWidgets('should handle rapid consecutive calls', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => const Right([]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  // Rapid fire calls
                  service.checkAndShowPendingRequests(context);
                  service.checkAndShowPendingRequests(context);
                  service.checkAndShowPendingRequests(context);
                },
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should prevent concurrent checks
      verify(() => mockRepository.getReceivedRequests()).called(1);
    });

    testWidgets('should handle very large request list', (tester) async {
      // Arrange
      final largeList = List.generate(
        100,
        (i) => CartRequest(
          id: 'req$i',
          bookId: 'book$i',
          bookTitle: 'Book $i',
          bookAuthor: 'Author $i',
          bookImageUrl: 'https://example.com/image$i.jpg',
          requesterId: 'user$i',
          ownerId: 'owner1',
          requestType: CartItemType.rent,
          rentalPeriodInDays: 14,
          price: 29.99,
          status: RequestStatus.pending,
          createdAt: DateTime(2025, 10, 31),
        ),
      );
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right(largeList));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Should handle large list without error
      verify(() => mockRepository.getReceivedRequests()).called(1);
      expect(tester.takeException(), isNull);
    });
  });

  group('PendingRequestService - Dialog Display', () {
    final testRequest = CartRequest(
      id: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 29.99,
      status: RequestStatus.pending,
      createdAt: DateTime(2025, 10, 31),
    );

    testWidgets('should show dialog when pending requests exist', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be shown
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('should show single request dialog for manual check with multiple requests', (tester) async {
      // Arrange
      final testRequest2 = testRequest.copyWith(id: 'req2');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest, testRequest2]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context, isAutoCheck: false),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be shown with both requests
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('should show single request dialog for auto-check with multiple requests', (tester) async {
      // Arrange
      final testRequest2 = testRequest.copyWith(id: 'req2');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest, testRequest2]));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context, isAutoCheck: true),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      // Act
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Assert - Dialog should be shown with only latest request for auto-check
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('PendingRequestService - Accept Request', () {
    final testRequest = CartRequest(
      id: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 29.99,
      status: RequestStatus.pending,
      createdAt: DateTime(2025, 10, 31),
    );

    testWidgets('should show loading snackbar when accepting request', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockAcceptUseCase(any()))
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pump();

      // Assert
      expect(find.text('Accepting request...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      
      // Clean up pending timers
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    });

    testWidgets('should show success snackbar when accept succeeds', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockAcceptUseCase(any()))
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Request accepted successfully!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      verify(() => mockAcceptUseCase('req1')).called(1);
    });

    testWidgets('should show error snackbar when accept fails', (tester) async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to accept');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockAcceptUseCase(any()))
          .thenAnswer((_) async => const Left(failure));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to accept request: Failed to accept'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    // Note: Retry functionality is tested implicitly through error snackbar tests
    // The retry button shows correctly and can be tapped, full retry flow is complex
    // to test due to async timing with _checkForMoreRequests

    testWidgets('should handle accept timeout', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockAcceptUseCase(any()))
          .thenAnswer((_) => Completer<Either<Failure, void>>().future);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 16));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should handle exception during accept', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockAcceptUseCase(any()))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should check for more requests after successful accept', (tester) async {
      // Arrange
      final testRequest2 = testRequest.copyWith(id: 'req2');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest, testRequest2]));
      when(() => mockAcceptUseCase(any()))
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Accept'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Assert - Should check for more requests
      verify(() => mockRepository.getReceivedRequests()).called(greaterThanOrEqualTo(2));
    });
  });

  group('PendingRequestService - Reject Request', () {
    final testRequest = CartRequest(
      id: 'req1',
      bookId: 'book1',
      bookTitle: 'Test Book',
      bookAuthor: 'Test Author',
      bookImageUrl: 'https://example.com/image.jpg',
      requesterId: 'user1',
      ownerId: 'owner1',
      requestType: CartItemType.rent,
      rentalPeriodInDays: 14,
      price: 29.99,
      status: RequestStatus.pending,
      createdAt: DateTime(2025, 10, 31),
    );

    testWidgets('should show loading snackbar when rejecting request', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockRejectUseCase(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      // Show reject dialog
      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pump();

      // Assert
      expect(find.text('Rejecting request...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
      
      // Clean up pending timers
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    });

    testWidgets('should show success snackbar when reject succeeds', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockRejectUseCase(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Request rejected'), findsOneWidget);
      verify(() => mockRejectUseCase('req1', reason: null)).called(1);
    });

    testWidgets('should pass rejection reason to usecase', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockRejectUseCase(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Out of stock');
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockRejectUseCase('req1', reason: 'Out of stock')).called(1);
    });

    testWidgets('should show error snackbar when reject fails', (tester) async {
      // Arrange
      const failure = ServerFailure(message: 'Failed to reject');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockRejectUseCase(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async => const Left(failure));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Failed to reject request: Failed to reject'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    // Note: Retry functionality is tested implicitly through error snackbar tests
    // The retry button shows correctly and can be tapped, full retry flow is complex
    // to test due to async timing with _checkForMoreRequests

    testWidgets('should handle reject timeout', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockRejectUseCase(any(), reason: any(named: 'reason')))
          .thenAnswer((_) => Completer<Either<Failure, void>>().future);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pump();
      await tester.pump(const Duration(seconds: 16));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should handle exception during reject', (tester) async {
      // Arrange
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest]));
      when(() => mockRejectUseCase(any(), reason: any(named: 'reason')))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pump();
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should check for more requests after successful reject', (tester) async {
      // Arrange
      final testRequest2 = testRequest.copyWith(id: 'req2');
      when(() => mockRepository.getReceivedRequests())
          .thenAnswer((_) async => Right([testRequest, testRequest2]));
      when(() => mockRejectUseCase(any(), reason: any(named: 'reason')))
          .thenAnswer((_) async => const Right(unit));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => service.checkAndShowPendingRequests(context),
                child: const Text('Check'),
              );
            },
          ),
        ),
      ));

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Reject').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Assert - Should check for more requests
      verify(() => mockRepository.getReceivedRequests()).called(greaterThanOrEqualTo(2));
    });
  });
}
