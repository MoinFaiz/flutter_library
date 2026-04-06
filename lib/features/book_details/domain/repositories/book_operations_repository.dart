import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';

/// Repository interface for book operations (rent, buy, return, etc.)
abstract class BookOperationsRepository {
  /// Rent a book
  Future<Either<Failure, Book>> rentBook(String bookId);
  
  /// Buy a book
  Future<Either<Failure, Book>> buyBook(String bookId);
  
  /// Return a rented book
  Future<Either<Failure, Book>> returnBook(String bookId);
  
  /// Renew a rented book
  Future<Either<Failure, Book>> renewBook(String bookId);
  
  /// Add book to cart
  Future<Either<Failure, Book>> addToCart(String bookId);
  
  /// Remove book from cart
  Future<Either<Failure, Book>> removeFromCart(String bookId);
}
