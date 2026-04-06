import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'package:flutter_library/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group('ToggleFavoriteUseCase Tests', () {
    late ToggleFavoriteUseCase useCase;
    late MockFavoritesRepository mockFavoritesRepository;

    setUp(() {
      mockFavoritesRepository = MockFavoritesRepository();
      useCase = ToggleFavoriteUseCase(
        favoritesRepository: mockFavoritesRepository,
      );
    });

    test('should add book to favorites when not currently favorite', () async {
      // Arrange
      const bookId = '1';
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right(<String>[]));
      when(() => mockFavoritesRepository.addToFavorites(bookId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(bookId);

      // Assert
      expect(result, const Right(true));
      verify(() => mockFavoritesRepository.getFavoriteBookIds()).called(1);
      verify(() => mockFavoritesRepository.addToFavorites(bookId)).called(1);
      verifyNever(() => mockFavoritesRepository.removeFromFavorites(any()));
    });

    test('should remove book from favorites when currently favorite', () async {
      // Arrange
      const bookId = '1';
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right(<String>['1']));
      when(() => mockFavoritesRepository.removeFromFavorites(bookId))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(bookId);

      // Assert
      expect(result, const Right(false));
      verify(() => mockFavoritesRepository.getFavoriteBookIds()).called(1);
      verify(() => mockFavoritesRepository.removeFromFavorites(bookId)).called(1);
      verifyNever(() => mockFavoritesRepository.addToFavorites(any()));
    });

    test('should return failure when getFavoriteBookIds fails', () async {
      // Arrange
      const bookId = '1';
      const failure = ServerFailure(message: 'Network error');
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(bookId);

      // Assert
      expect(result, const Left(failure));
      verifyNever(() => mockFavoritesRepository.addToFavorites(any()));
      verifyNever(() => mockFavoritesRepository.removeFromFavorites(any()));
    });

    test('should return failure when addToFavorites fails', () async {
      // Arrange
      const bookId = '1';
      const failure = ServerFailure(message: 'Failed to add favorite');
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right(<String>[]));
      when(() => mockFavoritesRepository.addToFavorites(bookId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(bookId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return failure when removeFromFavorites fails', () async {
      // Arrange
      const bookId = '1';
      const failure = ServerFailure(message: 'Failed to remove favorite');
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenAnswer((_) async => const Right(<String>['1']));
      when(() => mockFavoritesRepository.removeFromFavorites(bookId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(bookId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should handle exceptions and return unknown failure', () async {
      // Arrange
      const bookId = '1';
      when(() => mockFavoritesRepository.getFavoriteBookIds())
          .thenThrow(Exception('Test exception'));

      // Act
      final result = await useCase.call(bookId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure.message, contains('Failed to toggle favorite')),
        (_) => fail('Expected failure but got success'),
      );
    });
  });
}