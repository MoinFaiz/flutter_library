import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

/// Base class for all feedback events
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit feedback
class SubmitFeedback extends FeedbackEvent {
  final FeedbackType type;
  final String message;

  const SubmitFeedback({
    required this.type,
    required this.message,
  });

  @override
  List<Object?> get props => [type, message];
}

/// Event to get feedback history
class GetFeedbackHistory extends FeedbackEvent {
  const GetFeedbackHistory();
}

/// Event to reset the feedback state
class ResetFeedbackState extends FeedbackEvent {
  const ResetFeedbackState();
}
