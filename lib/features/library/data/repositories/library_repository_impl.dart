import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/library/data/datasources/library_remote_datasource.dart';
import 'package:flutter_library/features/library/domain/repositories/library_repository.dart';

/// Implementation of LibraryRepository
class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Book>>> getBorrowedBooks({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDataSource.getBorrowedBooks(
        page: page,
        limit: limit,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: '${AppConstants.failedToGetBorrowedBooksError}: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getUploadedBooks({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final models = await remoteDataSource.getUploadedBooks(
        page: page,
        limit: limit,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: '${AppConstants.failedToGetUploadedBooksError}: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getAllBorrowedBooks() async {
    try {
      // Get all borrowed books (use a large limit)
      final models = await remoteDataSource.getBorrowedBooks(
        page: 1,
        limit: AppConstants.maxBooksPerBatch,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: '${AppConstants.failedToGetAllBorrowedBooksError}: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getAllUploadedBooks() async {
    try {
      // Get all uploaded books (use a large limit)
      final models = await remoteDataSource.getUploadedBooks(
        page: 1,
        limit: AppConstants.maxBooksPerBatch,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: '${AppConstants.failedToGetAllUploadedBooksError}: $e'));
    }
  }
}
