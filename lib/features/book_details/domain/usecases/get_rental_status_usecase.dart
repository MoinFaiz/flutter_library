import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
import 'package:flutter_library/features/book_details/domain/repositories/rental_status_repository.dart';

/// Use case for getting rental status of a book
class GetRentalStatusUseCase {
  final RentalStatusRepository repository;

  GetRentalStatusUseCase({required this.repository});

  Future<Either<Failure, RentalStatus>> call(String bookId) async {
    return await repository.getRentalStatus(bookId);
  }
}
