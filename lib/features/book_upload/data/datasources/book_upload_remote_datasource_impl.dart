import 'package:dio/dio.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/book_upload/data/datasources/book_upload_remote_datasource.dart';
import 'package:flutter_library/features/book_upload/data/models/book_copy_model.dart';
import 'package:flutter_library/features/book_upload/data/models/book_upload_form_model.dart';

/// Implementation of BookUploadRemoteDataSource
class BookUploadRemoteDataSourceImpl implements BookUploadRemoteDataSource {
  final Dio dio;

  BookUploadRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.get('/books/search', queryParameters: {'q': query});
      // return (response.data as List).map((json) => BookModel.fromJson(json)).toList();
      
      // For demo purposes, return mock search results
      await Future.delayed(const Duration(milliseconds: 800));
      
      return _mockSearchResults(query);
    } catch (e) {
      throw Exception('Failed to search books: $e');
    }
  }

  @override
  Future<BookModel?> getBookByIsbn(String isbn) async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.get('/books/isbn/$isbn');
      // return BookModel.fromJson(response.data);
      
      // For demo purposes, return mock result
      await Future.delayed(const Duration(milliseconds: 600));
      
      return _mockBookByIsbn(isbn);
    } catch (e) {
      throw Exception('Failed to get book by ISBN: $e');
    }
  }

  @override
  Future<BookModel> uploadBook(BookUploadFormModel form) async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.post('/books', data: form.toJson());
      // return BookModel.fromJson(response.data);
      
      // For demo purposes, return mock result
      await Future.delayed(const Duration(milliseconds: 1500));
      
      return _createBookFromForm(form);
    } catch (e) {
      throw Exception('Failed to upload book: $e');
    }
  }

  @override
  Future<BookModel> updateBook(BookUploadFormModel form) async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.put('/books/${form.id}', data: form.toJson());
      // return BookModel.fromJson(response.data);
      
      // For demo purposes, return mock result
      await Future.delayed(const Duration(milliseconds: 1200));
      
      return _createBookFromForm(form);
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  @override
  Future<BookCopyModel> uploadCopy(BookCopyModel copy) async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.post('/copies', data: copy.toJson());
      // return BookCopyModel.fromJson(response.data);
      
      // For demo purposes, return mock result
      await Future.delayed(const Duration(milliseconds: 1000));
      
      return copy.copyWith(
        id: 'copy_${DateTime.now().millisecondsSinceEpoch}',
        uploadDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to upload copy: $e');
    }
  }

  @override
  Future<BookCopyModel> updateCopy(BookCopyModel copy) async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.put('/copies/${copy.id}', data: copy.toJson());
      // return BookCopyModel.fromJson(response.data);
      
      // For demo purposes, return mock result
      await Future.delayed(const Duration(milliseconds: 800));
      
      return copy.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw Exception('Failed to update copy: $e');
    }
  }

  @override
  Future<void> deleteCopy(String copyId, String reason) async {
    try {
      // In a real app, this would make an API call
      // await dio.delete('/copies/$copyId', data: {'reason': reason});
      
      // For demo purposes, simulate deletion
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to delete copy: $e');
    }
  }

  @override
  Future<void> deleteBook(String bookId, String reason) async {
    try {
      // In a real app, this would make an API call
      // await dio.delete('/books/$bookId', data: {'reason': reason});
      
      // For demo purposes, simulate deletion
      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  @override
  Future<List<BookModel>> getUserBooks() async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.get('/books/user/me');
      // return (response.data as List).map((json) => BookModel.fromJson(json)).toList();
      
      // For demo purposes, return mock user books
      await Future.delayed(const Duration(milliseconds: 600));
      
      return _mockUserBooks();
    } catch (e) {
      throw Exception('Failed to get user books: $e');
    }
  }

  @override
  Future<String> uploadImage(String filePath) async {
    try {
      // In a real app, this would upload the image to a cloud storage service
      // final formData = FormData.fromMap({
      //   'image': await MultipartFile.fromFile(filePath),
      // });
      // final response = await dio.post('/upload/image', data: formData);
      // return response.data['url'];
      
      // For demo purposes, return mock URL
      await Future.delayed(const Duration(milliseconds: 2000));
      
      return 'https://via.placeholder.com/200x300/FF5722/FFFFFF?text=Uploaded+Image';
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<List<String>> getGenres() async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.get('/metadata/genres');
      // return (response.data as List).cast<String>();
      
      // For demo purposes, return mock genres
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _mockGenres;
    } catch (e) {
      throw Exception('Failed to get genres: $e');
    }
  }

  @override
  Future<List<String>> getLanguages() async {
    try {
      // In a real app, this would make an API call
      // final response = await dio.get('/metadata/languages');
      // return (response.data as List).cast<String>();
      
      // For demo purposes, return mock languages
      await Future.delayed(const Duration(milliseconds: 300));
      
      return _mockLanguages;
    } catch (e) {
      throw Exception('Failed to get languages: $e');
    }
  }

  // Mock data methods

  List<BookModel> _mockUserBooks() {
    // Mock books uploaded by the current user
    return [
      _createMockBook(
        id: 'user_book_1',
        title: 'My Flutter App Development',
        author: 'Current User',
        isbn: '978-1111111111',
        description: 'Personal notes on Flutter app development',
      ),
      _createMockBook(
        id: 'user_book_2',
        title: 'Learning Dart Programming',
        author: 'Current User',
        isbn: '978-2222222222',
        description: 'My journey learning Dart programming language',
      ),
      _createMockBook(
        id: 'user_book_3',
        title: 'Mobile UI/UX Design',
        author: 'Current User',
        isbn: '978-3333333333',
        description: 'Collection of mobile UI/UX design patterns',
      ),
    ];
  }

  List<BookModel> _mockSearchResults(String query) {
    // Mock search results based on query
    final results = <BookModel>[];
    
    if (query.toLowerCase().contains('flutter')) {
      results.add(_createMockBook(
        id: 'search_1',
        title: 'Flutter Development Guide',
        author: 'John Smith',
        isbn: '978-1234567890',
        description: 'Comprehensive guide to Flutter development',
      ));
    }
    
    if (query.toLowerCase().contains('dart')) {
      results.add(_createMockBook(
        id: 'search_2',
        title: 'Dart Programming Language',
        author: 'Jane Doe',
        isbn: '978-0987654321',
        description: 'Complete reference for Dart programming',
      ));
    }
    
    if (query.toLowerCase().contains('mobile')) {
      results.add(_createMockBook(
        id: 'search_3',
        title: 'Mobile Development Best Practices',
        author: 'Mike Johnson',
        isbn: '978-1122334455',
        description: 'Best practices for mobile app development',
      ));
    }
    
    return results;
  }

  BookModel? _mockBookByIsbn(String isbn) {
    // Mock book lookup by ISBN
    switch (isbn) {
      case '978-1234567890':
        return _createMockBook(
          id: 'isbn_1',
          title: 'Flutter Development Guide',
          author: 'John Smith',
          isbn: isbn,
          description: 'Comprehensive guide to Flutter development',
        );
      case '978-0987654321':
        return _createMockBook(
          id: 'isbn_2',
          title: 'Dart Programming Language',
          author: 'Jane Doe',
          isbn: isbn,
          description: 'Complete reference for Dart programming',
        );
      default:
        return null;
    }
  }

  BookModel _createMockBook({
    required String id,
    required String title,
    required String author,
    required String isbn,
    required String description,
  }) {
    return BookModel(
      id: id,
      title: title,
      author: author,
      imageUrls: ['https://via.placeholder.com/200x300/2196F3/FFFFFF?text=$title'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        rentPrice: 7.99,
        minimumCostToBuy: 29.99,
        maximumCostToBuy: 29.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 0,
        availableForSaleCount: 0,
        totalCopies: 0,
      ),
      metadata: BookMetadata(
        isbn: isbn,
        publisher: 'Tech Publishing',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: const ['Technology', 'Programming'],
        pageCount: 300,
        language: 'English',
        edition: '1st Edition',
      ),
      isFromFriend: false,
      description: description,
      publishedYear: 2024,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  BookModel _createBookFromForm(BookUploadFormModel form) {
    final now = DateTime.now();
    
    return BookModel(
      id: form.id ?? 'book_${now.millisecondsSinceEpoch}',
      title: form.title,
      author: form.author,
      imageUrls: form.copies.isNotEmpty && form.copies.first.imageUrls.isNotEmpty
          ? [form.copies.first.imageUrls.first]
          : [],
      rating: 0.0,
      pricing: BookPricing(
        salePrice: form.copies.isNotEmpty && form.copies.first.expectedPrice != null
            ? form.copies.first.expectedPrice!
            : 0.0,
        rentPrice: form.copies.isNotEmpty && form.copies.first.rentPrice != null
            ? form.copies.first.rentPrice!
            : 0.0,
        minimumCostToBuy: form.copies.isNotEmpty && form.copies.first.expectedPrice != null
            ? form.copies.first.expectedPrice!
            : 0.0,
        maximumCostToBuy: form.copies.isNotEmpty && form.copies.first.expectedPrice != null
            ? form.copies.first.expectedPrice!
            : 0.0,
      ),
      availability: BookAvailability(
        availableForRentCount: form.copies.where((c) => c.isForRent).length,
        availableForSaleCount: form.copies.where((c) => c.isForSale).length,
        totalCopies: form.copies.length,
      ),
      metadata: BookMetadata(
        isbn: form.isbn,
        publisher: form.publisher,
        ageAppropriateness: AgeAppropriateness.adult,
        genres: form.genres,
        pageCount: form.pageCount ?? 0,
        language: form.language ?? 'English',
        edition: '1st Edition',
      ),
      isFromFriend: false,
      description: form.description,
      publishedYear: form.publishedYear ?? now.year,
      createdAt: form.createdAt ?? now,
      updatedAt: form.updatedAt ?? now,
    );
  }

  static const List<String> _mockGenres = [
    'Technology',
    'Programming',
    'Fiction',
    'Non-Fiction',
    'Science',
    'History',
    'Biography',
    'Self-Help',
    'Fantasy',
    'Mystery',
    'Romance',
    'Horror',
    'Children',
    'Young Adult',
    'Academic',
    'Business',
    'Health',
    'Travel',
    'Cooking',
    'Art',
  ];

  static const List<String> _mockLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Russian',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
    'Bengali',
    'Other',
  ];
}
