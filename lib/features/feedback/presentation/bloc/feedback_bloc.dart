import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/feedback/domain/usecases/get_feedback_history_usecase.dart';
import 'package:flutter_library/features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_event.dart';
import 'package:flutter_library/features/feedback/presentation/bloc/feedback_state.dart';

/// BLoC for managing feedback state
class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final SubmitFeedbackUseCase submitFeedbackUseCase;
  final GetFeedbackHistoryUseCase getFeedbackHistoryUseCase;

  FeedbackBloc({
    required this.submitFeedbackUseCase,
    required this.getFeedbackHistoryUseCase,
  }) : super(const FeedbackInitial()) {
    on<SubmitFeedback>(_onSubmitFeedback);
    on<GetFeedbackHistory>(_onGetFeedbackHistory);
    on<ResetFeedbackState>(_onResetFeedbackState);
  }

  Future<void> _onSubmitFeedback(
    SubmitFeedback event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(const FeedbackLoading());

    final result = await submitFeedbackUseCase(
      type: event.type,
      message: event.message,
    );

    result.fold(
      (failure) => emit(FeedbackError(message: failure.message)),
      (feedback) => emit(FeedbackSubmitted(feedback: feedback)),
    );
  }

  Future<void> _onGetFeedbackHistory(
    GetFeedbackHistory event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(const FeedbackLoading());

    final result = await getFeedbackHistoryUseCase();

    result.fold(
      (failure) => emit(FeedbackError(message: failure.message)),
      (feedbackList) => emit(FeedbackHistoryLoaded(feedbackList: feedbackList)),
    );
  }

  void _onResetFeedbackState(
    ResetFeedbackState event,
    Emitter<FeedbackState> emit,
  ) {
    emit(const FeedbackInitial());
  }
}
