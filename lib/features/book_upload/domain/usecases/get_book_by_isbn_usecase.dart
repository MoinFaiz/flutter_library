import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for getting book by ISBN
class GetBookByIsbnUseCase {
  final BookUploadRepository repository;

  GetBookByIsbnUseCase({required this.repository});

  Future<Either<Failure, Book?>> call(String isbn) async {
    if (isbn.trim().isEmpty) {
      return const Right(null);
    }
    
    return await repository.getBookByIsbn(isbn.trim());
  }
}
