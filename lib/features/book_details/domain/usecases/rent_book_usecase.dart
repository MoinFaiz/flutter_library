import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_details/domain/repositories/book_operations_repository.dart';

/// Use case for renting a book
class RentBookUseCase {
  final BookOperationsRepository repository;

  RentBookUseCase({required this.repository});

  Future<Either<Failure, Book>> call(String bookId) async {
    return await repository.rentBook(bookId);
  }
}
