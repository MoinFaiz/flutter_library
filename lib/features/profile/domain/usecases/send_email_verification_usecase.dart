import 'package:dartz/dartz.dart';
import 'package:flutter_library/core/error/failures.dart';
import 'package:flutter_library/features/profile/domain/repositories/profile_repository.dart';

class SendEmailVerificationUseCase {
  final ProfileRepository repository;

  SendEmailVerificationUseCase({required this.repository});

  Future<Either<Failure, void>> call() async {
    return await repository.sendEmailVerification();
  }
}
