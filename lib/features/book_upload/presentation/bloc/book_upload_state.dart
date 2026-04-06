import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';

/// States for book upload
abstract class BookUploadState extends Equatable {
  const BookUploadState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BookUploadInitial extends BookUploadState {
  const BookUploadInitial();
}

/// Loading state
class BookUploadLoading extends BookUploadState {
  const BookUploadLoading();
}

/// Form loaded state
class BookUploadLoaded extends BookUploadState {
  final BookUploadForm form;
  final List<Book> searchResults;
  final List<String> genres;
  final List<String> languages;
  final bool isSearching;
  final bool isUploadingImage;
  final String? searchError;
  final String? uploadError;
  final String? successMessage;

  const BookUploadLoaded({
    required this.form,
    this.searchResults = const [],
    this.genres = const [],
    this.languages = const [],
    this.isSearching = false,
    this.isUploadingImage = false,
    this.searchError,
    this.uploadError,
    this.successMessage,
  });

  @override
  List<Object?> get props => [
        form,
        searchResults,
        genres,
        languages,
        isSearching,
        isUploadingImage,
        searchError,
        uploadError,
        successMessage,
      ];

  BookUploadLoaded copyWith({
    BookUploadForm? form,
    List<Book>? searchResults,
    List<String>? genres,
    List<String>? languages,
    bool? isSearching,
    bool? isUploadingImage,
    String? searchError,
    String? uploadError,
    String? successMessage,
    bool clearSearchError = false,
    bool clearUploadError = false,
    bool clearSuccessMessage = false,
  }) {
    return BookUploadLoaded(
      form: form ?? this.form,
      searchResults: searchResults ?? this.searchResults,
      genres: genres ?? this.genres,
      languages: languages ?? this.languages,
      isSearching: isSearching ?? this.isSearching,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      searchError: clearSearchError ? null : (searchError ?? this.searchError),
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Error state
class BookUploadError extends BookUploadState {
  final String message;

  const BookUploadError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Success state
class BookUploadSuccess extends BookUploadState {
  final Book uploadedBook;
  final String message;

  const BookUploadSuccess({
    required this.uploadedBook,
    required this.message,
  });

  @override
  List<Object?> get props => [uploadedBook, message];
}
