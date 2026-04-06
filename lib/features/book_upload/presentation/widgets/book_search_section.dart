import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_bloc.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_event.dart';
import 'package:flutter_library/features/book_upload/presentation/bloc/book_upload_state.dart';
import 'package:flutter_library/features/books/domain/entities/book.dart';
/// Widget for book search functionality
class BookSearchSection extends StatefulWidget {
  const BookSearchSection({super.key});

  @override
  State<BookSearchSection> createState() => _BookSearchSectionState();
}

class _BookSearchSectionState extends State<BookSearchSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                const Text(
                  'Search for Existing Book',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeLg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  'Search by title or ISBN to check if the book already exists',
                  style: TextStyle(
                    fontSize: AppTypography.fontSizeSm,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Search input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Enter book title or ISBN',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            context.read<BookUploadBloc>().add(SearchBooks(value));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallPadding),
                    ElevatedButton(
                      onPressed: state.isSearching
                          ? null
                          : () {
                              if (_searchController.text.isNotEmpty) {
                                context.read<BookUploadBloc>().add(
                                    SearchBooks(_searchController.text));
                              }
                            },
                      child: state.isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Search'),
                    ),
                  ],
                ),
                
                // Clear search button
                if (state.searchResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.smallPadding),
                    child: TextButton(
                      onPressed: () {
                        _searchController.clear();
                        context.read<BookUploadBloc>().add(const ClearSearchResults());
                      },
                      child: const Text('Clear Search'),
                    ),
                  ),
                
                // Search error
                if (state.searchError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppConstants.smallPadding),
                    child: Text(
                      state.searchError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                
                // Search results
                if (state.searchResults.isNotEmpty)
                  _buildSearchResults(context, state.searchResults),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, List<Book> searchResults) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppConstants.defaultPadding),
        const Text(
          'Search Results',
          style: TextStyle(
            fontSize: AppTypography.fontSizeMd,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height > 600
              ? AppDimensions.maxSearchResultsHeight
              : double.infinity,
        ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final book = searchResults[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  vertical: AppConstants.smallPadding / 2,
                ),
                child: ListTile(
                  leading: book.hasAnyImages
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                          child: Image.network(
                            book.primaryImageUrl,
                            width: 40,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: AppDimensions.iconXl + AppDimensions.spaceSm,
                                height: AppDimensions.icon3Xl + AppDimensions.spaceSm,
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                                child: const Icon(Icons.book),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: AppDimensions.iconXl + AppDimensions.spaceSm,
                          height: AppDimensions.icon3Xl + AppDimensions.spaceSm,
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          child: const Icon(Icons.book),
                        ),
                  title: Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.author,
                        style: const TextStyle(fontSize: AppTypography.fontSizeXs),
                      ),
                      if (book.metadata.isbn != null && book.metadata.isbn!.isNotEmpty)
                        Text(
                          'ISBN: ${book.metadata.isbn}',
                          style: TextStyle(fontSize: AppTypography.fontSizeXs, color: Theme.of(context).colorScheme.outline),
                        ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: AppDimensions.iconXs),
                  onTap: () {
                    context.read<BookUploadBloc>().add(
                        SelectBookFromSearch(book));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
