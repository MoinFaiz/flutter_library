import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';

/// Widget for book form fields
class BookFormSection extends StatefulWidget {
  const BookFormSection({super.key});

  @override
  State<BookFormSection> createState() => _BookFormSectionState();
}

class _BookFormSectionState extends State<BookFormSection> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final fields = [
      'title',
      'isbn',
      'author',
      'description',
      'publisher',
      'publishedYear',
      'pageCount',
      'ageAppropriateness',
    ];

    for (final field in fields) {
      _controllers[field] = TextEditingController();
      _focusNodes[field] = FocusNode();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookUploadBloc, BookUploadState>(
      listener: (context, state) {
        if (state is BookUploadLoaded) {
          _updateControllers(state);
        }
      },
      child: BlocBuilder<BookUploadBloc, BookUploadState>(
        builder: (context, state) {
          if (state is! BookUploadLoaded) {
            return const SizedBox.shrink();
          }

          final isLocked = state.form.isSearchResult;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Book Information',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeLg,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isLocked)
                        const Padding(
                          padding: EdgeInsets.only(left: AppDimensions.spaceSm),
                          child: Icon(
                            Icons.lock,
                            size: 16,
                            color: AppColors.warning,
                          ),
                        ),
                    ],
                  ),
                  if (isLocked)
                    const Padding(
                      padding: EdgeInsets.only(top: AppDimensions.spaceXs),
                      child: Text(
                        'Fields are locked because this book was found in search results',
                        style: TextStyle(
                          fontSize: AppTypography.fontSizeXs,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppConstants.defaultPadding),

                  // Title (required)
                  _buildTextField(
                    label: 'Title *',
                    field: 'title',
                    value: state.form.title,
                    enabled: !isLocked,
                    maxLines: 2,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // ISBN (required)
                  _buildTextField(
                    label: 'ISBN *',
                    field: 'isbn',
                    value: state.form.isbn,
                    enabled: !isLocked,
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Author (required)
                  _buildTextField(
                    label: 'Author *',
                    field: 'author',
                    value: state.form.author,
                    enabled: !isLocked,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Description (required)
                  _buildTextField(
                    label: 'Description *',
                    field: 'description',
                    value: state.form.description,
                    enabled: !isLocked,
                    maxLines: 4,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Publisher (optional)
                  _buildTextField(
                    label: 'Publisher',
                    field: 'publisher',
                    value: state.form.publisher ?? '',
                    enabled: !isLocked,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Published Year and Page Count in a row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Published Year',
                          field: 'publishedYear',
                          value: state.form.publishedYear?.toString() ?? '',
                          enabled: !isLocked,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildTextField(
                          label: 'Page Count',
                          field: 'pageCount',
                          value: state.form.pageCount?.toString() ?? '',
                          enabled: !isLocked,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Age Appropriateness and Language in a row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Age Appropriateness',
                          field: 'ageAppropriateness',
                          value: state.form.ageAppropriateness?.toString() ?? '',
                          enabled: !isLocked,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: AppConstants.defaultPadding),
                      Expanded(
                        child: _buildLanguageDropdown(state),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  // Genres
                  _buildGenresSection(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String field,
    required String value,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextField(
          controller: _controllers[field],
          focusNode: _focusNodes[field],
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            fillColor: enabled ? null : Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            filled: !enabled,
          ),
          onChanged: (value) {
            // Check field type and use appropriate event
            switch (field) {
              case 'title':
              case 'isbn':
              case 'author':
              case 'description':
                context.read<BookUploadBloc>().add(
                    UpdateStringField(field: field, value: value));
                break;
              case 'publishedYear':
              case 'pageCount':
              case 'ageAppropriateness':
                final intValue = int.tryParse(value);
                context.read<BookUploadBloc>().add(
                    UpdateIntField(field: field, value: intValue));
                break;
              case 'publisher':
                context.read<BookUploadBloc>().add(
                    UpdateNullableStringField(field: field, value: value.isEmpty ? null : value));
                break;
            }
          },
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown(BookUploadLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language',
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        DropdownButtonFormField<String>(
          initialValue: state.form.language?.isNotEmpty == true ? state.form.language : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            fillColor: state.form.isSearchResult ? Theme.of(context).colorScheme.outline.withValues(alpha: 0.1) : null,
            filled: state.form.isSearchResult,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
          isExpanded: true, // This prevents overflow by expanding the dropdown to fill available width
          items: state.languages.map((language) {
            return DropdownMenuItem(
              value: language,
              child: Text(
                language,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: state.form.isSearchResult
              ? null
              : (value) {
                  context.read<BookUploadBloc>().add(
                      UpdateNullableStringField(field: 'language', value: value));
                },
          hint: const Text(
            'Select Language',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGenresSection(BookUploadLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genres',
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Column(
            children: [
              // Selected genres
              if (state.form.genres.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  child: Wrap(
                    spacing: AppConstants.smallPadding,
                    runSpacing: AppConstants.smallPadding,
                    children: state.form.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        deleteIcon: state.form.isSearchResult
                            ? null
                            : const Icon(Icons.close, size: 16),
                        onDeleted: state.form.isSearchResult
                            ? null
                            : () {
                                final updatedGenres = List<String>.from(state.form.genres);
                                updatedGenres.remove(genre);
                                context.read<BookUploadBloc>().add(
                                    UpdateStringListField(field: 'genres', value: updatedGenres));
                              },
                      );
                    }).toList(),
                  ),
                ),
              
              // Available genres
              if (!state.form.isSearchResult && state.genres.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallPadding),
                  child: Wrap(
                    spacing: AppConstants.smallPadding,
                    runSpacing: AppConstants.smallPadding,
                    children: state.genres
                        .where((genre) => !state.form.genres.contains(genre))
                        .map((genre) {
                      return ActionChip(
                        label: Text(genre),
                        onPressed: () {
                          final updatedGenres = List<String>.from(state.form.genres);
                          updatedGenres.add(genre);
                          context.read<BookUploadBloc>().add(
                              UpdateStringListField(field: 'genres', value: updatedGenres));
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _updateControllers(BookUploadLoaded state) {
    _controllers['title']?.text = state.form.title;
    _controllers['isbn']?.text = state.form.isbn;
    _controllers['author']?.text = state.form.author;
    _controllers['description']?.text = state.form.description;
    _controllers['publisher']?.text = state.form.publisher ?? '';
    _controllers['publishedYear']?.text = state.form.publishedYear?.toString() ?? '';
    _controllers['pageCount']?.text = state.form.pageCount?.toString() ?? '';
    _controllers['ageAppropriateness']?.text = state.form.ageAppropriateness?.toString() ?? '';
  }
}
