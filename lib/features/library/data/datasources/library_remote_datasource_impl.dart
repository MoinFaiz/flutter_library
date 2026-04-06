import 'package:dio/dio.dart';
import 'package:flutter_library/features/books/data/models/book_model.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/library/data/datasources/library_remote_datasource.dart';

/// Implementation of LibraryRemoteDataSource
class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final Dio dio;

  LibraryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BookModel>> getBorrowedBooks({int page = 1, int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // In a real app, you would make an API call here
    // final response = await dio.get('/user/borrowed-books', queryParameters: {'page': page, 'limit': limit});
    // return (response.data as List).map((json) => BookModel.fromJson(json)).toList();
    
    // Mock borrowed books data
    return _getMockBorrowedBooks(page: page, limit: limit);
  }

  @override
  Future<List<BookModel>> getUploadedBooks({int page = 1, int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));
    
    // In a real app, you would make an API call here
    // final response = await dio.get('/user/uploaded-books', queryParameters: {'page': page, 'limit': limit});
    // return (response.data as List).map((json) => BookModel.fromJson(json)).toList();
    
    // Mock uploaded books data
    return _getMockUploadedBooks(page: page, limit: limit);
  }

  List<BookModel> _getMockBorrowedBooks({int page = 1, int limit = 20}) {
    // Validate input parameters
    if (page < 1) page = 1;
    if (limit < 1) limit = 1;
    
    // Simulate pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= _mockBorrowedBooks.length) {
      return []; // No more books
    }
    
    return _mockBorrowedBooks.sublist(
      startIndex, 
      endIndex > _mockBorrowedBooks.length ? _mockBorrowedBooks.length : endIndex
    );
  }

  List<BookModel> _getMockUploadedBooks({int page = 1, int limit = 20}) {
    // Validate input parameters
    if (page < 1) page = 1;
    if (limit < 1) limit = 1;
    
    // Simulate pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= _mockUploadedBooks.length) {
      return []; // No more books
    }
    
    return _mockUploadedBooks.sublist(
      startIndex, 
      endIndex > _mockUploadedBooks.length ? _mockUploadedBooks.length : endIndex
    );
  }
}

