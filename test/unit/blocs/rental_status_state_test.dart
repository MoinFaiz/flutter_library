import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/book_details/presentation/bloc/rental_status_state.dart';

import 'package:flutter_library/features/book_details/domain/entities/rental_status.dart';
class DummyRentalStatus extends RentalStatus {
  const DummyRentalStatus()
      : super(
          bookId: 'id',
          status: RentalStatusType.available,
        );
}

void main() {
  group('RentalStatusState', () {
    test('RentalStatusInitial equality', () {
      expect(const RentalStatusInitial(), const RentalStatusInitial());
    });
    
    test('RentalStatusInitial props', () {
      expect(const RentalStatusInitial().props, []);
    });
    
    test('RentalStatusLoading equality', () {
      expect(const RentalStatusLoading(), const RentalStatusLoading());
    });
    
    test('RentalStatusLoading props', () {
      expect(const RentalStatusLoading().props, []);
    });
    
    test('RentalStatusLoaded equality and copyWith', () {
      const status = DummyRentalStatus();
      const loaded = RentalStatusLoaded(rentalStatus: status, actionMessage: 'msg');
      expect(loaded, RentalStatusLoaded(rentalStatus: status, actionMessage: 'msg'));
      expect(loaded.copyWith(rentalStatus: status, actionMessage: 'new'), RentalStatusLoaded(rentalStatus: status, actionMessage: 'new'));
    });
    
    test('RentalStatusLoaded props', () {
      const status = DummyRentalStatus();
      const loaded = RentalStatusLoaded(rentalStatus: status, actionMessage: 'msg');
      expect(loaded.props, [status, 'msg']);
    });
    
    test('RentalStatusLoaded copyWith null actionMessage', () {
      const status = DummyRentalStatus();
      const loaded = RentalStatusLoaded(rentalStatus: status, actionMessage: 'msg');
      final copied = loaded.copyWith(actionMessage: null);
      expect(copied.actionMessage, isNull);
      expect(copied.rentalStatus, status);
    });
    
    test('RentalStatusLoaded copyWith no parameters sets actionMessage to null', () {
      const status = DummyRentalStatus();
      const loaded = RentalStatusLoaded(rentalStatus: status, actionMessage: 'msg');
      final copied = loaded.copyWith();
      expect(copied.rentalStatus, status);
      expect(copied.actionMessage, isNull);
    });
    
    test('RentalStatusError equality and props', () {
      expect(const RentalStatusError('err'), const RentalStatusError('err'));
      expect(const RentalStatusError('err').props, ['err']);
    });
    
    test('RentalStatusError different messages are not equal', () {
      expect(const RentalStatusError('err1'), isNot(equals(const RentalStatusError('err2'))));
    });
    
    test('RentalStatusUpdating equality and props', () {
      const status = DummyRentalStatus();
      expect(const RentalStatusUpdating(rentalStatus: status), const RentalStatusUpdating(rentalStatus: status));
      expect(const RentalStatusUpdating(rentalStatus: status).props, [status]);
    });
    
    test('RentalStatusUpdating different statuses are not equal', () {
      const status1 = DummyRentalStatus();
      const status2 = RentalStatus(bookId: 'id2', status: RentalStatusType.rented);
      expect(const RentalStatusUpdating(rentalStatus: status1), 
             isNot(equals(const RentalStatusUpdating(rentalStatus: status2))));
    });
    
    test('All states extend RentalStatusState', () {
      expect(const RentalStatusInitial(), isA<RentalStatusState>());
      expect(const RentalStatusLoading(), isA<RentalStatusState>());
      expect(const RentalStatusLoaded(rentalStatus: DummyRentalStatus()), isA<RentalStatusState>());
      expect(const RentalStatusError('error'), isA<RentalStatusState>());
      expect(const RentalStatusUpdating(rentalStatus: DummyRentalStatus()), isA<RentalStatusState>());
    });
  });
}
