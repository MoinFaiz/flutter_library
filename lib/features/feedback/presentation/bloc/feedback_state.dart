import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/feedback/domain/entities/feedback.dart';

/// Base class for all feedback states
abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FeedbackInitial extends FeedbackState {
  const FeedbackInitial();
}

/// Loading state
class FeedbackLoading extends FeedbackState {
  const FeedbackLoading();
}

/// Success state after submitting feedback
class FeedbackSubmitted extends FeedbackState {
  final Feedback feedback;

  const FeedbackSubmitted({required this.feedback});

  @override
  List<Object?> get props => [feedback];
}

/// State when feedback history is loaded
class FeedbackHistoryLoaded extends FeedbackState {
  final List<Feedback> feedbackList;

  const FeedbackHistoryLoaded({required this.feedbackList});

  @override
  List<Object?> get props => [feedbackList];
}

/// Error state
class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError({required this.message});

  @override
  List<Object?> get props => [message];
}
