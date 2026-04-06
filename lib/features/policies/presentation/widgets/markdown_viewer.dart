import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';

/// Widget for displaying markdown content with responsive styling
class MarkdownViewer extends StatelessWidget {
  final String content;
  final String? title;
  final DateTime? lastUpdated;

  const MarkdownViewer({
    super.key,
    required this.content,
    this.title,
    this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
          ],
          
          if (lastUpdated != null) ...[
            Text(
              'Last updated: ${_formatDate(lastUpdated!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
          ],
          
          MarkdownBody(
            data: content,
            styleSheet: _getMarkdownStyleSheet(context),
            selectable: true,
          ),
          
          const SizedBox(height: AppConstants.largePadding),
        ],
      ),
    );
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils.getResponsiveSpacing(context);
    
    return MarkdownStyleSheet(
      h1: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
      h2: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      h3: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
      ),
      h4: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h5: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      h6: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      p: theme.textTheme.bodyMedium?.copyWith(
        height: 1.6,
      ),
      listBullet: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
      codeblockDecoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      blockquotePadding: EdgeInsets.all(responsive),
      listIndent: responsive,
      h1Padding: EdgeInsets.only(bottom: responsive * 0.5),
      h2Padding: EdgeInsets.only(bottom: responsive * 0.5, top: responsive),
      h3Padding: EdgeInsets.only(bottom: responsive * 0.25, top: responsive * 0.5),
      h4Padding: EdgeInsets.only(bottom: responsive * 0.25, top: responsive * 0.5),
      h5Padding: EdgeInsets.only(bottom: responsive * 0.25, top: responsive * 0.5),
      h6Padding: EdgeInsets.only(bottom: responsive * 0.25, top: responsive * 0.5),
      pPadding: EdgeInsets.only(bottom: responsive * 0.5),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
