import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';

/// Use case for getting books uploaded by the current user
class GetUserBooksUseCase {
  final BookUploadRepository repository;

  GetUserBooksUseCase({required this.repository});

  Future<Either<Failure, List<Book>>> call() async {
    return await repository.getUserBooks();
  }
}
