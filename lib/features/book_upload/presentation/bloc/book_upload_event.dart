import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';

/// Events for book upload
abstract class BookUploadEvent extends Equatable {
  const BookUploadEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize the upload form
class InitializeForm extends BookUploadEvent {
  final BookUploadForm? initialForm;

  const InitializeForm({this.initialForm});

  @override
  List<Object?> get props => [initialForm];
}

/// Update form field with string value
class UpdateStringField extends BookUploadEvent {
  final String field;
  final String value;

  const UpdateStringField({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

/// Update form field with nullable string value
class UpdateNullableStringField extends BookUploadEvent {
  final String field;
  final String? value;

  const UpdateNullableStringField({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

/// Update form field with int value
class UpdateIntField extends BookUploadEvent {
  final String field;
  final int? value;

  const UpdateIntField({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

/// Update form field with list of strings value
class UpdateStringListField extends BookUploadEvent {
  final String field;
  final List<String> value;

  const UpdateStringListField({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

/// Search books by query
class SearchBooks extends BookUploadEvent {
  final String query;

  const SearchBooks(this.query);

  @override
  List<Object?> get props => [query];
}

/// Clear search results
class ClearSearchResults extends BookUploadEvent {
  const ClearSearchResults();
}

/// Select book from search results
class SelectBookFromSearch extends BookUploadEvent {
  final Book book;

  const SelectBookFromSearch(this.book);

  @override
  List<Object?> get props => [book];
}

/// Get book by ISBN
class GetBookByIsbn extends BookUploadEvent {
  final String isbn;

  const GetBookByIsbn(this.isbn);

  @override
  List<Object?> get props => [isbn];
}

/// Add new copy
class AddNewCopy extends BookUploadEvent {
  const AddNewCopy();
}

/// Update copy
class UpdateCopy extends BookUploadEvent {
  final int copyIndex;
  final BookCopy copy;

  const UpdateCopy({required this.copyIndex, required this.copy});

  @override
  List<Object?> get props => [copyIndex, copy];
}

/// Remove copy
class RemoveCopy extends BookUploadEvent {
  final int copyIndex;

  const RemoveCopy(this.copyIndex);

  @override
  List<Object?> get props => [copyIndex];
}

/// Upload image
class UploadImage extends BookUploadEvent {
  final String filePath;

  const UploadImage(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Upload image for copy
class UploadImageForCopy extends BookUploadEvent {
  final int copyIndex;
  final String imageUrl;

  const UploadImageForCopy({required this.copyIndex, required this.imageUrl});

  @override
  List<Object?> get props => [copyIndex, imageUrl];
}

/// Remove image from copy
class RemoveImageFromCopy extends BookUploadEvent {
  final int copyIndex;
  final int imageIndex;

  const RemoveImageFromCopy({required this.copyIndex, required this.imageIndex});

  @override
  List<Object?> get props => [copyIndex, imageIndex];
}

/// Load genres
class LoadGenres extends BookUploadEvent {
  const LoadGenres();
}

/// Load languages
class LoadLanguages extends BookUploadEvent {
  const LoadLanguages();
}

/// Submit form
class SubmitForm extends BookUploadEvent {
  const SubmitForm();
}

/// Reset form
class ResetForm extends BookUploadEvent {
  const ResetForm();
}
