import 'package:equatable/equatable.dart';
import 'age_appropriateness.dart';

/// Value object for book metadata including ISBN, publisher, genres, etc.
class BookMetadata extends Equatable {
  final String? isbn;
  final String? publisher;
  final AgeAppropriateness ageAppropriateness;
  final List<String> genres;
  final int pageCount;
  final String language;
  final String? edition;

  const BookMetadata({
    this.isbn,
    this.publisher,
    required this.ageAppropriateness,
    required this.genres,
    required this.pageCount,
    required this.language,
    this.edition,
  });

  /// Primary genre (first in the list)
  String get primaryGenre => genres.isNotEmpty ? genres.first : 'Unknown';

  /// Whether book has multiple genres
  bool get hasMultipleGenres => genres.length > 1;

  /// Formatted genre string for display
  String get genreDisplay => genres.join(', ');

  BookMetadata copyWith({
    String? isbn,
    String? publisher,
    AgeAppropriateness? ageAppropriateness,
    List<String>? genres,
    int? pageCount,
    String? language,
    String? edition,
  }) {
    return BookMetadata(
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      ageAppropriateness: ageAppropriateness ?? this.ageAppropriateness,
      genres: genres ?? this.genres,
      pageCount: pageCount ?? this.pageCount,
      language: language ?? this.language,
      edition: edition ?? this.edition,
    );
  }

  @override
  List<Object?> get props => [
        isbn,
        publisher,
        ageAppropriateness,
        genres,
        pageCount,
        language,
        edition,
      ];
}
