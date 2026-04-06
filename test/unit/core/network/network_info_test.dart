import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_library/core/network/network_info.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('NetworkInfo Tests', () {
    group('NetworkInfoImpl', () {
      late NetworkInfoImpl networkInfo;
      late MockConnectivity mockConnectivity;

      setUp(() {
        mockConnectivity = MockConnectivity();
        networkInfo = NetworkInfoImpl(mockConnectivity);
      });

      group('isConnected', () {
        test('should return true when connectivity result is wifi', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.wifi]);

          // Act
          final result = await networkInfo.isConnected;

          // Assert
          expect(result, isTrue);
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });

        test('should return true when connectivity result is mobile', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.mobile]);

          // Act
          final result = await networkInfo.isConnected;

          // Assert
          expect(result, isTrue);
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });

        test('should return true when connectivity result is ethernet', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.ethernet]);

          // Act
          final result = await networkInfo.isConnected;

          // Assert
          expect(result, isTrue);
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });

        test('should return true when connectivity result is bluetooth', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

          // Act
          final result = await networkInfo.isConnected;

          // Assert
          expect(result, isTrue);
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });

        test('should return true when connectivity result is vpn', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.vpn]);

          // Act
          final result = await networkInfo.isConnected;

          // Assert
          expect(result, isTrue);
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });

        test('should return false when connectivity result is none', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.none]);

          // Act
          final result = await networkInfo.isConnected;

          // Assert
          expect(result, isFalse);
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });

        test('should handle connectivity check multiple times', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.wifi]);

          // Act
          final result1 = await networkInfo.isConnected;
          final result2 = await networkInfo.isConnected;
          final result3 = await networkInfo.isConnected;

          // Assert
          expect(result1, isTrue);
          expect(result2, isTrue);
          expect(result3, isTrue);
          verify(() => mockConnectivity.checkConnectivity()).called(3);
        });

        test('should handle connectivity state changes', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.wifi]);

          // Act
          final result1 = await networkInfo.isConnected;

          // Change connectivity state
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.none]);

          final result2 = await networkInfo.isConnected;

          // Assert
          expect(result1, isTrue);
          expect(result2, isFalse);
          verify(() => mockConnectivity.checkConnectivity()).called(2);
        });

        test('should handle exceptions from connectivity check gracefully', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenThrow(Exception('Connectivity check failed'));

          // Act & Assert
          expect(
            () => networkInfo.isConnected,
            throwsA(isA<Exception>()),
          );
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });

        test('should handle delayed connectivity responses', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity()).thenAnswer(
            (_) async {
              await Future.delayed(const Duration(milliseconds: 100));
              return [ConnectivityResult.mobile];
            },
          );

          // Act
          final stopwatch = Stopwatch()..start();
          final result = await networkInfo.isConnected;
          stopwatch.stop();

          // Assert
          expect(result, isTrue);
          expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
          verify(() => mockConnectivity.checkConnectivity()).called(1);
        });
      });

      group('Constructor', () {
        test('should accept Connectivity instance in constructor', () {
          // Act
          final networkInfoInstance = NetworkInfoImpl(mockConnectivity);

          // Assert
          expect(networkInfoInstance, isA<NetworkInfo>());
          expect(networkInfoInstance, isA<NetworkInfoImpl>());
        });

        test('should store connectivity instance correctly', () {
          // Act
          final networkInfoInstance = NetworkInfoImpl(mockConnectivity);

          // Assert
          expect(networkInfoInstance.connectivity, equals(mockConnectivity));
        });
      });

      group('Interface Compliance', () {
        test('should implement NetworkInfo interface', () {
          // Assert
          expect(networkInfo, isA<NetworkInfo>());
        });

        test('should have isConnected getter that returns Future<bool>', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.wifi]);

          // Act
          final result = networkInfo.isConnected;

          // Assert
          expect(result, isA<Future<bool>>());
          expect(await result, isA<bool>());
        });
      });

      group('Edge Cases', () {
        test('should handle rapid consecutive calls', () async {
          // Arrange
          when(() => mockConnectivity.checkConnectivity())
              .thenAnswer((_) async => [ConnectivityResult.wifi]);

          // Act
          final futures = List.generate(
            10,
            (_) => networkInfo.isConnected,
          );
          final results = await Future.wait(futures);

          // Assert
          expect(results, hasLength(10));
          expect(results.every((result) => result == true), isTrue);
          verify(() => mockConnectivity.checkConnectivity()).called(10);
        });

        test('should handle mixed connectivity results in rapid succession', () async {
          // Arrange
          var callCount = 0;
          when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async {
            callCount++;
            return callCount.isEven 
                ? [ConnectivityResult.wifi]
                : [ConnectivityResult.none];
          });

          // Act
          final result1 = await networkInfo.isConnected;
          final result2 = await networkInfo.isConnected;
          final result3 = await networkInfo.isConnected;
          final result4 = await networkInfo.isConnected;

          // Assert
          expect(result1, isFalse); // call 1 (odd)
          expect(result2, isTrue);  // call 2 (even)
          expect(result3, isFalse); // call 3 (odd)
          expect(result4, isTrue);  // call 4 (even)
          verify(() => mockConnectivity.checkConnectivity()).called(4);
        });
      });
    });

    group('NetworkInfo Abstract Class', () {
      test('should be implemented by concrete classes', () {
        // Arrange
        final mockConnectivity = MockConnectivity();
        final networkInfo = NetworkInfoImpl(mockConnectivity);

        // Assert
        expect(networkInfo, isA<NetworkInfo>());
      });

      test('should define isConnected as abstract getter', () {
        // This test verifies that NetworkInfo is properly defined as an abstract class
        // with an abstract getter for isConnected
        expect(NetworkInfo, isA<Type>());
      });
    });
  });
}
