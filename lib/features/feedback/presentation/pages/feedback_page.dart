import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/core/theme/app_dimensions.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_bloc.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_state.dart';
import 'package:flutter_library/shared/widgets/app_button.dart';
import 'package:flutter_library/shared/widgets/app_text_field.dart';

/// Feedback page for users to submit feedback and suggestions
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  FeedbackType _selectedType = FeedbackType.general;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: BlocListener<FeedbackBloc, FeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Thank you for your feedback! We\'ll review it soon.'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            // Clear form
            _feedbackController.clear();
            setState(() {
              _selectedType = FeedbackType.general;
            });
          }
          if (state is FeedbackError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<FeedbackBloc, FeedbackState>(
      builder: (context, state) {
        final isLoading = state is FeedbackLoading;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMd),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'We\'d love to hear from you!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  'Your feedback helps us improve the app and provide better service.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),

                // Feedback Type
                Text(
                  'Feedback Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                _buildFeedbackTypeDropdown(),
                const SizedBox(height: AppDimensions.spaceMd),

                // Feedback Message
                Text(
                  'Your Feedback',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                AppTextField.multiline(
                  controller: _feedbackController,
                  maxLines: 6,
                  hintText: 'Please share your thoughts, suggestions, or report any issues...',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your feedback';
                    }
                    if (value.trim().length < 10) {
                      return 'Please provide more detailed feedback (at least 10 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceLg),

                // Submit Button
                AppButton.primary(
                  text: 'Submit Feedback',
                  onPressed: () => _submitFeedback(context),
                  isLoading: isLoading,
                  fullWidth: true,
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                // Contact Info
                _buildContactInfo(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackTypeDropdown() {
    return DropdownButtonFormField<FeedbackType>(
      initialValue: _selectedType,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.category_outlined),
        hintText: 'Select feedback type',
      ),
      items: FeedbackType.values.map((type) {
        return DropdownMenuItem<FeedbackType>(
          value: type,
          child: Text(
            type.displayName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedType = value!;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a feedback type';
        }
        return null;
      },
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Other ways to reach us:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          _buildContactRow(Icons.email, 'support@flutterlibrary.com'),
          const SizedBox(height: AppDimensions.spaceXs),
          _buildContactRow(Icons.phone, '+1 (555) 123-4567'),
          const SizedBox(height: AppDimensions.spaceXs),
          _buildContactRow(Icons.access_time, 'Mon-Fri: 9AM-6PM EST'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconXs,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ],
    );
  }

  void _submitFeedback(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<FeedbackBloc>().add(
      SubmitFeedback(
        type: _selectedType,
        message: _feedbackController.text.trim(),
      ),
    );
  }
}
