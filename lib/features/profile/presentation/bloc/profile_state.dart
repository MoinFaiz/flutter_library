import 'package:equatable/equatable.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

/// Base class for all profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state for profile operations
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// State when profile is successfully loaded
class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final String? successMessage;

  const ProfileLoaded({required this.profile, this.successMessage});

  @override
  List<Object?> get props => [profile, successMessage];
}

/// State when profile update is in progress
class ProfileUpdating extends ProfileState {
  final UserProfile profile;

  const ProfileUpdating({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// State when avatar update is in progress
class AvatarUpdating extends ProfileState {
  final UserProfile profile;

  const AvatarUpdating({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// State when email verification is sent
class EmailVerificationSent extends ProfileState {
  final UserProfile profile;

  const EmailVerificationSent({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// State when phone verification is sent
class PhoneVerificationSent extends ProfileState {
  final UserProfile profile;
  final String phoneNumber;

  const PhoneVerificationSent({required this.profile, required this.phoneNumber});

  @override
  List<Object?> get props => [profile, phoneNumber];
}

/// State when phone number is verified
class PhoneVerified extends ProfileState {
  final UserProfile profile;

  const PhoneVerified({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Error state
class ProfileError extends ProfileState {
  final String message;
  final UserProfile? profile;

  const ProfileError(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
