import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_policy_usecase.dart';
import 'policy_event.dart';
import 'policy_state.dart';

/// Policy BLoC
class PolicyBloc extends Bloc<PolicyEvent, PolicyState> {
  final GetPolicyUseCase _getPolicyUseCase;

  PolicyBloc(this._getPolicyUseCase) : super(PolicyInitial()) {
    on<LoadPolicy>(_onLoadPolicy);
    on<RefreshPolicy>(_onRefreshPolicy);
  }

  Future<void> _onLoadPolicy(LoadPolicy event, Emitter<PolicyState> emit) async {
    emit(PolicyLoading());
    final result = await _getPolicyUseCase.execute(event.policyId);
    result.fold(
      (failure) => emit(PolicyError(failure.message)),
      (policy) => emit(PolicyLoaded(policy)),
    );
  }

  Future<void> _onRefreshPolicy(RefreshPolicy event, Emitter<PolicyState> emit) async {
    final result = await _getPolicyUseCase.execute(event.policyId);
    result.fold(
      (failure) => emit(PolicyError(failure.message)),
      (policy) => emit(PolicyLoaded(policy)),
    );
  }
}

