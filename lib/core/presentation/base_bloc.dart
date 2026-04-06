import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:equatable/equatable.dart';

/// Base state class for common BLoC patterns
abstract class BaseState extends Equatable {
  const BaseState();
}

/// Base loading state
class BaseLoading extends BaseState {
  @override
  List<Object> get props => [];
}

/// Base error state
class BaseError extends BaseState {
  final String message;
  
  const BaseError(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Mixin for common BLoC result handling patterns
mixin BlocResultHandler<State extends BaseState> on BlocBase<State> {
  /// Handles Either results with common error mapping
  void handleResult<T>(
    Either<Failure, T> result,
    void Function(T data) onSuccess,
    void Function(String error) onError,
  ) {
    result.fold(
      (failure) => onError(failure.message),
      (data) => onSuccess(data),
    );
  }

  /// Emits appropriate state based on Either result
  void emitResult<T>(
    Either<Failure, T> result,
    Emitter<State> emit,
    State Function(T data) createSuccessState,
    State Function(String error) createErrorState,
  ) {
    result.fold(
      (failure) => emit(createErrorState(failure.message)),
      (data) => emit(createSuccessState(data)),
    );
  }

  /// Generic method to execute async operations with loading state
  Future<void> executeWithLoading<T>(
    Future<Either<Failure, T>> Function() operation,
    Emitter<State> emit,
    State loadingState,
    State Function(T data) createSuccessState,
    State Function(String error) createErrorState,
  ) async {
    emit(loadingState);
    final result = await operation();
    emitResult(result, emit, createSuccessState, createErrorState);
  }
}

/// Base class for data-holding states
abstract class BaseDataState<T extends Object> extends BaseState {
  final T data;
  
  const BaseDataState(this.data);
  
  @override
  List<Object> get props => [data];
  
  /// Create a copy with new data
  BaseDataState<T> copyWith(T newData);
}
