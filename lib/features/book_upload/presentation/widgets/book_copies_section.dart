import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/book_upload/domain/entities/entities.dart';
import 'package:flutter_library/features/book_upload/presentation/widgets/dialogs/dialogs.dart';

/// Widget for managing book copies
class BookCopiesSection extends StatelessWidget {
  const BookCopiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookUploadBloc, BookUploadState>(
      builder: (context, state) {
        if (state is! BookUploadLoaded) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Book Copies',
                      style: TextStyle(
                        fontSize: AppTypography.fontSizeLg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<BookUploadBloc>().add(const AddNewCopy());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Copy'),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Add at least one copy of this book with images and details',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeSm,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // List of copies
                if (state.form.copies.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildCopiesList(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_books,
            size: AppDimensions.icon3Xl,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'No copies added yet',
            style: TextStyle(
              fontSize: AppTypography.fontSizeMd,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Add at least one copy to continue',
            style: TextStyle(
              fontSize: AppTypography.fontSizeSm,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopiesList(BuildContext context, BookUploadLoaded state) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.form.copies.length,
      itemBuilder: (context, index) {
        final copy = state.form.copies[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Copy ${index + 1}',
                      style: const TextStyle(
                        fontSize: AppTypography.fontSizeMd,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showRemoveCopyDialog(context, index);
                      },
                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Remove Copy',
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.defaultPadding),

                // Images section
                _buildImagesSection(context, copy, index),

                const SizedBox(height: AppConstants.defaultPadding),

                // Condition dropdown
                _buildConditionDropdown(context, copy, index),

                const SizedBox(height: AppConstants.defaultPadding),

                // Availability toggles
                _buildAvailabilityToggles(context, copy, index),

                const SizedBox(height: AppConstants.defaultPadding),

                // Price fields
                _buildPriceFields(context, copy, index),

                const SizedBox(height: AppConstants.defaultPadding),

                // Notes field
                _buildNotesField(context, copy, index),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagesSection(BuildContext context, BookCopy copy, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Images',
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: copy.imageUrls.length + 1,
            itemBuilder: (context, imageIndex) {
              if (imageIndex == copy.imageUrls.length) {
                // Add image button
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: AppConstants.smallPadding),
                  child: InkWell(
                    onTap: () {
                      _showImagePickerDialog(context, index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: AppDimensions.iconMd),
                          SizedBox(height: AppDimensions.spaceXs),
                          Text('Add', style: TextStyle(fontSize: AppTypography.fontSizeXs)),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                // Existing image
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: AppConstants.smallPadding),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          child: Image.network(
                            copy.imageUrls[imageIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image);
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            _removeImage(context, index, imageIndex);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: AppDimensions.iconXs,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConditionDropdown(BuildContext context, BookCopy copy, int index) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Condition',
                style: TextStyle(
                  fontSize: AppTypography.fontSizeSm,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              DropdownButtonFormField<BookCondition>(
                initialValue: copy.condition,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                ),
                items: BookCondition.values.map((condition) {
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(condition.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final updatedCopy = copy.copyWith(condition: value);
                    context.read<BookUploadBloc>().add(
                        UpdateCopy(copyIndex: index, copy: updatedCopy));
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggles(BuildContext context, BookCopy copy, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('For Sale'),
                value: copy.isForSale,
                onChanged: (value) {
                  final updatedCopy = copy.copyWith(isForSale: value ?? false);
                  context.read<BookUploadBloc>().add(
                      UpdateCopy(copyIndex: index, copy: updatedCopy));
                },
                dense: true,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('For Rent'),
                value: copy.isForRent,
                onChanged: (value) {
                  final updatedCopy = copy.copyWith(isForRent: value ?? false);
                  context.read<BookUploadBloc>().add(
                      UpdateCopy(copyIndex: index, copy: updatedCopy));
                },
                dense: true,
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('For Donation'),
          value: copy.isForDonate,
          onChanged: (value) {
            final updatedCopy = copy.copyWith(isForDonate: value ?? false);
            context.read<BookUploadBloc>().add(
                UpdateCopy(copyIndex: index, copy: updatedCopy));
          },
          dense: true,
        ),
      ],
    );
  }

  Widget _buildPriceFields(BuildContext context, BookCopy copy, int index) {
    return Row(
      children: [
        if (copy.isForSale)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sale Price',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    prefixText: '\$',
                  ),
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    final updatedCopy = copy.copyWith(expectedPrice: price);
                    context.read<BookUploadBloc>().add(
                        UpdateCopy(copyIndex: index, copy: updatedCopy));
                  },
                ),
              ],
            ),
          ),
        if (copy.isForSale && copy.isForRent)
          const SizedBox(width: AppConstants.defaultPadding),
        if (copy.isForRent)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rent Price',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    prefixText: '\$',
                  ),
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    final updatedCopy = copy.copyWith(expectedPrice: price);
                    context.read<BookUploadBloc>().add(
                        UpdateCopy(copyIndex: index, copy: updatedCopy));
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotesField(BuildContext context, BookCopy copy, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            hintText: 'Add any additional notes about this copy',
          ),
          onChanged: (value) {
            final updatedCopy = copy.copyWith(notes: value);
            context.read<BookUploadBloc>().add(
                UpdateCopy(copyIndex: index, copy: updatedCopy));
          },
        ),
      ],
    );
  }

  void _showImagePickerDialog(BuildContext context, int copyIndex) {
    showDialog(
      context: context,
      builder: (context) => ImagePickerDialog(
        onSourceSelected: (source) => _pickImage(context, copyIndex, source),
      ),
    );
  }

  void _showRemoveCopyDialog(BuildContext context, int copyIndex) {
    showDialog(
      context: context,
      builder: (context) => RemoveCopyDialog(
        copyIndex: copyIndex,
        onRemove: (reason) => _handleCopyRemoval(context, copyIndex, reason),
      ),
    );
  }

  void _handleCopyRemoval(BuildContext context, int copyIndex, String reason) {
    // Remove the copy from the bloc
    context.read<BookUploadBloc>().add(RemoveCopy(copyIndex));
    
    // Show feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copy removed. Reason: $reason'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    
    // TODO: Log the removal reason for analytics/audit trail
    // _analyticsService.logCopyRemoval(copyIndex, reason);
  }

  void _pickImage(BuildContext context, int copyIndex, ImageSource source) {
    // For now, we'll simulate adding an image URL
    // In a real app, you would use image_picker package
    final imageUrl = 'https://via.placeholder.com/150x200?text=Book+Copy+${copyIndex + 1}';
    
    context.read<BookUploadBloc>().add(
        UploadImageForCopy(copyIndex: copyIndex, imageUrl: imageUrl));
  }

  void _removeImage(BuildContext context, int copyIndex, int imageIndex) {
    context.read<BookUploadBloc>().add(
        RemoveImageFromCopy(copyIndex: copyIndex, imageIndex: imageIndex));
  }
}
