import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_book_by_isbn_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_book_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_copy_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/upload_image_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/usecases/get_metadata_usecase.dart';
import 'package:flutter_library/features/book_upload/domain/repositories/book_upload_repository.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_upload_form.dart';
import 'package:flutter_library/features/book_upload/domain/entities/book_copy.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_metadata.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_pricing.dart';
import 'package:flutter_library/features/books/domain/value_objects/book_availability.dart';
import 'package:flutter_library/features/books/domain/value_objects/age_appropriateness.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockBookUploadRepository extends Mock implements BookUploadRepository {}

void main() {
  group('Book Upload Use Cases Tests', () {
    late MockBookUploadRepository mockRepository;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(BookUploadForm.empty());
      registerFallbackValue(BookCopy(
        condition: BookCondition.good,
        isForRent: false,
        isForSale: false,
        isForDonate: false,
        imageUrls: [],
      ));
    });

    setUp(() {
      mockRepository = MockBookUploadRepository();
    });

    final testDateTime = DateTime(2023, 6, 1);
    final mockBook = Book(
      id: 'book_123',
      title: 'Test Book',
      author: 'Test Author',
      description: 'Test Description',
      imageUrls: const ['test.jpg'],
      rating: 4.5,
      pricing: const BookPricing(
        salePrice: 24.99,
        rentPrice: 5.99,
      ),
      availability: const BookAvailability(
        totalCopies: 3,
        availableForRentCount: 2,
        availableForSaleCount: 5,
      ),
      metadata: const BookMetadata(
        ageAppropriateness: AgeAppropriateness.adult,
        genres: ['Fiction'],
        pageCount: 300,
        language: 'English',
      ),
      isFavorite: false,
      isFromFriend: false,
      publishedYear: 2023,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    group('GetBookByIsbnUseCase', () {
      late GetBookByIsbnUseCase useCase;

      setUp(() {
        useCase = GetBookByIsbnUseCase(repository: mockRepository);
      });

      test('should return book when ISBN lookup is successful', () async {
        // Arrange
        when(() => mockRepository.getBookByIsbn('9781234567890'))
            .thenAnswer((_) async => Right(mockBook));

        // Act
        final result = await useCase('9781234567890');

        // Assert
        expect(result, Right(mockBook));
        verify(() => mockRepository.getBookByIsbn('9781234567890')).called(1);
      });

      test('should return null when ISBN is not found', () async {
        // Arrange
        when(() => mockRepository.getBookByIsbn('9781234567890'))
            .thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase('9781234567890');

        // Assert
        expect(result, const Right(null));
      });

      test('should return validation failure for invalid ISBN format', () async {
        // Arrange
        when(() => mockRepository.getBookByIsbn('invalid-isbn'))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid ISBN format')));

        // Act
        final result = await useCase('invalid-isbn');

        // Assert
        expect(result, const Left(ValidationFailure('Invalid ISBN format')));
      });

      test('should handle network failures gracefully', () async {
        // Arrange
        when(() => mockRepository.getBookByIsbn('9781234567890'))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final result = await useCase('9781234567890');

        // Assert
        expect(result, const Left(NetworkFailure()));
      });

      test('should return null for empty ISBN', () async {
        // Act
        final result = await useCase('');

        // Assert
        expect(result, const Right(null));
        verifyNever(() => mockRepository.getBookByIsbn(any()));
      });
    });

    group('UploadBookUseCase', () {
      late UploadBookUseCase useCase;

      setUp(() {
        useCase = UploadBookUseCase(repository: mockRepository);
      });

      test('should return success when book is uploaded successfully', () async {
        // Arrange
        final mockCopy = BookCopy(
          id: 'copy_1',
          bookId: 'book_123',
          condition: BookCondition.good,
          isForRent: true,
          isForSale: true,
          isForDonate: false,
          rentPrice: 5.99,
          expectedPrice: 24.99,
          imageUrls: ['test.jpg'],
          notes: 'Test copy',
          uploadDate: testDateTime,
          updatedAt: testDateTime,
        );

        final bookForm = BookUploadForm(
          title: 'Test Book',
          isbn: '9781234567890',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          copies: [mockCopy],
          publishedYear: 2023,
          language: 'English',
          pageCount: 300,
        );

        when(() => mockRepository.uploadBook(bookForm))
            .thenAnswer((_) async => Right(mockBook));

        // Act
        final result = await useCase(bookForm);

        // Assert
        expect(result, Right(mockBook));
        verify(() => mockRepository.uploadBook(bookForm)).called(1);
      });

      test('should return validation failure for incomplete form', () async {
        // Arrange
        final incompleteForm = BookUploadForm(
          title: '',  // Empty title makes it invalid
          isbn: '',
          author: '',
          description: '',
          genres: const [],
          copies: const [],
        );

        // Act
        final result = await useCase(incompleteForm);

        // Assert
        expect(result, const Left(ValidationFailure('Please fill in all required fields')));
        verifyNever(() => mockRepository.uploadBook(any()));
      });

      test('should return validation failure when no copies provided', () async {
        // Arrange - create a form that's valid except for missing copies
        final formWithoutCopies = BookUploadForm(
          title: 'Test Book',
          isbn: '9781234567890',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          copies: const [], // No copies
          publishedYear: 2023,
        );

        // Act
        final result = await useCase(formWithoutCopies);

        // Assert - Since the form.isValid check comes first and requires copies,
        // it will return the general validation message
        expect(result, const Left(ValidationFailure('Please fill in all required fields')));
        verifyNever(() => mockRepository.uploadBook(any()));
      });

      test('should handle server errors during upload', () async {
        // Arrange
        final mockCopy = BookCopy(
          id: 'copy_1',
          bookId: 'book_123',
          condition: BookCondition.good,
          isForRent: true,
          isForSale: true,
          isForDonate: false,
          rentPrice: 5.99,
          expectedPrice: 24.99,
          imageUrls: ['test.jpg'],
          notes: 'Test copy',
          uploadDate: testDateTime,
          updatedAt: testDateTime,
        );

        final bookForm = BookUploadForm(
          title: 'Test Book',
          isbn: '9781234567890',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          copies: [mockCopy],
          publishedYear: 2023,
        );

        when(() => mockRepository.uploadBook(bookForm))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase(bookForm);

        // Assert
        expect(result, const Left(ServerFailure()));
      });

      test('should handle permission errors', () async {
        // Arrange
        final mockCopy = BookCopy(
          id: 'copy_1',
          bookId: 'book_123',
          condition: BookCondition.good,
          isForRent: true,
          isForSale: true,
          isForDonate: false,
          rentPrice: 5.99,
          expectedPrice: 24.99,
          imageUrls: ['test.jpg'],
          notes: 'Test copy',
          uploadDate: testDateTime,
          updatedAt: testDateTime,
        );

        final bookForm = BookUploadForm(
          title: 'Test Book',
          isbn: '9781234567890',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          copies: [mockCopy],
          publishedYear: 2023,
        );

        when(() => mockRepository.uploadBook(bookForm))
            .thenAnswer((_) async => const Left(PermissionFailure()));

        // Act
        final result = await useCase(bookForm);

        // Assert
        expect(result, const Left(PermissionFailure()));
      });
    });

    group('UploadCopyUseCase', () {
      late UploadCopyUseCase useCase;

      setUp(() {
        useCase = UploadCopyUseCase(repository: mockRepository);
      });

      test('should return success when copy is uploaded successfully', () async {
        // Arrange
        final mockCopy = BookCopy(
          id: 'copy_1',
          bookId: 'book_123',
          condition: BookCondition.good,
          isForRent: true,
          isForSale: false,
          isForDonate: false,
          rentPrice: 5.99,
          imageUrls: ['test.jpg'],
          notes: 'Test copy',
          uploadDate: testDateTime,
          updatedAt: testDateTime,
        );

        when(() => mockRepository.uploadCopy(mockCopy))
            .thenAnswer((_) async => Right(mockCopy));

        // Act
        final result = await useCase(mockCopy);

        // Assert
        expect(result, Right(mockCopy));
        verify(() => mockRepository.uploadCopy(mockCopy)).called(1);
      });

      test('should return validation failure for invalid copy', () async {
        // Arrange
        final invalidCopy = BookCopy(
          condition: BookCondition.good,
          isForRent: false,
          isForSale: false,
          isForDonate: false,
          imageUrls: [],
        );

        // Act
        final result = await useCase(invalidCopy);

        // Assert
        expect(result, const Left(ValidationFailure('Please complete all copy details')));
        verifyNever(() => mockRepository.uploadCopy(any()));
      });

      test('should return validation failure when no images provided', () async {
        // Arrange
        final copyWithoutImages = BookCopy(
          condition: BookCondition.good,
          isForRent: true,
          isForSale: false,
          isForDonate: false,
          imageUrls: [],
        );

        // Act
        final result = await useCase(copyWithoutImages);

        // Assert - isValid checks images first, so it returns general validation message
        expect(result, const Left(ValidationFailure('Please complete all copy details')));
        verifyNever(() => mockRepository.uploadCopy(any()));
      });

      test('should return validation failure when copy is not available', () async {
        // Arrange
        final unavailableCopy = BookCopy(
          condition: BookCondition.good,
          isForRent: false,
          isForSale: false,
          isForDonate: false,
          imageUrls: ['test.jpg'],
        );

        // Act
        final result = await useCase(unavailableCopy);

        // Assert - isValid checks availability, so it returns general validation message
        expect(result, const Left(ValidationFailure('Please complete all copy details')));
        verifyNever(() => mockRepository.uploadCopy(any()));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        final mockCopy = BookCopy(
          condition: BookCondition.good,
          isForRent: true,
          isForSale: false,
          isForDonate: false,
          imageUrls: ['test.jpg'],
        );

        when(() => mockRepository.uploadCopy(mockCopy))
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase(mockCopy);

        // Assert
        expect(result, const Left(ServerFailure()));
      });
    });

    group('UploadImageUseCase', () {
      late UploadImageUseCase useCase;

      setUp(() {
        useCase = UploadImageUseCase(repository: mockRepository);
      });

      test('should return image URL when upload is successful', () async {
        // Arrange
        when(() => mockRepository.uploadImage('path/to/image.jpg'))
            .thenAnswer((_) async => const Right('https://example.com/image.jpg'));

        // Act
        final result = await useCase('path/to/image.jpg');

        // Assert
        expect(result, const Right('https://example.com/image.jpg'));
        verify(() => mockRepository.uploadImage('path/to/image.jpg')).called(1);
      });

      test('should return validation failure for invalid file path', () async {
        // Act
        final result = await useCase('');

        // Assert
        expect(result, const Left(ValidationFailure('Please select an image')));
        verifyNever(() => mockRepository.uploadImage(any()));
      });

      test('should return validation failure for unsupported file type', () async {
        // Arrange
        when(() => mockRepository.uploadImage('path/to/file.txt'))
            .thenAnswer((_) async => const Left(ValidationFailure('Unsupported file type')));

        // Act
        final result = await useCase('path/to/file.txt');

        // Assert
        expect(result, const Left(ValidationFailure('Unsupported file type')));
      });

      test('should handle file size limit errors', () async {
        // Arrange
        when(() => mockRepository.uploadImage('path/to/large-image.jpg'))
            .thenAnswer((_) async => const Left(ValidationFailure('File size too large')));

        // Act
        final result = await useCase('path/to/large-image.jpg');

        // Assert
        expect(result, const Left(ValidationFailure('File size too large')));
      });

      test('should handle network failures during upload', () async {
        // Arrange
        when(() => mockRepository.uploadImage('path/to/image.jpg'))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        // Act
        final result = await useCase('path/to/image.jpg');

        // Assert
        expect(result, const Left(NetworkFailure()));
      });
    });

    group('GetGenresUseCase', () {
      late GetGenresUseCase useCase;

      setUp(() {
        useCase = GetGenresUseCase(repository: mockRepository);
      });

      test('should return list of genres when repository call is successful', () async {
        // Arrange
        final genres = ['Fiction', 'Non-Fiction', 'Mystery', 'Romance', 'Sci-Fi'];
        when(() => mockRepository.getGenres())
            .thenAnswer((_) async => Right(genres));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(genres));
        verify(() => mockRepository.getGenres()).called(1);
      });

      test('should return empty list when no genres are available', () async {
        // Arrange
        when(() => mockRepository.getGenres())
            .thenAnswer((_) async => const Right(<String>[]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Right(<String>[]));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        when(() => mockRepository.getGenres())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(ServerFailure()));
      });

      test('should handle cache failures gracefully', () async {
        // Arrange
        when(() => mockRepository.getGenres())
            .thenAnswer((_) async => const Left(CacheFailure('Cache error')));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(CacheFailure('Cache error')));
      });
    });

    group('GetLanguagesUseCase', () {
      late GetLanguagesUseCase useCase;

      setUp(() {
        useCase = GetLanguagesUseCase(repository: mockRepository);
      });

      test('should return list of languages when repository call is successful', () async {
        // Arrange
        final languages = ['English', 'Spanish', 'French', 'German', 'Italian'];
        when(() => mockRepository.getLanguages())
            .thenAnswer((_) async => Right(languages));

        // Act
        final result = await useCase();

        // Assert
        expect(result, Right(languages));
        verify(() => mockRepository.getLanguages()).called(1);
      });

      test('should return empty list when no languages are available', () async {
        // Arrange
        when(() => mockRepository.getLanguages())
            .thenAnswer((_) async => const Right(<String>[]));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Right(<String>[]));
      });

      test('should handle server errors gracefully', () async {
        // Arrange
        when(() => mockRepository.getLanguages())
            .thenAnswer((_) async => const Left(ServerFailure()));

        // Act
        final result = await useCase();

        // Assert
        expect(result, const Left(ServerFailure()));
      });
    });

    group('Integration Tests', () {
      test('should handle complete book upload workflow', () async {
        // Arrange
        final getGenresUseCase = GetGenresUseCase(repository: mockRepository);
        final getLanguagesUseCase = GetLanguagesUseCase(repository: mockRepository);
        final uploadImageUseCase = UploadImageUseCase(repository: mockRepository);
        final uploadBookUseCase = UploadBookUseCase(repository: mockRepository);
        final uploadCopyUseCase = UploadCopyUseCase(repository: mockRepository);

        when(() => mockRepository.getGenres())
            .thenAnswer((_) async => const Right(['Fiction', 'Mystery']));
        when(() => mockRepository.getLanguages())
            .thenAnswer((_) async => const Right(['English', 'Spanish']));
        when(() => mockRepository.uploadImage('path/to/image.jpg'))
            .thenAnswer((_) async => const Right('https://example.com/image.jpg'));

        final mockCopy = BookCopy(
          condition: BookCondition.good,
          isForRent: true,
          isForSale: false,
          isForDonate: false,
          imageUrls: ['https://example.com/image.jpg'],
        );

        final bookForm = BookUploadForm(
          title: 'Test Book',
          isbn: '9781234567890',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          copies: [mockCopy],
          publishedYear: 2023,
        );

        when(() => mockRepository.uploadBook(bookForm))
            .thenAnswer((_) async => Right(mockBook));
        when(() => mockRepository.uploadCopy(mockCopy))
            .thenAnswer((_) async => Right(mockCopy));

        // Act & Assert
        final genresResult = await getGenresUseCase();
        expect(genresResult.fold((_) => [], (genres) => genres.length), 2);

        final languagesResult = await getLanguagesUseCase();
        expect(languagesResult.fold((_) => [], (languages) => languages.length), 2);

        final imageResult = await uploadImageUseCase('path/to/image.jpg');
        expect(imageResult, const Right('https://example.com/image.jpg'));

        final bookResult = await uploadBookUseCase(bookForm);
        expect(bookResult, Right(mockBook));

        final copyResult = await uploadCopyUseCase(mockCopy);
        expect(copyResult, Right(mockCopy));
      });

      test('should handle failures at different stages of upload workflow', () async {
        // Arrange
        final uploadImageUseCase = UploadImageUseCase(repository: mockRepository);
        final uploadBookUseCase = UploadBookUseCase(repository: mockRepository);

        when(() => mockRepository.uploadImage('path/to/image.jpg'))
            .thenAnswer((_) async => const Left(NetworkFailure()));

        final bookForm = BookUploadForm(
          title: 'Test Book',
          isbn: '9781234567890',
          author: 'Test Author',
          description: 'Test Description',
          genres: ['Fiction'],
          copies: [],
          publishedYear: 2023,
        );

        // Act & Assert
        final imageResult = await uploadImageUseCase('path/to/image.jpg');
        expect(imageResult, const Left(NetworkFailure()));

        final bookResult = await uploadBookUseCase(bookForm);
        expect(bookResult, const Left(ValidationFailure('Please fill in all required fields')));
      });
    });
  });
}
