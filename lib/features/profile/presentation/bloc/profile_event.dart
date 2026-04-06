import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

/// Base class for all profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user profile
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Event to update user profile
class UpdateProfile extends ProfileEvent {
  final UserProfile profile;

  const UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Event to update user avatar
class UpdateAvatar extends ProfileEvent {
  final String imagePath;

  const UpdateAvatar(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Event to delete user avatar
class DeleteAvatar extends ProfileEvent {
  const DeleteAvatar();
}

/// Event to send email verification
class SendEmailVerification extends ProfileEvent {
  const SendEmailVerification();
}

/// Event to send phone verification
class SendPhoneVerification extends ProfileEvent {
  final String phoneNumber;

  const SendPhoneVerification(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

/// Event to verify phone number
class VerifyPhoneNumber extends ProfileEvent {
  final String phoneNumber;
  final String verificationCode;

  const VerifyPhoneNumber(this.phoneNumber, this.verificationCode);

  @override
  List<Object?> get props => [phoneNumber, verificationCode];
}
