import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';

/// Image carousel for book details page
class BookImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final String heroTag;

  const BookImageCarousel({
    super.key,
    required this.imageUrls,
    required this.heroTag,
  });

  @override
  State<BookImageCarousel> createState() => _BookImageCarouselState();
}

class _BookImageCarouselState extends State<BookImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        Hero(
          tag: widget.heroTag,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return _buildImageItem(widget.imageUrls[index]);
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          _buildPageIndicator(),
          _buildNavigationButtons(),
        ],
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: AppDimensions.icon3Xl,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).shadowColor.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Hero(
      tag: widget.heroTag,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerHighest,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book,
                size: AppDimensions.icon3Xl + AppDimensions.spaceLg,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              Text(
                'No Image Available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: AppDimensions.spaceSm + AppDimensions.spaceSm,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.imageUrls.length,
          (index) => Container(
            width: AppDimensions.spaceSm,
            height: AppDimensions.spaceSm,
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceXs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Positioned(
      left: AppDimensions.spaceMd,
      right: AppDimensions.spaceMd,
      top: 0,
      bottom: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentIndex > 0)
            _buildNavButton(
              icon: Icons.chevron_left,
              onTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          const Spacer(),
          if (_currentIndex < widget.imageUrls.length - 1)
            _buildNavButton(
              icon: Icons.chevron_right,
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceSm + AppDimensions.spaceXs),
        decoration: BoxDecoration(
          color: Theme.of(context).shadowColor.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface,
          size: AppDimensions.iconMd,
        ),
      ),
    );
  }
}
