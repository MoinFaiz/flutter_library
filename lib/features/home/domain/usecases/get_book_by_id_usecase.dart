import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/home/domain/repositories/book_repository.dart';

class GetBookByIdUseCase {
  final BookRepository repository;

  GetBookByIdUseCase({required this.repository});

  Future<Either<Failure, Book?>> call(String bookId) async {
    return await repository.getBookById(bookId);
  }
}
