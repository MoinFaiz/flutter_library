import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/data/datasources/book_upload_remote_datasource.dart';
import 'package:flutter_library/features/book_upload/data/models/book_copy_model.dart';
import 'package:flutter_library/features/book_upload/data/models/book_upload_form_model.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Implementation of BookUploadRepository
class BookUploadRepositoryImpl implements BookUploadRepository {
  final BookUploadRemoteDataSource remoteDataSource;

  BookUploadRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Book>>> searchBooks(String query) async {
    try {
      final bookModels = await remoteDataSource.searchBooks(query);
      return Right(bookModels.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search books: $e'));
    }
  }

  @override
  Future<Either<Failure, Book?>> getBookByIsbn(String isbn) async {
    try {
      final bookModel = await remoteDataSource.getBookByIsbn(isbn);
      return Right(bookModel?.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get book by ISBN: $e'));
    }
  }

  @override
  Future<Either<Failure, Book>> uploadBook(BookUploadForm form) async {
    try {
      final formModel = BookUploadFormModel.fromEntity(form);
      final bookModel = await remoteDataSource.uploadBook(formModel);
      return Right(bookModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to upload book: $e'));
    }
  }

  @override
  Future<Either<Failure, Book>> updateBook(BookUploadForm form) async {
    try {
      final formModel = BookUploadFormModel.fromEntity(form);
      final bookModel = await remoteDataSource.updateBook(formModel);
      return Right(bookModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update book: $e'));
    }
  }

  @override
  Future<Either<Failure, BookCopy>> uploadCopy(BookCopy copy) async {
    try {
      final copyModel = BookCopyModel.fromEntity(copy);
      final uploadedCopyModel = await remoteDataSource.uploadCopy(copyModel);
      final uploadedCopy = BookCopy(
        id: uploadedCopyModel.id,
        bookId: uploadedCopyModel.bookId,
        userId: uploadedCopyModel.userId,
        imageUrls: uploadedCopyModel.imageUrls,
        condition: uploadedCopyModel.condition,
        isForSale: uploadedCopyModel.isForSale,
        isForRent: uploadedCopyModel.isForRent,
        isForDonate: uploadedCopyModel.isForDonate,
        expectedPrice: uploadedCopyModel.expectedPrice,
        rentPrice: uploadedCopyModel.rentPrice,
        notes: uploadedCopyModel.notes,
        uploadDate: uploadedCopyModel.uploadDate,
        updatedAt: uploadedCopyModel.updatedAt,
      );
      return Right(uploadedCopy);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to upload copy: $e'));
    }
  }

  @override
  Future<Either<Failure, BookCopy>> updateCopy(BookCopy copy) async {
    try {
      final copyModel = BookCopyModel.fromEntity(copy);
      final updatedCopyModel = await remoteDataSource.updateCopy(copyModel);
      final updatedCopy = BookCopy(
        id: updatedCopyModel.id,
        bookId: updatedCopyModel.bookId,
        userId: updatedCopyModel.userId,
        imageUrls: updatedCopyModel.imageUrls,
        condition: updatedCopyModel.condition,
        isForSale: updatedCopyModel.isForSale,
        isForRent: updatedCopyModel.isForRent,
        isForDonate: updatedCopyModel.isForDonate,
        expectedPrice: updatedCopyModel.expectedPrice,
        rentPrice: updatedCopyModel.rentPrice,
        notes: updatedCopyModel.notes,
        uploadDate: updatedCopyModel.uploadDate,
        updatedAt: updatedCopyModel.updatedAt,
      );
      return Right(updatedCopy);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update copy: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCopy(String copyId, String reason) async {
    try {
      await remoteDataSource.deleteCopy(copyId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete copy: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(String bookId, String reason) async {
    try {
      await remoteDataSource.deleteBook(bookId, reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete book: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Book>>> getUserBooks() async {
    try {
      final bookModels = await remoteDataSource.getUserBooks();
      final books = bookModels.map((model) => model.toEntity()).toList();
      return Right(books);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user books: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(String filePath) async {
    try {
      final imageUrl = await remoteDataSource.uploadImage(filePath);
      return Right(imageUrl);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getGenres() async {
    try {
      final genres = await remoteDataSource.getGenres();
      return Right(genres);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get genres: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLanguages() async {
    try {
      final languages = await remoteDataSource.getLanguages();
      return Right(languages);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get languages: $e'));
    }
  }
}
