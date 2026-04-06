import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';
import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';

/// Remote data source for rental status
abstract class RentalStatusRemoteDataSource {
  /// Get rental status for a book
  Future<RentalStatusModel> getRentalStatus(String bookId);
  
  /// Get rental status for multiple books
  Future<List<RentalStatusModel>> getRentalStatusBatch(List<String> bookIds);
  
  /// Update rental status
  Future<RentalStatusModel> updateRentalStatus(RentalStatusModel status);
}

/// Mock implementation of RentalStatusRemoteDataSource
class RentalStatusRemoteDataSourceImpl implements RentalStatusRemoteDataSource {
  @override
  Future<RentalStatusModel> getRentalStatus(String bookId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Return different statuses for different books for demo purposes
    switch (bookId.hashCode % 5) {
      case 0:
        return RentalStatusModel(
          bookId: bookId,
          status: RentalStatusType.available,
          canRenew: false,
          isInCart: false,
          isPurchased: false,
        );
      case 1:
        return RentalStatusModel(
          bookId: bookId,
          status: RentalStatusType.rented,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          rentedDate: DateTime.now().subtract(const Duration(days: 7)),
          daysRemaining: 7,
          canRenew: true,
          isInCart: false,
          isPurchased: false,
        );
      case 2:
        return RentalStatusModel(
          bookId: bookId,
          status: RentalStatusType.overdue,
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          rentedDate: DateTime.now().subtract(const Duration(days: 16)),
          daysRemaining: -2,
          canRenew: false,
          isInCart: false,
          isPurchased: false,
          lateFee: 5.50,
        );
      case 3:
        return RentalStatusModel(
          bookId: bookId,
          status: RentalStatusType.available,
          canRenew: false,
          isInCart: true,
          isPurchased: false,
        );
      case 4:
        return RentalStatusModel(
          bookId: bookId,
          status: RentalStatusType.purchased,
          canRenew: false,
          isInCart: false,
          isPurchased: true,
        );
      default:
        return RentalStatusModel(
          bookId: bookId,
          status: RentalStatusType.available,
          canRenew: false,
          isInCart: false,
          isPurchased: false,
        );
    }
  }

  @override
  Future<List<RentalStatusModel>> getRentalStatusBatch(List<String> bookIds) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Get status for each book
    final statuses = <RentalStatusModel>[];
    for (final bookId in bookIds) {
      final status = await getRentalStatus(bookId);
      statuses.add(status);
    }
    
    return statuses;
  }

  @override
  Future<RentalStatusModel> updateRentalStatus(RentalStatusModel status) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return the updated status
    return status;
  }
}
