import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/utils/helpers/responsive_utils.dart';

/// Dialog for reporting inappropriate reviews
class ReportReviewDialog extends StatefulWidget {
  final Function(String reason) onReport;

  const ReportReviewDialog({
    super.key,
    required this.onReport,
  });

  @override
  State<ReportReviewDialog> createState() => _ReportReviewDialogState();
}

class _ReportReviewDialogState extends State<ReportReviewDialog> {
  final _reasonController = TextEditingController();
  String? _selectedReason;
  final _formKey = GlobalKey<FormState>();

  static const List<String> _reportReasons = [
    'Spam or misleading',
    'Offensive language',
    'Harassment or hate speech',
    'Off-topic content',
    'Duplicate review',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      title: Row(
        children: [
          Icon(
            Icons.flag,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
          const Expanded(
            child: Text('Report Review'),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help us understand what\'s wrong with this review',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 16)),
              
              // Reason dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedReason,
                decoration: InputDecoration(
                  labelText: 'Reason for reporting',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.smallPadding),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: _reportReasons.map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a reason';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 16)),
              
              // Additional details
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: 'Additional details (optional)',
                  hintText: 'Provide more context...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.smallPadding),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
              
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppConstants.smallPadding),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
                    Expanded(
                      child: Text(
                        'Reports are confidential and will be reviewed by our moderation team.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Submit Report'),
        ),
      ],
    );
  }

  void _handleReport() {
    if (_formKey.currentState?.validate() ?? false) {
      final reason = _selectedReason!;
      final details = _reasonController.text.trim();
      final fullReason = details.isNotEmpty ? '$reason: $details' : reason;
      
      widget.onReport(fullReason);
      Navigator.of(context).pop();
    }
  }
}
