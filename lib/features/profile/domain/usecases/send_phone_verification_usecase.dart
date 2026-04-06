import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';

class SendPhoneVerificationUseCase {
  final ProfileRepository repository;

  SendPhoneVerificationUseCase({required this.repository});

  Future<Either<Failure, void>> call(String phoneNumber) async {
    return await repository.sendPhoneVerification(phoneNumber);
  }
}
