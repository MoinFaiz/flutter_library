import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_book_by_isbn_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_metadata_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/search_books_for_upload_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_book_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_image_usecase.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';

/// BLoC for managing book upload state
class BookUploadBloc extends Bloc<BookUploadEvent, BookUploadState> {
  final SearchBooksForUploadUseCase searchBooksUseCase;
  final GetBookByIsbnUseCase getBookByIsbnUseCase;
  final UploadBookUseCase uploadBookUseCase;
  final UploadImageUseCase uploadImageUseCase;
  final GetGenresUseCase getGenresUseCase;
  final GetLanguagesUseCase getLanguagesUseCase;

  BookUploadBloc({
    required this.searchBooksUseCase,
    required this.getBookByIsbnUseCase,
    required this.uploadBookUseCase,
    required this.uploadImageUseCase,
    required this.getGenresUseCase,
    required this.getLanguagesUseCase,
  }) : super(const BookUploadInitial()) {
    on<InitializeForm>(_onInitializeForm);
    on<UpdateStringField>(_onUpdateStringField);
    on<UpdateNullableStringField>(_onUpdateNullableStringField);
    on<UpdateIntField>(_onUpdateIntField);
    on<UpdateStringListField>(_onUpdateStringListField);
    on<SearchBooks>(_onSearchBooks);
    on<ClearSearchResults>(_onClearSearchResults);
    on<SelectBookFromSearch>(_onSelectBookFromSearch);
    on<GetBookByIsbn>(_onGetBookByIsbn);
    on<AddNewCopy>(_onAddNewCopy);
    on<UpdateCopy>(_onUpdateCopy);
    on<RemoveCopy>(_onRemoveCopy);
    on<UploadImage>(_onUploadImage);
    on<LoadGenres>(_onLoadGenres);
    on<LoadLanguages>(_onLoadLanguages);
    on<SubmitForm>(_onSubmitForm);
    on<ResetForm>(_onResetForm);
    on<UploadImageForCopy>(_onUploadImageForCopy);
    on<RemoveImageFromCopy>(_onRemoveImageFromCopy);
  }

  Future<void> _onInitializeForm(InitializeForm event, Emitter<BookUploadState> emit) async {
    emit(const BookUploadLoading());
    
    try {
      final form = event.initialForm ?? BookUploadForm.empty();
      
      // Load metadata
      final genresResult = await getGenresUseCase();
      final languagesResult = await getLanguagesUseCase();
      
      final genres = genresResult.fold((failure) => <String>[], (genres) => genres);
      final languages = languagesResult.fold((failure) => <String>[], (languages) => languages);
      
      emit(BookUploadLoaded(
        form: form,
        genres: genres,
        languages: languages,
      ));
    } catch (e) {
      emit(BookUploadError('Failed to initialize form: $e'));
    }
  }

