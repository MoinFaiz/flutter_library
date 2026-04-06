import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';

/// Entity representing book upload form data
class BookUploadForm extends Equatable {
  final String? id; // Book ID if editing existing book
  final String title;
  final String isbn;
  final String author;
  final String description;
  final List<String> genres;
  final int? publishedYear;
  final String? publisher;
  final String? language;
  final int? pageCount;
  final int? ageAppropriateness;
  final List<BookCopy> copies;
  final bool isSearchResult; // Whether this was populated from search
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BookUploadForm({
    this.id,
    required this.title,
    required this.isbn,
    required this.author,
    required this.description,
    required this.genres,
    this.publishedYear,
    this.publisher,
    this.language,
    this.pageCount,
    this.ageAppropriateness,
    required this.copies,
    this.isSearchResult = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Empty form for initial state
  factory BookUploadForm.empty() {
    return const BookUploadForm(
      title: '',
      isbn: '',
      author: '',
      description: '',
      genres: [],
      copies: [],
    );
  }

  /// Whether the form has minimum required fields
  bool get isMinimallyValid {
    return title.trim().isNotEmpty &&
           isbn.trim().isNotEmpty &&
           author.trim().isNotEmpty;
  }

  /// Whether the form is completely valid for submission
  bool get isValid {
    return isMinimallyValid &&
           description.trim().isNotEmpty &&
           genres.isNotEmpty &&
           publishedYear != null &&
           copies.isNotEmpty &&
           copies.every((copy) => copy.isValid);
  }

  /// Whether this form has any data entered
  bool get hasData {
    return title.isNotEmpty ||
           isbn.isNotEmpty ||
           author.isNotEmpty ||
           description.isNotEmpty ||
           genres.isNotEmpty ||
           publishedYear != null ||
           publisher != null ||
           language != null ||
           pageCount != null ||
           ageAppropriateness != null ||
           copies.isNotEmpty;
  }

  /// Whether the book fields are locked (from search result)
  bool get isLocked => isSearchResult;

  /// Number of valid copies
  int get validCopiesCount => copies.where((copy) => copy.isValid).length;

  /// Total number of copies
  int get totalCopiesCount => copies.length;

  /// Whether there are any incomplete copies
  bool get hasIncompleteCopies => copies.any((copy) => !copy.isValid);

  BookUploadForm copyWith({
    String? id,
    String? title,
    String? isbn,
    String? author,
    String? description,
    List<String>? genres,
    int? publishedYear,
    String? publisher,
    String? language,
    int? pageCount,
    int? ageAppropriateness,
    List<BookCopy>? copies,
    bool? isSearchResult,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookUploadForm(
      id: id ?? this.id,
      title: title ?? this.title,
      isbn: isbn ?? this.isbn,
      author: author ?? this.author,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      publishedYear: publishedYear ?? this.publishedYear,
      publisher: publisher ?? this.publisher,
      language: language ?? this.language,
      pageCount: pageCount ?? this.pageCount,
      ageAppropriateness: ageAppropriateness ?? this.ageAppropriateness,
      copies: copies ?? this.copies,
      isSearchResult: isSearchResult ?? this.isSearchResult,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        isbn,
        author,
        description,
        genres,
        publishedYear,
        publisher,
        language,
        pageCount,
        ageAppropriateness,
        copies,
        isSearchResult,
        createdAt,
        updatedAt,
      ];
}
