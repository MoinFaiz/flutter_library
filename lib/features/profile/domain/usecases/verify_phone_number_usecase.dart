import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';

class VerifyPhoneNumberUseCase {
  final ProfileRepository repository;

  VerifyPhoneNumberUseCase({required this.repository});

  Future<Either<Failure, void>> call(String phoneNumber, String verificationCode) async {
    return await repository.verifyPhoneNumber(phoneNumber, verificationCode);
  }
}
