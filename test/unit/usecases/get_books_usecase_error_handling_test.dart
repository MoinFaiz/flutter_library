import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/home/domain/usecases/get_books_usecase.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookRepository extends Mock implements BookRepository {}

void main() {
  group('GetBooksUseCase Error Handling Tests', () {
    late GetBooksUseCase useCase;
    late MockBookRepository mockBookRepository;

    setUp(() {
      mockBookRepository = MockBookRepository();
      useCase = GetBooksUseCase(bookRepository: mockBookRepository);
    });

    test('should handle network failure gracefully', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(NetworkFailure()));
      final result = await useCase.call(page: 1, limit: 20);
      expect(result, isA<Left<Failure, dynamic>>());
      expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
    });

    test('should handle server failure gracefully', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(ServerFailure()));
      final result = await useCase.call(page: 1, limit: 20);
      expect(result, isA<Left<Failure, dynamic>>());
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });

    test('should handle cache failure gracefully', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
      final result = await useCase.call(page: 1, limit: 20);
      expect(result, isA<Left<Failure, dynamic>>());
      expect(result.fold((l) => l, (r) => null), isA<CacheFailure>());
    });

    test('should handle validation failure gracefully', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(ValidationFailure('Invalid parameters')));
      final result = await useCase.call(page: 1, limit: 20);
      expect(result, isA<Left<Failure, dynamic>>());
      expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
    });

    test('should handle unknown failure gracefully', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Left(UnknownFailure('Unknown error')));
      final result = await useCase.call(page: 1, limit: 20);
      expect(result, isA<Left<Failure, dynamic>>());
      expect(result.fold((l) => l, (r) => null), isA<UnknownFailure>());
    });

    test('should handle edge case with zero page', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([]));
      final result = await useCase.call(page: 0, limit: 20);
      expect(result, isA<Right<dynamic, List>>());
      verify(() => mockBookRepository.getBooks(page: 0, limit: 20)).called(1);
    });

    test('should handle edge case with negative limit', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([]));
      final result = await useCase.call(page: 1, limit: -1);
      expect(result, isA<Right<dynamic, List>>());
      verify(() => mockBookRepository.getBooks(page: 1, limit: -1)).called(1);
    });

    test('should handle very large page numbers', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([]));
      final result = await useCase.call(page: 999999, limit: 20);
      expect(result, isA<Right<dynamic, List>>());
      verify(() => mockBookRepository.getBooks(page: 999999, limit: 20)).called(1);
    });

    test('should handle null or empty book list from repository', () async {
      when(() => mockBookRepository.getBooks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([]));
      final result = await useCase.call(page: 1, limit: 20);
      expect(result, isA<Right<dynamic, List>>());
      expect(result.fold((l) => null, (r) => r), isEmpty);
    });
  });
}