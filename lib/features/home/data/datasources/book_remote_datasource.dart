import 'package:dio/dio.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';

abstract class BookRemoteDataSource {
  Future<List<BookModel>> getBooks({int page = 1, int limit = 20});
  Future<List<BookModel>> searchBooks(String query);
  Future<BookModel?> getBookById(String bookId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final Dio dio;

  BookRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookModel>> getBooks({int page = 1, int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Validate input parameters
    if (page < 1) page = 1;
    if (limit < 1) limit = 1;

    // Mock data - In a real app, you would make an API call here
    // final response = await dio.get('/books', queryParameters: {'page': page, 'limit': limit});
    // return (response.data as List).map((json) => BookModel.fromJson(json)).toList();

    // Simulate pagination by slicing the mock data
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    if (startIndex >= _mockBooks.length) {
      return []; // No more books
    }

    return _mockBooks.sublist(
      startIndex,
      endIndex > _mockBooks.length ? _mockBooks.length : endIndex,
    );
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // In a real app, you would make an API call with the query parameter
    // final response = await dio.get('/books/search', queryParameters: {'q': query});
    // return (response.data as List).map((json) => BookModel.fromJson(json)).toList();

    final normalizedQuery = query.toLowerCase();

    return _mockBooks.where((book) =>
        book.title.toLowerCase().contains(normalizedQuery) ||
        book.author.toLowerCase().contains(normalizedQuery) ||
        book.metadata.genres.any(
          (genre) => genre.toLowerCase().contains(normalizedQuery),
        )).toList();
  }

  @override
  Future<BookModel?> getBookById(String bookId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // In a real app, you would make an API call to get a specific book
    // final response = await dio.get('/books/$bookId');
    // return BookModel.fromJson(response.data);

    try {
      return _mockBooks.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null; // Book not found
    }
  }

  static final List<BookModel> _mockBooks = [
    BookModel(
      id: '1',
      title: 'The Flutter Way',
      author: 'John Doe',
      imageUrls: const [
        'https://picsum.photos/seed/flutter-way-front/200/300',
        'https://picsum.photos/seed/flutter-way-back/200/300',
      ],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 29.99,
        discountedSalePrice: 24.99,
        rentPrice: 5.99,
        discountedRentPrice: 4.99,
        percentageDiscountForRent: 16.7,
        percentageDiscountForSale: 16.7,
        minimumCostToBuy: 24.99,
        maximumCostToBuy: 29.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 3,
        availableForSaleCount: 5,
        totalCopies: 8,
      ),
      metadata: const BookMetadata(
        isbn: '978-0-123456-78-9',
        publisher: 'Tech Books Publishing',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Technology', 'Programming', 'Mobile Development'],
        pageCount: 320,
        language: 'English',
        edition: '2nd Edition',
      ),
      isFromFriend: false,
      description: 'A comprehensive guide to Flutter development covering state management, architecture, and best practices.',
      publishedYear: 2024,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
    BookModel(
      id: '2',
      title: 'Clean Architecture',
      author: 'Robert C. Martin',
      imageUrls: const [
        'https://picsum.photos/seed/clean-architecture/200/300',
      ],
      rating: 4.8,
      pricing: const BookPricing(
        salePrice: 35.99,
        rentPrice: 7.99,
        discountedRentPrice: 6.99,
        percentageDiscountForRent: 12.5,
        minimumCostToBuy: 35.99,
        maximumCostToBuy: 35.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 2,
        availableForSaleCount: 10,
        totalCopies: 12,
      ),
      metadata: const BookMetadata(
        isbn: '978-0-134494-16-5',
        publisher: 'Prentice Hall',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Software Engineering', 'Programming', 'Architecture'],
        pageCount: 432,
        language: 'English',
        edition: '1st Edition',
      ),
      isFromFriend: false,
      description: 'A craftsman\'s guide to software structure and design',
      publishedYear: 2017,
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime(2024, 1, 10),
    ),
    BookModel(
      id: '3',
      title: 'Dart Programming',
      author: 'Jane Smith',
      imageUrls: const [
        'https://picsum.photos/seed/dart-programming-front/200/300',
        'https://picsum.photos/seed/dart-programming-back/200/300',
      ],
      rating: 4.2,
      pricing: const BookPricing(
        salePrice: 22.99,
        discountedSalePrice: 18.99,
        rentPrice: 4.99,
        discountedRentPrice: 3.99,
        percentageDiscountForRent: 20.0,
        percentageDiscountForSale: 17.4,
        minimumCostToBuy: 18.99,
        maximumCostToBuy: 22.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 4,
        availableForSaleCount: 3,
        totalCopies: 7,
      ),
      metadata: const BookMetadata(
        isbn: '978-1-234567-89-0',
        publisher: 'Programming Press',
        ageAppropriateness: AgeAppropriateness.youngAdult,
        genres: ['Programming', 'Dart', 'Technology'],
        pageCount: 280,
        language: 'English',
        edition: '3rd Edition',
      ),
      isFromFriend: true,
      description: 'Master the Dart programming language with practical examples and exercises.',
      publishedYear: 2023,
      createdAt: DateTime(2024, 1, 5),
      updatedAt: DateTime(2024, 1, 5),
    ),
    BookModel(
      id: '4',
      title: 'Mobile UI/UX Design',
      author: 'Sarah Wilson',
      imageUrls: const [
        'https://picsum.photos/seed/mobile-uiux-front/200/300',
        'https://picsum.photos/seed/mobile-uiux-back/200/300',
      ],
      rating: 4.6,
      pricing: const BookPricing(
        salePrice: 27.99,
        rentPrice: 6.99,
        minimumCostToBuy: 27.99,
        maximumCostToBuy: 27.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 2,
        availableForSaleCount: 0,
        totalCopies: 2,
      ),
      metadata: const BookMetadata(
        isbn: '978-2-345678-90-1',
        publisher: 'Design Studio Books',
        ageAppropriateness: AgeAppropriateness.allAges,
        genres: ['Design', 'UI/UX', 'Mobile'],
        pageCount: 240,
        language: 'English',
        edition: '1st Edition',
      ),
      isFromFriend: false,
      description: 'Design principles for mobile applications with modern UI/UX practices.',
      publishedYear: 2023,
      createdAt: DateTime(2024, 1, 8),
      updatedAt: DateTime(2024, 1, 8),
    ),
    BookModel(
      id: '5',
      title: 'State Management in Flutter',
      author: 'Mike Johnson',
      imageUrls: const [
        'https://picsum.photos/seed/state-management-flutter/200/300',
      ],
      rating: 4.7,
      pricing: const BookPricing(
        salePrice: 31.99,
        discountedSalePrice: 25.99,
        rentPrice: 7.99,
        discountedRentPrice: 6.49,
        percentageDiscountForRent: 18.8,
        percentageDiscountForSale: 18.8,
        minimumCostToBuy: 25.99,
        maximumCostToBuy: 31.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 5,
        availableForSaleCount: 7,
        totalCopies: 12,
      ),
      metadata: const BookMetadata(
        isbn: '978-3-456789-01-2',
        publisher: 'Flutter Publishing',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Technology', 'Flutter', 'State Management'],
        pageCount: 380,
        language: 'English',
        edition: '1st Edition',
      ),
      isFromFriend: true,
      description: 'Complete guide to Flutter state management including BLoC, Provider, Riverpod, and more.',
      publishedYear: 2024,
      createdAt: DateTime(2024, 1, 12),
      updatedAt: DateTime(2024, 1, 12),
    ),
    BookModel(
      id: '6',
      title: 'Firebase for Mobile',
      author: 'David Brown',
      imageUrls: const [
        'https://picsum.photos/seed/firebase-mobile/200/300',
      ],
      rating: 4.3,
      pricing: const BookPricing(
        salePrice: 26.99,
        rentPrice: 5.99,
        minimumCostToBuy: 26.99,
        maximumCostToBuy: 26.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 0,
        availableForSaleCount: 8,
        totalCopies: 8,
      ),
      metadata: const BookMetadata(
        isbn: '978-4-567890-12-3',
        publisher: 'Cloud Tech Books',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Backend', 'Firebase', 'Mobile Development'],
        pageCount: 290,
        language: 'English',
        edition: '2nd Edition',
      ),
      isFromFriend: false,
      description: 'Backend services for mobile applications using Firebase cloud platform.',
      publishedYear: 2023,
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
    ),
    BookModel(
      id: '7',
      title: 'Advanced Flutter Patterns',
      author: 'Emily Johnson',
      imageUrls: [], // Empty array to test default placeholder
      rating: 4.4,
      pricing: const BookPricing(
        salePrice: 33.99,
        discountedSalePrice: 27.99,
        rentPrice: 6.99,
        discountedRentPrice: 5.49,
        percentageDiscountForRent: 21.5,
        percentageDiscountForSale: 17.7,
        minimumCostToBuy: 27.99,
        maximumCostToBuy: 33.99,
      ),
      availability: const BookAvailability(
        availableForRentCount: 2,
        availableForSaleCount: 4,
        totalCopies: 6,
      ),
      metadata: const BookMetadata(
        isbn: '978-5-678901-23-4',
        publisher: 'Advanced Tech Publications',
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Technology', 'Flutter', 'Advanced Programming'],
        pageCount: 450,
        language: 'English',
        edition: '1st Edition',
      ),
      isFromFriend: false,
      description: 'Deep dive into advanced Flutter patterns and architectures for professional development.',
      publishedYear: 2024,
      createdAt: DateTime(2024, 1, 20),
      updatedAt: DateTime(2024, 1, 20),
    ),
  ];
}

// --- end of file ---
/*
  BookModel(
    id: '1',
    title: 'The Flutter Way',
    author: 'John Doe',
    imageUrls: const [
      'https://picsum.photos/seed/flutter-way-front/200/300',
      'https://picsum.photos/seed/flutter-way-back/200/300',
    ],
    rating: 4.5,
    pricing: const BookPricing(
      salePrice: 29.99,
      discountedSalePrice: 24.99,
      rentPrice: 5.99,
      discountedRentPrice: 4.99,
      percentageDiscountForRent: 16.7,
      percentageDiscountForSale: 16.7,
      minimumCostToBuy: 24.99,
      maximumCostToBuy: 29.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 3,
      availableForSaleCount: 5,
      totalCopies: 8,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-123456-78-9',
      publisher: 'Tech Books Publishing',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Technology', 'Programming', 'Mobile Development'],
      pageCount: 320,
      language: 'English',
      edition: '2nd Edition',
    ),
    isFromFriend: false,
    isFavorite: false,
    description: 'A comprehensive guide to Flutter development covering state management, architecture, and best practices.',
    publishedYear: 2024,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  ),
  BookModel(
    id: '2',
    title: 'Clean Architecture',
    author: 'Robert C. Martin',
    imageUrls: const [
      'https://picsum.photos/seed/clean-architecture/200/300',
    ],
    rating: 4.8,
    pricing: const BookPricing(
      salePrice: 35.99,
      rentPrice: 7.99,
      discountedRentPrice: 6.99,
      percentageDiscountForRent: 12.5,
      minimumCostToBuy: 35.99,
      maximumCostToBuy: 35.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 2,
      availableForSaleCount: 10,
      totalCopies: 12,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-134494-16-5',
      publisher: 'Prentice Hall',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Software Engineering', 'Programming', 'Architecture'],
      pageCount: 432,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    isFavorite: false,
    description: 'A craftsman\'s guide to software structure and design',
    publishedYear: 2017,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 10),
  ),
  BookModel(
    id: '3',
    title: 'Dart Programming',
    author: 'Jane Smith',
    imageUrls: const [
      'https://picsum.photos/seed/dart-programming-front/200/300',
      'https://picsum.photos/seed/dart-programming-back/200/300',
    ],
    rating: 4.2,
    pricing: const BookPricing(
      salePrice: 22.99,
      discountedSalePrice: 18.99,
      rentPrice: 4.99,
      discountedRentPrice: 3.99,
      percentageDiscountForRent: 20.0,
      percentageDiscountForSale: 17.4,
      minimumCostToBuy: 18.99,
      maximumCostToBuy: 22.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 4,
      availableForSaleCount: 3,
      totalCopies: 7,
    ),
    metadata: const BookMetadata(
      isbn: '978-1-234567-89-0',
      publisher: 'Programming Press',
      ageAppropriateness: AgeAppropriateness.youngAdult,
      genres: ['Programming', 'Dart', 'Technology'],
      pageCount: 280,
      language: 'English',
      edition: '3rd Edition',
    ),
    isFromFriend: true,
    isFavorite: false,
    description: 'Master the Dart programming language with practical examples and exercises.',
    publishedYear: 2023,
    createdAt: DateTime(2024, 1, 5),
    updatedAt: DateTime(2024, 1, 5),
  ),
  BookModel(
    id: '4',
    title: 'Mobile UI/UX Design',
    author: 'Sarah Wilson',
    imageUrls: const [
      'https://picsum.photos/seed/mobile-uiux-front/200/300',
      'https://picsum.photos/seed/mobile-uiux-back/200/300',
    ],
    rating: 4.6,
    pricing: const BookPricing(
      salePrice: 27.99,
      rentPrice: 6.99,
      minimumCostToBuy: 27.99,
      maximumCostToBuy: 27.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 2,
      availableForSaleCount: 0,
      totalCopies: 2,
    ),
    metadata: const BookMetadata(
      isbn: '978-2-345678-90-1',
      publisher: 'Design Studio Books',
      ageAppropriateness: AgeAppropriateness.allAges,
      genres: ['Design', 'UI/UX', 'Mobile'],
      pageCount: 240,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    isFavorite: false,
    description: 'Design principles for mobile applications with modern UI/UX practices.',
    publishedYear: 2023,
    createdAt: DateTime(2024, 1, 8),
    updatedAt: DateTime(2024, 1, 8),
  ),
  BookModel(
    id: '5',
    title: 'State Management in Flutter',
    author: 'Mike Johnson',
    imageUrls: const [
      'https://picsum.photos/seed/state-management-flutter/200/300',
    ],
    rating: 4.7,
    pricing: const BookPricing(
      salePrice: 31.99,
      discountedSalePrice: 25.99,
      rentPrice: 7.99,
      discountedRentPrice: 6.49,
      percentageDiscountForRent: 18.8,
      percentageDiscountForSale: 18.8,
      minimumCostToBuy: 25.99,
      maximumCostToBuy: 31.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 5,
      availableForSaleCount: 7,
      totalCopies: 12,
    ),
    metadata: const BookMetadata(
      isbn: '978-3-456789-01-2',
      publisher: 'Flutter Publishing',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Technology', 'Flutter', 'State Management'],
      pageCount: 380,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: true,
    isFavorite: false,
    description: 'Complete guide to Flutter state management including BLoC, Provider, Riverpod, and more.',
    publishedYear: 2024,
    createdAt: DateTime(2024, 1, 12),
    updatedAt: DateTime(2024, 1, 12),
  ),
  BookModel(
    id: '6',
    title: 'Firebase for Mobile',
    author: 'David Brown',
    imageUrls: const [
      'https://picsum.photos/seed/firebase-mobile/200/300',
    ],
    rating: 4.3,
    pricing: const BookPricing(
      salePrice: 26.99,
      rentPrice: 5.99,
      minimumCostToBuy: 26.99,
      maximumCostToBuy: 26.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 0,
      availableForSaleCount: 8,
      totalCopies: 8,
    ),
    metadata: const BookMetadata(
      isbn: '978-4-567890-12-3',
      publisher: 'Cloud Tech Books',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Backend', 'Firebase', 'Mobile Development'],
      pageCount: 290,
      language: 'English',
      edition: '2nd Edition',
    ),
    isFromFriend: false,
    isFavorite: false,
    description: 'Backend services for mobile applications using Firebase cloud platform.',
    publishedYear: 2023,
    createdAt: DateTime(2024, 1, 3),
    updatedAt: DateTime(2024, 1, 3),
  ),
  BookModel(
    id: '7',
    title: 'Advanced Flutter Patterns',
    author: 'Emily Johnson',
    imageUrls: [], // Empty array to test default placeholder
    rating: 4.4,
    pricing: const BookPricing(
      salePrice: 33.99,
      discountedSalePrice: 27.99,
      rentPrice: 6.99,
      discountedRentPrice: 5.49,
      percentageDiscountForRent: 21.5,
      percentageDiscountForSale: 17.7,
      minimumCostToBuy: 27.99,
      maximumCostToBuy: 33.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 2,
      availableForSaleCount: 4,
      totalCopies: 6,
    ),
    metadata: const BookMetadata(
      isbn: '978-5-678901-23-4',
      publisher: 'Advanced Tech Publications',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Technology', 'Flutter', 'Advanced Programming'],
      pageCount: 450,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    isFavorite: false,
    description: 'Deep dive into advanced Flutter patterns and architectures for professional development.',
    publishedYear: 2024,
    createdAt: DateTime(2024, 1, 20),
    updatedAt: DateTime(2024, 1, 20),
  ),
];
*/