import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_colors.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart' as feedback_entities;
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_state.dart';

/// Widget showing feedback history
class FeedbackHistoryWidget extends StatelessWidget {
  const FeedbackHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Feedback History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            BlocBuilder<FeedbackBloc, FeedbackState>(
              builder: (context, state) {
                if (state is FeedbackLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is FeedbackHistoryLoaded) {
                  if (state.feedbackList.isEmpty) {
                    return const _EmptyHistoryWidget();
                  }
                  return _FeedbackListWidget(feedbackList: state.feedbackList);
                } else if (state is FeedbackError) {
                  return _ErrorWidget(message: state.message);
                } else {
                  return const _EmptyHistoryWidget();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryWidget extends StatelessWidget {
  const _EmptyHistoryWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'No feedback history yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Your submitted feedback will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackListWidget extends StatelessWidget {
  final List<feedback_entities.Feedback> feedbackList;

  const _FeedbackListWidget({required this.feedbackList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedbackList.length,
      itemBuilder: (context, index) {
        final feedback = feedbackList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: ListTile(
            leading: _getFeedbackIcon(context, feedback.type),
            title: Text(feedback.type.displayName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feedback.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppDimensions.spaceXs),
                Text(
                  _formatDate(feedback.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            trailing: _getStatusChip(context, feedback.status),
          ),
        );
      },
    );
  }

  Widget _getFeedbackIcon(BuildContext context, feedback_entities.FeedbackType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case feedback_entities.FeedbackType.general:
        iconData = Icons.comment;
        color = Theme.of(context).colorScheme.primary;
        break;
      case feedback_entities.FeedbackType.bugReport:
        iconData = Icons.bug_report;
        color = Theme.of(context).colorScheme.error;
        break;
      case feedback_entities.FeedbackType.featureRequest:
        iconData = Icons.lightbulb;
        color = AppColors.warning;
        break;
      case feedback_entities.FeedbackType.complaint:
        iconData = Icons.warning;
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Icon(iconData, color: color);
  }

  Widget _getStatusChip(BuildContext context, feedback_entities.FeedbackStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case feedback_entities.FeedbackStatus.pending:
        backgroundColor = AppColors.warning.withValues(alpha: 0.1);
        textColor = AppColors.warning;
        text = 'Pending';
        break;
      case feedback_entities.FeedbackStatus.inReview:
        backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.primary;
        text = 'In Review';
        break;
      case feedback_entities.FeedbackStatus.resolved:
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        text = 'Resolved';
        break;
      case feedback_entities.FeedbackStatus.closed:
        backgroundColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.1);
        textColor = Theme.of(context).colorScheme.outline;
        text = 'Closed';
        break;
    }

    return Chip(
      label: Text(text),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: textColor,
        fontSize: AppTypography.fontSizeXs,
        fontWeight: FontWeight.w500,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;

  const _ErrorWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Error loading feedback history',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
