import 'package:flutter/material.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';

/// Enhanced loading indicator with smooth animations and messaging
/// 
/// Provides a polished loading experience with:
/// - Smooth animated progress indicator
/// - Optional message display
/// - Customizable colors
/// - Proper spacing and alignment
class EnhancedLoadingIndicator extends StatefulWidget {
  /// Optional loading message to display below the spinner
  final String? message;

  /// Optional subtitle/description text
  final String? subtitle;

  /// Custom indicator color (defaults to theme primary)
  final Color? color;

  /// Whether to show a subtle background container
  final bool showBackground;

  /// Animation duration for the spinner
  final Duration animationDuration;

  /// Size of the progress indicator
  final double size;

  const EnhancedLoadingIndicator({
    super.key,
    this.message,
    this.subtitle,
    this.color,
    this.showBackground = false,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.size = 48.0,
  });

  @override
  State<EnhancedLoadingIndicator> createState() =>
      _EnhancedLoadingIndicatorState();
}

class _EnhancedLoadingIndicatorState extends State<EnhancedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indicatorColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated progress indicator with fade effect
        ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                strokeWidth: 3.5,
              ),
            ),
          ),
        ),

        // Message section with smooth fade-in
        if (widget.message != null) ...[
          const SizedBox(height: AppDimensions.spaceLg),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.message!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        // Subtitle section
        if (widget.subtitle != null) ...[
          const SizedBox(height: AppDimensions.spaceMd),
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    // Optionally wrap with background container
    if (widget.showBackground) {
      return Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: AppDimensions.elevationMd,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: content,
      );
    }

    return Center(child: content);
  }
}

/// Minimal loading indicator variant (compact version)
/// 
/// Used for inline loading states or within smaller containers
class CompactLoadingIndicator extends StatelessWidget {
  /// Custom indicator color
  final Color? color;

  /// Size of the indicator
  final double size;

  /// Stroke width of the circular indicator
  final double strokeWidth;

  const CompactLoadingIndicator({
    super.key,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
        strokeWidth: strokeWidth,
      ),
    );
  }
}

/// Skeleton loading indicator for placeholder animations
/// 
/// Shows a shimmer effect to indicate content is loading
class SkeletonLoadingIndicator extends StatefulWidget {
  /// Width of the skeleton
  final double width;

  /// Height of the skeleton
  final double height;

  /// Border radius for the skeleton shape
  final double borderRadius;

  /// Whether to show shimmer animation
  final bool showShimmer;

  const SkeletonLoadingIndicator({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.showShimmer = true,
  });

  @override
  State<SkeletonLoadingIndicator> createState() =>
      _SkeletonLoadingIndicatorState();
}

class _SkeletonLoadingIndicatorState extends State<SkeletonLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.showShimmer) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat();
    }
  }

  @override
  void dispose() {
    if (widget.showShimmer) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final highlightColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white;

    if (!widget.showShimmer) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Loading state wrapper for handling async operations
/// 
/// Usage:
/// ```dart
/// LoadingStateWrapper(
///   isLoading: _isLoading,
///   child: MyContent(),
///   loadingMessage: 'Loading data...',
/// )
/// ```
class LoadingStateWrapper extends StatelessWidget {
  /// Whether the content is currently loading
  final bool isLoading;

  /// The main content widget
  final Widget child;

  /// Loading message to display
  final String? loadingMessage;

  /// Loading subtitle
  final String? loadingSubtitle;

  /// Custom loading indicator widget
  final Widget? loadingWidget;

  /// Whether to blur the background content while loading
  final bool blurBackground;

  const LoadingStateWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.loadingSubtitle,
    this.loadingWidget,
    this.blurBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content (blurred if loading and blurBackground is true)
        if (blurBackground && isLoading)
          Opacity(
            opacity: 0.5,
            child: child,
          )
        else
          child,

        // Loading overlay
        if (isLoading)
          Container(
            color: Colors.black.withValues(
              alpha: blurBackground ? 0.3 : 0.0,
            ),
            child: loadingWidget ??
                EnhancedLoadingIndicator(
                  message: loadingMessage,
                  subtitle: loadingSubtitle,
                ),
          ),
      ],
    );
  }
}
