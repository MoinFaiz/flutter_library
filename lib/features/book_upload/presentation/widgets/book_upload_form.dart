import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_search_section.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_form_section.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/book_copies_section.dart';

/// Main widget for book upload form
class BookUploadForm extends StatelessWidget {
  const BookUploadForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookUploadBloc, BookUploadState>(
      listener: (context, state) {
        if (state is BookUploadLoaded) {
          // Show success message
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.success,
              ),
            );
          }
          
          // Show error message
          if (state.uploadError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.uploadError!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
      child: BlocBuilder<BookUploadBloc, BookUploadState>(
        builder: (context, state) {
          if (state is BookUploadInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is BookUploadLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is BookUploadLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search section
                  const BookSearchSection(),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Form section
                  const BookFormSection(),
                  
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Copies section
                  const BookCopiesSection(),
                  
                  const SizedBox(height: AppConstants.largePadding),
                  
                  // Submit button
                  _buildSubmitButton(context, state),
                ],
              ),
            );
          }
          
          if (state is BookUploadError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: AppTypography.fontSizeMd),
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookUploadBloc>().add(const InitializeForm());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, BookUploadLoaded state) {
    final canSubmit = state.form.title.isNotEmpty &&
        state.form.isbn.isNotEmpty &&
        state.form.author.isNotEmpty &&
        state.form.copies.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit
            ? () {
                context.read<BookUploadBloc>().add(const SubmitForm());
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
        child: const Text(
          'Upload Book',
          style: TextStyle(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
