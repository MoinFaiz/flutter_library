import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/core/presentation/base_bloc.dart';

class DummyState extends BaseState {
  const DummyState();
  @override
  List<Object?> get props => [];
}

class DummyDataState extends BaseDataState<String> {
  const DummyDataState(super.data);
  @override
  DummyDataState copyWith(String newData) => DummyDataState(newData);
}

void main() {
  group('BaseState', () {
    test('BaseLoading equality', () {
      expect(BaseLoading(), BaseLoading());
    });
    test('BaseError equality and props', () {
      expect(const BaseError('err'), const BaseError('err'));
      expect(const BaseError('err').props, ['err']);
    });
  });

  group('BaseDataState', () {
    test('BaseDataState equality and copyWith', () {
      final state1 = DummyDataState('foo');
      final state2 = DummyDataState('foo');
      expect(state1, state2);
      expect(state1.copyWith('bar'), DummyDataState('bar'));
    });
  });
}
