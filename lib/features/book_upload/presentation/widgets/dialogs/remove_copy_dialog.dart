import 'package:flutter/material.dart';
import 'package:flutter_library/core/constants/app_constants.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/core/theme/app_typography.dart';
import 'package:flutter_library/features/book_upload/domain/entities/entities.dart';

/// Dialog widget for confirming book copy removal with reason selection
class RemoveCopyDialog extends StatefulWidget {
  /// Index of the copy to be removed
  final int copyIndex;
  
  /// Callback function called when removal is confirmed
  final Function(String reason) onRemove;

  const RemoveCopyDialog({
    super.key,
    required this.copyIndex,
    required this.onRemove,
  });

  @override
  State<RemoveCopyDialog> createState() => _RemoveCopyDialogState();
}

class _RemoveCopyDialogState extends State<RemoveCopyDialog> {
  RemovalReason? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _isOtherSelected = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildDialogTitle(context),
      content: _buildDialogContent(context),
      actions: _buildDialogActions(context),
    );
  }

  Widget _buildDialogTitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 8),
        const Text('Remove Copy'),
      ],
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to remove Copy ${widget.copyIndex + 1}?',
            style: const TextStyle(fontSize: AppTypography.fontSizeMd),
          ),
          SizedBox(height: AppDimensions.spaceMd),
          _buildReasonSelection(),
          if (_isOtherSelected) ...[
            SizedBox(height: AppDimensions.spaceMd),
            _buildCustomReasonField(),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Please select a reason for removal:',
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppDimensions.spaceMd),
        DropdownButtonFormField<RemovalReason>(
          initialValue: _selectedReason,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: const Text('Select reason'),
          items: RemovalReason.values.map((reason) {
            return DropdownMenuItem(
              value: reason,
              child: Text(reason.displayName),
            );
          }).toList(),
          onChanged: _onReasonChanged,
        ),
      ],
    );
  }

  Widget _buildCustomReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Please specify the reason:',
          style: TextStyle(
            fontSize: AppTypography.fontSizeSm,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppDimensions.spaceSm),
        TextField(
          controller: _otherReasonController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            hintText: 'Enter your reason...',
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (_) => setState(() {}), // Trigger rebuild for validation
        ),
      ],
    );
  }

  List<Widget> _buildDialogActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _isRemoveButtonEnabled() ? _onRemovePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        child: const Text('Remove Copy'),
      ),
    ];
  }

  void _onReasonChanged(RemovalReason? value) {
    setState(() {
      _selectedReason = value;
      _isOtherSelected = value == RemovalReason.other;
      if (!_isOtherSelected) {
        _otherReasonController.clear();
      }
    });
  }

  bool _isRemoveButtonEnabled() {
    return _selectedReason != null &&
        (!_isOtherSelected || _otherReasonController.text.trim().isNotEmpty);
  }

  void _onRemovePressed() {
    final reason = _isOtherSelected
        ? _otherReasonController.text.trim()
        : _selectedReason!.displayName;

    Navigator.of(context).pop();
    widget.onRemove(reason);
  }
}