// Mock data for borrowed books
final List<BookModel> _mockBorrowedBooks = [
  BookModel(
    id: 'borrowed_1',
    title: 'Clean Code',
    author: 'Robert C. Martin',
    imageUrls: [
      'https://via.placeholder.com/200x300/FF5722/FFFFFF?text=Clean+Code',
    ],
    rating: 4.8,
    pricing: const BookPricing(
      salePrice: 0.0,
      rentPrice: 7.99,
      minimumCostToBuy: 0.0,
      maximumCostToBuy: 0.0,
    ),
    availability: const BookAvailability(
      availableForRentCount: 0,
      availableForSaleCount: 0,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-132350-88-4',
      publisher: 'Prentice Hall',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Programming', 'Software Engineering'],
      pageCount: 464,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'A handbook of agile software craftsmanship.',
    publishedYear: 2008,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  ),
  BookModel(
    id: 'borrowed_2',
    title: 'The Pragmatic Programmer',
    author: 'Dave Thomas',
    imageUrls: [
      'https://via.placeholder.com/200x300/2196F3/FFFFFF?text=Pragmatic+Programmer',
    ],
    rating: 4.6,
    pricing: const BookPricing(
      salePrice: 0.0,
      rentPrice: 8.99,
      minimumCostToBuy: 0.0,
      maximumCostToBuy: 0.0,
    ),
    availability: const BookAvailability(
      availableForRentCount: 0,
      availableForSaleCount: 0,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-201616-22-3',
      publisher: 'Addison-Wesley',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Programming', 'Software Development'],
      pageCount: 352,
      language: 'English',
      edition: '2nd Edition',
    ),
    isFromFriend: false,
    description: 'Your journey to mastery.',
    publishedYear: 2019,
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 10),
  ),
  BookModel(
    id: 'borrowed_3',
    title: 'Design Patterns',
    author: 'Gang of Four',
    imageUrls: [
      'https://via.placeholder.com/200x300/4CAF50/FFFFFF?text=Design+Patterns',
    ],
    rating: 4.4,
    pricing: const BookPricing(
      salePrice: 0.0,
      rentPrice: 9.99,
      minimumCostToBuy: 0.0,
      maximumCostToBuy: 0.0,
    ),
    availability: const BookAvailability(
      availableForRentCount: 0,
      availableForSaleCount: 0,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-201633-61-2',
      publisher: 'Addison-Wesley',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Programming', 'Design Patterns'],
      pageCount: 395,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Elements of reusable object-oriented software.',
    publishedYear: 1994,
    createdAt: DateTime(2024, 1, 5),
    updatedAt: DateTime(2024, 1, 5),
  ),
  BookModel(
    id: 'borrowed_4',
    title: 'Refactoring',
    author: 'Martin Fowler',
    imageUrls: [
      'https://via.placeholder.com/200x300/9C27B0/FFFFFF?text=Refactoring',
    ],
    rating: 4.5,
    pricing: const BookPricing(
      salePrice: 0.0,
      rentPrice: 8.49,
      minimumCostToBuy: 0.0,
      maximumCostToBuy: 0.0,
    ),
    availability: const BookAvailability(
      availableForRentCount: 0,
      availableForSaleCount: 0,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-134757-59-9',
      publisher: 'Addison-Wesley',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Programming', 'Software Engineering'],
      pageCount: 448,
      language: 'English',
      edition: '2nd Edition',
    ),
    isFromFriend: false,
    description: 'Improving the design of existing code.',
    publishedYear: 2018,
    createdAt: DateTime(2023, 12, 20),
    updatedAt: DateTime(2023, 12, 20),
  ),
  BookModel(
    id: 'borrowed_5',
    title: 'Effective Java',
    author: 'Joshua Bloch',
    imageUrls: [
      'https://via.placeholder.com/200x300/FF9800/FFFFFF?text=Effective+Java',
    ],
    rating: 4.7,
    pricing: const BookPricing(
      salePrice: 0.0,
      rentPrice: 7.99,
      minimumCostToBuy: 0.0,
      maximumCostToBuy: 0.0,
    ),
    availability: const BookAvailability(
      availableForRentCount: 0,
      availableForSaleCount: 0,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-134685-99-1',
      publisher: 'Addison-Wesley',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Java', 'Programming'],
      pageCount: 416,
      language: 'English',
      edition: '3rd Edition',
    ),
    isFromFriend: false,
    description: 'Best practices for the Java platform.',
    publishedYear: 2017,
    createdAt: DateTime(2023, 12, 15),
    updatedAt: DateTime(2023, 12, 15),
  ),
  BookModel(
    id: 'borrowed_6',
    title: 'You Don\'t Know JS',
    author: 'Kyle Simpson',
    imageUrls: [
      'https://via.placeholder.com/200x300/E91E63/FFFFFF?text=You+Dont+Know+JS',
    ],
    rating: 4.3,
    pricing: const BookPricing(
      salePrice: 0.0,
      rentPrice: 6.99,
      minimumCostToBuy: 0.0,
      maximumCostToBuy: 0.0,
    ),
    availability: const BookAvailability(
      availableForRentCount: 0,
      availableForSaleCount: 0,
      totalCopies: 1,
    ),
    metadata: const BookMetadata(
      isbn: '978-1-491904-24-4',
      publisher: 'O\'Reilly Media',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['JavaScript', 'Programming'],
      pageCount: 278,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Scope & Closures, this & Object Prototypes, Types & Grammar.',
    publishedYear: 2014,
    createdAt: DateTime(2023, 12, 10),
    updatedAt: DateTime(2023, 12, 10),
  ),
];

// Mock data for uploaded books
final List<BookModel> _mockUploadedBooks = [
  BookModel(
    id: 'uploaded_1',
    title: 'Flutter in Action',
    author: 'Eric Windmill',
    imageUrls: [
      'https://via.placeholder.com/200x300/3F51B5/FFFFFF?text=Flutter+Action',
    ],
    rating: 4.2,
    pricing: const BookPricing(
      salePrice: 25.99,
      rentPrice: 5.99,
      minimumCostToBuy: 25.99,
      maximumCostToBuy: 25.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 2,
      availableForSaleCount: 1,
      totalCopies: 3,
    ),
    metadata: const BookMetadata(
      isbn: '978-1-617296-14-2',
      publisher: 'Manning Publications',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Flutter', 'Mobile Development'],
      pageCount: 368,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Build beautiful cross-platform mobile apps with Flutter.',
    publishedYear: 2019,
    createdAt: DateTime(2024, 1, 20),
    updatedAt: DateTime(2024, 1, 20),
  ),
  BookModel(
    id: 'uploaded_2',
    title: 'Dart Apprentice',
    author: 'Jonathan Sande',
    imageUrls: [
      'https://via.placeholder.com/200x300/00BCD4/FFFFFF?text=Dart+Apprentice',
    ],
    rating: 4.4,
    pricing: const BookPricing(
      salePrice: 32.99,
      rentPrice: 7.99,
      minimumCostToBuy: 32.99,
      maximumCostToBuy: 32.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 1,
      availableForSaleCount: 2,
      totalCopies: 3,
    ),
    metadata: const BookMetadata(
      isbn: '978-1-950325-07-1',
      publisher: 'Kodeco',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Dart', 'Programming'],
      pageCount: 412,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Beginning programming with Dart.',
    publishedYear: 2021,
    createdAt: DateTime(2024, 1, 18),
    updatedAt: DateTime(2024, 1, 18),
  ),
  BookModel(
    id: 'uploaded_3',
    title: 'Firebase Essentials',
    author: 'Alex Johnson',
    imageUrls: [
      'https://via.placeholder.com/200x300/FF5722/FFFFFF?text=Firebase+Essentials',
    ],
    rating: 4.1,
    pricing: const BookPricing(
      salePrice: 28.99,
      rentPrice: 6.99,
      minimumCostToBuy: 28.99,
      maximumCostToBuy: 28.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 3,
      availableForSaleCount: 1,
      totalCopies: 4,
    ),
    metadata: const BookMetadata(
      isbn: '978-1-234567-89-0',
      publisher: 'Tech Publications',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Firebase', 'Backend'],
      pageCount: 298,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Complete guide to Firebase for mobile app development.',
    publishedYear: 2022,
    createdAt: DateTime(2024, 1, 16),
    updatedAt: DateTime(2024, 1, 16),
  ),
  BookModel(
    id: 'uploaded_4',
    title: 'State Management Guide',
    author: 'Sarah Developer',
    imageUrls: [
      'https://via.placeholder.com/200x300/673AB7/FFFFFF?text=State+Management',
    ],
    rating: 4.6,
    pricing: const BookPricing(
      salePrice: 31.99,
      rentPrice: 8.99,
      minimumCostToBuy: 31.99,
      maximumCostToBuy: 31.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 2,
      availableForSaleCount: 2,
      totalCopies: 4,
    ),
    metadata: const BookMetadata(
      isbn: '978-0-987654-32-1',
      publisher: 'Mobile Books',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Flutter', 'State Management'],
      pageCount: 356,
      language: 'English',
      edition: '2nd Edition',
    ),
    isFromFriend: false,
    description: 'Master state management in Flutter applications.',
    publishedYear: 2023,
    createdAt: DateTime(2024, 1, 14),
    updatedAt: DateTime(2024, 1, 14),
  ),
  BookModel(
    id: 'uploaded_5',
    title: 'Responsive UI Design',
    author: 'Mike Designer',
    imageUrls: [
      'https://via.placeholder.com/200x300/8BC34A/FFFFFF?text=Responsive+UI',
    ],
    rating: 4.3,
    pricing: const BookPricing(
      salePrice: 27.99,
      rentPrice: 6.49,
      minimumCostToBuy: 27.99,
      maximumCostToBuy: 27.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 1,
      availableForSaleCount: 3,
      totalCopies: 4,
    ),
    metadata: const BookMetadata(
      isbn: '978-1-111111-11-1',
      publisher: 'Design Press',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['UI/UX', 'Design'],
      pageCount: 284,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Creating beautiful responsive user interfaces.',
    publishedYear: 2023,
    createdAt: DateTime(2024, 1, 12),
    updatedAt: DateTime(2024, 1, 12),
  ),
  BookModel(
    id: 'uploaded_6',
    title: 'Testing Flutter Apps',
    author: 'John Tester',
    imageUrls: [
      'https://via.placeholder.com/200x300/795548/FFFFFF?text=Testing+Flutter',
    ],
    rating: 4.5,
    pricing: const BookPricing(
      salePrice: 29.99,
      rentPrice: 7.49,
      minimumCostToBuy: 29.99,
      maximumCostToBuy: 29.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 2,
      availableForSaleCount: 1,
      totalCopies: 3,
    ),
    metadata: const BookMetadata(
      isbn: '978-2-222222-22-2',
      publisher: 'Test Publications',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Testing', 'Flutter'],
      pageCount: 324,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Comprehensive testing strategies for Flutter applications.',
    publishedYear: 2022,
    createdAt: DateTime(2024, 1, 8),
    updatedAt: DateTime(2024, 1, 8),
  ),
  BookModel(
    id: 'uploaded_7',
    title: 'Animation Mastery',
    author: 'Lisa Animator',
    imageUrls: [
      'https://via.placeholder.com/200x300/607D8B/FFFFFF?text=Animation+Mastery',
    ],
    rating: 4.7,
    pricing: const BookPricing(
      salePrice: 34.99,
      rentPrice: 8.99,
      minimumCostToBuy: 34.99,
      maximumCostToBuy: 34.99,
    ),
    availability: const BookAvailability(
      availableForRentCount: 1,
      availableForSaleCount: 2,
      totalCopies: 3,
    ),
    metadata: const BookMetadata(
      isbn: '978-3-333333-33-3',
      publisher: 'Animation Studios',
      ageAppropriateness: AgeAppropriateness.adult,
      genres: ['Animation', 'Flutter'],
      pageCount: 398,
      language: 'English',
      edition: '1st Edition',
    ),
    isFromFriend: false,
    description: 'Advanced animation techniques for mobile applications.',
    publishedYear: 2023,
    createdAt: DateTime(2024, 1, 6),
    updatedAt: DateTime(2024, 1, 6),
  ),
];
