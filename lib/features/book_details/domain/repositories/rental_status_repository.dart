import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

/// Repository interface for rental status operations
abstract class RentalStatusRepository {
  /// Get rental status for a book
  Future<Either<Failure, RentalStatus>> getRentalStatus(String bookId);
  
  /// Get rental status for multiple books
  Future<Either<Failure, List<RentalStatus>>> getRentalStatusBatch(List<String> bookIds);
  
  /// Update rental status (used internally by operations)
  Future<Either<Failure, RentalStatus>> updateRentalStatus(RentalStatus status);
}
