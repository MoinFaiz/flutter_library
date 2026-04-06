import 'package:dio/dio.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/book_details/data/models/rental_status_model.dart';

/// Remote data source for book operations
abstract class BookOperationsRemoteDataSource {
  Future<Book> rentBook(String bookId);
  Future<Book> buyBook(String bookId);
  Future<Book> returnBook(String bookId);
  Future<Book> renewBook(String bookId);
  Future<Book> addToCart(String bookId);
  Future<Book> removeFromCart(String bookId);
  Future<RentalStatusModel> getRentalStatus(String bookId);
}

/// Implementation of BookOperationsRemoteDataSource
class BookOperationsRemoteDataSourceImpl implements BookOperationsRemoteDataSource {
  final Dio dio;

  BookOperationsRemoteDataSourceImpl({required this.dio});

  @override
  Future<Book> rentBook(String bookId) async {
    try {
      final response = await dio.post('/books/$bookId/rent');
      
      if (response.statusCode == 200) {
        // In a real app, you'd parse the response to a Book entity
        // For now, we'll simulate a successful response
        return _createMockBook(bookId);
      } else {
        throw Exception('Failed to rent book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while renting book: $e');
    }
  }

  @override
  Future<Book> buyBook(String bookId) async {
    try {
      final response = await dio.post('/books/$bookId/buy');
      
      if (response.statusCode == 200) {
        return _createMockBook(bookId);
      } else {
        throw Exception('Failed to buy book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while buying book: $e');
    }
  }

  @override
  Future<Book> returnBook(String bookId) async {
    try {
      final response = await dio.post('/books/$bookId/return');
      
      if (response.statusCode == 200) {
        return _createMockBook(bookId);
      } else {
        throw Exception('Failed to return book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while returning book: $e');
    }
  }

  @override
  Future<Book> renewBook(String bookId) async {
    try {
      final response = await dio.post('/books/$bookId/renew');
      
      if (response.statusCode == 200) {
        return _createMockBook(bookId);
      } else {
        throw Exception('Failed to renew book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while renewing book: $e');
    }
  }

  @override
  Future<Book> addToCart(String bookId) async {
    try {
      final response = await dio.post('/books/$bookId/cart');
      
      if (response.statusCode == 200) {
        return _createMockBook(bookId);
      } else {
        throw Exception('Failed to add to cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while adding to cart: $e');
    }
  }

  @override
  Future<Book> removeFromCart(String bookId) async {
    try {
      final response = await dio.delete('/books/$bookId/cart');
      
      if (response.statusCode == 200) {
        return _createMockBook(bookId);
      } else {
        throw Exception('Failed to remove from cart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while removing from cart: $e');
    }
  }

  @override
  Future<RentalStatusModel> getRentalStatus(String bookId) async {
    final response = await dio.get('/books/$bookId/rental-status');
    
    if (response.statusCode == 200) {
      return RentalStatusModel.fromJson(response.data);
    } else {
      throw Exception('Failed to get rental status: ${response.statusCode}');
    }
  }

  /// Create a mock book for demonstration
  Book _createMockBook(String bookId) {
    // In a real app, you'd create this from the API response
    // This is just a placeholder
    final now = DateTime.now();
    return Book(
      id: bookId,
      title: 'Mock Book Title',
      author: 'Mock Author',
      imageUrls: ['https://example.com/book.jpg'],
      rating: 4.0,
      pricing: const BookPricing(
        salePrice: 12.99,
        rentPrice: 5.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 10,
        availableForSaleCount: 5,
        totalCopies: 15,
      ),
      metadata: const BookMetadata(
        isbn: '9781234567890',
        publisher: 'Mock Publisher',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        pageCount: 200,
        language: 'English',
        edition: '1st Edition',
      ),
      isFromFriend: false,
      isFavorite: false,
      description: 'Mock book description',
      publishedYear: 2023,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create mock rental status based on book ID
}
