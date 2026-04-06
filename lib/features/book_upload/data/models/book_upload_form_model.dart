import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/data/models/book_copy_model.dart';

/// Data model for book upload form
class BookUploadFormModel extends BookUploadForm {
  const BookUploadFormModel({
    super.id,
    required super.title,
    required super.isbn,
    required super.author,
    required super.description,
    required super.genres,
    super.publishedYear,
    super.publisher,
    super.language,
    super.pageCount,
    super.ageAppropriateness,
    required super.copies,
    super.isSearchResult = false,
    super.createdAt,
    super.updatedAt,
  });

  /// Create model from JSON
  factory BookUploadFormModel.fromJson(Map<String, dynamic> json) {
    return BookUploadFormModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      isbn: json['isbn'] as String? ?? '',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      publishedYear: json['publishedYear'] as int?,
      publisher: json['publisher'] as String?,
      language: json['language'] as String?,
      pageCount: json['pageCount'] as int?,
      ageAppropriateness: json['ageAppropriateness'] as int?,
      copies: (json['copies'] as List<dynamic>?)
          ?.map((e) => BookCopyModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      isSearchResult: json['isSearchResult'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isbn': isbn,
      'author': author,
      'description': description,
      'genres': genres,
      'publishedYear': publishedYear,
      'publisher': publisher,
      'language': language,
      'pageCount': pageCount,
      'ageAppropriateness': ageAppropriateness,
      'copies': copies.map((copy) => BookCopyModel.fromEntity(copy).toJson()).toList(),
      'isSearchResult': isSearchResult,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create model from entity
  factory BookUploadFormModel.fromEntity(BookUploadForm form) {
    return BookUploadFormModel(
      id: form.id,
      title: form.title,
      isbn: form.isbn,
      author: form.author,
      description: form.description,
      genres: form.genres,
      publishedYear: form.publishedYear,
      publisher: form.publisher,
      language: form.language,
      pageCount: form.pageCount,
      ageAppropriateness: form.ageAppropriateness,
      copies: form.copies,
      isSearchResult: form.isSearchResult,
      createdAt: form.createdAt,
      updatedAt: form.updatedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  BookUploadFormModel copyWith({
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
    List<dynamic>? copies,
    bool? isSearchResult,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookUploadFormModel(
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
      copies: copies?.cast() ?? this.copies,
      isSearchResult: isSearchResult ?? this.isSearchResult,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
