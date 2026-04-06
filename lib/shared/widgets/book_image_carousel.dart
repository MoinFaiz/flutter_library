import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/shared/widgets/book_cover_image.dart';
import 'package:flutter_library/shared/widgets/default_book_placeholder.dart';

/// Widget to display multiple book images in a carousel
class BookImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double? width;
  final double? height;
  final bool showIndicators;

  const BookImageCarousel({
    super.key,
    required this.imageUrls,
    this.width,
    this.height,
    this.showIndicators = true,
  });

  @override
  State<BookImageCarousel> createState() => _BookImageCarouselState();
}

class _BookImageCarouselState extends State<BookImageCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return DefaultBookPlaceholder(
        width: widget.width,
        height: widget.height,
      );
    }

    if (widget.imageUrls.length == 1) {
      return BookCoverImage(
        imageUrl: widget.imageUrls.first,
        width: widget.width,
        height: widget.height,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return BookCoverImage(
                imageUrl: widget.imageUrls[index],
                width: widget.width,
                height: widget.height,
              );
            },
          ),
          if (widget.showIndicators && widget.imageUrls.length > 1 && widget.imageUrls.length <= 10)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.imageUrls.asMap().entries.map((entry) {
                  return Container(
                    width: AppDimensions.dotSize,
                    height: AppDimensions.dotSize,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