  Future<void> _onUpdateStringField(UpdateStringField event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      final currentForm = currentState.form;
      
      BookUploadForm updatedForm;
      
      switch (event.field) {
        case 'title':
          updatedForm = currentForm.copyWith(title: event.value);
          break;
        case 'isbn':
          updatedForm = currentForm.copyWith(isbn: event.value);
          break;
        case 'author':
          updatedForm = currentForm.copyWith(author: event.value);
          break;
        case 'description':
          updatedForm = currentForm.copyWith(description: event.value);
          break;
        default:
          updatedForm = currentForm;
      }
      
      emit(currentState.copyWith(form: updatedForm));
    }
  }

  Future<void> _onUpdateNullableStringField(UpdateNullableStringField event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      final currentForm = currentState.form;
      
      BookUploadForm updatedForm;
      
      switch (event.field) {
        case 'publisher':
          updatedForm = currentForm.copyWith(publisher: event.value);
          break;
        case 'language':
          updatedForm = currentForm.copyWith(language: event.value);
          break;
        default:
          updatedForm = currentForm;
      }
      
      emit(currentState.copyWith(form: updatedForm));
    }
  }

  Future<void> _onUpdateIntField(UpdateIntField event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      final currentForm = currentState.form;
      
      BookUploadForm updatedForm;
      
      switch (event.field) {
        case 'publishedYear':
          updatedForm = currentForm.copyWith(publishedYear: event.value);
          break;
        case 'pageCount':
          updatedForm = currentForm.copyWith(pageCount: event.value);
          break;
        case 'ageAppropriateness':
          updatedForm = currentForm.copyWith(ageAppropriateness: event.value);
          break;
        default:
          updatedForm = currentForm;
      }
      
      emit(currentState.copyWith(form: updatedForm));
    }
  }

  Future<void> _onUpdateStringListField(UpdateStringListField event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      final currentForm = currentState.form;
      
      BookUploadForm updatedForm;
      
      switch (event.field) {
        case 'genres':
          updatedForm = currentForm.copyWith(genres: event.value);
          break;
        default:
          updatedForm = currentForm;
      }
      
      emit(currentState.copyWith(form: updatedForm));
    }
  }

  Future<void> _onSearchBooks(SearchBooks event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      emit(currentState.copyWith(isSearching: true, clearSearchError: true));
      
      final result = await searchBooksUseCase(event.query);
      
      result.fold(
        (failure) => emit(currentState.copyWith(
          isSearching: false,
          searchError: failure.message,
        )),
        (books) => emit(currentState.copyWith(
          isSearching: false,
          searchResults: books,
          clearSearchError: true,
        )),
      );
    }
  }

  Future<void> _onClearSearchResults(ClearSearchResults event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      emit(currentState.copyWith(searchResults: [], clearSearchError: true));
    }
  }

  Future<void> _onSelectBookFromSearch(SelectBookFromSearch event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      final book = event.book;
      
      // Create form from selected book
      final form = BookUploadForm(
        id: book.id,
        title: book.title,
        isbn: book.metadata.isbn ?? '',
        author: book.author,
        description: book.description,
        genres: book.genres,
        publishedYear: book.publishedYear,
        publisher: book.metadata.publisher,
        language: book.metadata.language,
        pageCount: book.metadata.pageCount,
        ageAppropriateness: book.metadata.ageAppropriateness.index,
        copies: currentState.form.copies,
        isSearchResult: true,
      );
      
      emit(currentState.copyWith(
        form: form,
        searchResults: [],
        clearSearchError: true,
      ));
    }
  }

  Future<void> _onGetBookByIsbn(GetBookByIsbn event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      emit(currentState.copyWith(isSearching: true, clearSearchError: true));
      
      final result = await getBookByIsbnUseCase(event.isbn);
      
      result.fold(
        (failure) => emit(currentState.copyWith(
          isSearching: false,
          searchError: failure.message,
        )),
        (book) {
          if (book != null) {
            // Book found, populate form
            final form = BookUploadForm(
              id: book.id,
              title: book.title,
              isbn: book.metadata.isbn ?? '',
              author: book.author,
              description: book.description,
              genres: book.genres,
              publishedYear: book.publishedYear,
              publisher: book.metadata.publisher,
              language: book.metadata.language,
              pageCount: book.metadata.pageCount,
              ageAppropriateness: book.metadata.ageAppropriateness.index,
              copies: currentState.form.copies,
              isSearchResult: true,
            );
            
            emit(currentState.copyWith(
              form: form,
              isSearching: false,
              clearSearchError: true,
            ));
          } else {
            // Book not found, just update ISBN
            final form = currentState.form.copyWith(isbn: event.isbn);
            emit(currentState.copyWith(
              form: form,
              isSearching: false,
              clearSearchError: true,
            ));
          }
        },
      );
    }
  }

  Future<void> _onAddNewCopy(AddNewCopy event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      final newCopy = BookCopy(
        imageUrls: const [],
        condition: BookCondition.good,
        isForSale: false,
        isForRent: false,
        isForDonate: false,
      );
      
      final updatedCopies = List<BookCopy>.from(currentState.form.copies)..add(newCopy);
      final updatedForm = currentState.form.copyWith(copies: updatedCopies);
      
      emit(currentState.copyWith(form: updatedForm));
    }
  }

  Future<void> _onUpdateCopy(UpdateCopy event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      final updatedCopies = List<BookCopy>.from(currentState.form.copies);
      if (event.copyIndex < updatedCopies.length) {
        updatedCopies[event.copyIndex] = event.copy;
        final updatedForm = currentState.form.copyWith(copies: updatedCopies);
        emit(currentState.copyWith(form: updatedForm));
      }
    }
  }

  Future<void> _onRemoveCopy(RemoveCopy event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      final updatedCopies = List<BookCopy>.from(currentState.form.copies);
      if (event.copyIndex < updatedCopies.length) {
        updatedCopies.removeAt(event.copyIndex);
        final updatedForm = currentState.form.copyWith(copies: updatedCopies);
        emit(currentState.copyWith(form: updatedForm));
      }
    }
  }

  Future<void> _onUploadImage(UploadImage event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      emit(currentState.copyWith(isUploadingImage: true, clearUploadError: true));
      
      final result = await uploadImageUseCase(event.filePath);
      
      result.fold(
        (failure) => emit(currentState.copyWith(
          isUploadingImage: false,
          uploadError: failure.message,
        )),
        (imageUrl) => emit(currentState.copyWith(
          isUploadingImage: false,
          clearUploadError: true,
          // Note: Image URL should be added to specific copy via UpdateCopy event
        )),
      );
    }
  }

  Future<void> _onLoadGenres(LoadGenres event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      final result = await getGenresUseCase();
      
      result.fold(
        (failure) => {}, // Ignore error, keep current genres
        (genres) => emit(currentState.copyWith(genres: genres)),
      );
    }
  }

  Future<void> _onLoadLanguages(LoadLanguages event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      final result = await getLanguagesUseCase();
      
      result.fold(
        (failure) => {}, // Ignore error, keep current languages
        (languages) => emit(currentState.copyWith(languages: languages)),
      );
    }
  }

  Future<void> _onSubmitForm(SubmitForm event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      emit(const BookUploadLoading());
      
      final result = await uploadBookUseCase(currentState.form);
      
      result.fold(
        (failure) => emit(BookUploadError(failure.message)),
        (book) => emit(BookUploadSuccess(
          uploadedBook: book,
          message: 'Book uploaded successfully!',
        )),
      );
    }
  }

  Future<void> _onResetForm(ResetForm event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      emit(currentState.copyWith(
        form: BookUploadForm.empty(),
        searchResults: [],
        clearSearchError: true,
        clearUploadError: true,
        clearSuccessMessage: true,
      ));
    }
  }

  Future<void> _onUploadImageForCopy(UploadImageForCopy event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      // For now, we'll just add the image URL directly since we're simulating image upload
      final updatedCopies = List<BookCopy>.from(currentState.form.copies);
      if (event.copyIndex < updatedCopies.length) {
        final updatedCopy = updatedCopies[event.copyIndex].copyWith(
          imageUrls: [...updatedCopies[event.copyIndex].imageUrls, event.imageUrl]
        );
        updatedCopies[event.copyIndex] = updatedCopy;
        
        final updatedForm = currentState.form.copyWith(copies: updatedCopies);
        emit(currentState.copyWith(form: updatedForm));
      }
    }
  }

  Future<void> _onRemoveImageFromCopy(RemoveImageFromCopy event, Emitter<BookUploadState> emit) async {
    if (state is BookUploadLoaded) {
      final currentState = state as BookUploadLoaded;
      
      final updatedCopies = List<BookCopy>.from(currentState.form.copies);
      if (event.copyIndex < updatedCopies.length) {
        final imageUrls = List<String>.from(updatedCopies[event.copyIndex].imageUrls);
        if (event.imageIndex < imageUrls.length) {
          imageUrls.removeAt(event.imageIndex);
          final updatedCopy = updatedCopies[event.copyIndex].copyWith(imageUrls: imageUrls);
          updatedCopies[event.copyIndex] = updatedCopy;
          
          final updatedForm = currentState.form.copyWith(copies: updatedCopies);
          emit(currentState.copyWith(form: updatedForm));
        }
      }
    }
  }
}
