import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';

/// Reusable book cover image component
class BookCoverImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const BookCoverImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ??
          DefaultBookPlaceholder(
            width: width,
            height: height,
          );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          BookImageLoadingPlaceholder(
            width: width,
            height: height,
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          DefaultBookPlaceholder(
            width: width,
            height: height,
          ),
    );
  }
}
