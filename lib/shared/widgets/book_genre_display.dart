import 'package:flutter/material.dart';

/// Widget to display book genres as comma-separated chips
class BookGenreDisplay extends StatelessWidget {
  final List<String> genres;
  final int? maxGenres;
  final bool showAsChips;

  const BookGenreDisplay({
    super.key,
    required this.genres,
    this.maxGenres,
    this.showAsChips = false,
  });

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) {
      return Text(
        'No genre',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }

    final displayGenres = maxGenres != null 
        ? genres.take(maxGenres!).toList()
        : genres;

    if (showAsChips) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: displayGenres.map((genre) {
          return Chip(
            label: Text(
              genre,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      );
    }

    final genreText = displayGenres.join(', ');
    final hasMore = maxGenres != null && genres.length > maxGenres!;

    return Text(
      hasMore ? '$genreText...' : genreText,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.outline,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
