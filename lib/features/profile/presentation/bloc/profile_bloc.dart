import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/send_email_verification_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/send_phone_verification_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/verify_phone_number_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC for managing profile state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateAvatarUseCase updateAvatarUseCase;
  final DeleteAvatarUseCase deleteAvatarUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final SendPhoneVerificationUseCase sendPhoneVerificationUseCase;
  final VerifyPhoneNumberUseCase verifyPhoneNumberUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateAvatarUseCase,
    required this.deleteAvatarUseCase,
    required this.sendEmailVerificationUseCase,
    required this.sendPhoneVerificationUseCase,
    required this.verifyPhoneNumberUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateAvatar>(_onUpdateAvatar);
    on<DeleteAvatar>(_onDeleteAvatar);
    on<SendEmailVerification>(_onSendEmailVerification);
    on<SendPhoneVerification>(_onSendPhoneVerification);
    on<VerifyPhoneNumber>(_onVerifyPhoneNumber);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    
    final result = await getProfileUseCase();
    
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    emit(ProfileUpdating(profile: currentProfile));
    
    final result = await updateProfileUseCase(event.profile);
    
    result.fold(
      (failure) => emit(ProfileError(failure.message, profile: currentProfile)),
      (profile) => emit(ProfileLoaded(profile: profile, successMessage: 'Profile updated successfully')),
    );
  }

  Future<void> _onUpdateAvatar(UpdateAvatar event, Emitter<ProfileState> emit) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    emit(AvatarUpdating(profile: currentProfile));
    
    final result = await updateAvatarUseCase(event.imagePath);
    
    result.fold(
      (failure) => emit(ProfileError(failure.message, profile: currentProfile)),
      (updatedProfile) => emit(ProfileLoaded(profile: updatedProfile, successMessage: 'Avatar updated successfully')),
    );
  }

  Future<void> _onDeleteAvatar(DeleteAvatar event, Emitter<ProfileState> emit) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    emit(AvatarUpdating(profile: currentProfile));
    
    final result = await deleteAvatarUseCase();
    
    result.fold(
      (failure) => emit(ProfileError(failure.message, profile: currentProfile)),
      (updatedProfile) => emit(ProfileLoaded(profile: updatedProfile, successMessage: 'Avatar removed successfully')),
    );
  }

  Future<void> _onSendEmailVerification(SendEmailVerification event, Emitter<ProfileState> emit) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    final result = await sendEmailVerificationUseCase();
    
    result.fold(
      (failure) => emit(ProfileError(failure.message, profile: currentProfile)),
      (_) => emit(EmailVerificationSent(profile: currentProfile)),
    );
  }

  Future<void> _onSendPhoneVerification(SendPhoneVerification event, Emitter<ProfileState> emit) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    final result = await sendPhoneVerificationUseCase(event.phoneNumber);
    
    result.fold(
      (failure) => emit(ProfileError(failure.message, profile: currentProfile)),
      (_) => emit(PhoneVerificationSent(profile: currentProfile, phoneNumber: event.phoneNumber)),
    );
  }

  Future<void> _onVerifyPhoneNumber(VerifyPhoneNumber event, Emitter<ProfileState> emit) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile == null) return;

    emit(ProfileUpdating(profile: currentProfile));
    
    final result = await verifyPhoneNumberUseCase(event.phoneNumber, event.verificationCode);
    
    await result.fold(
      (failure) async => emit(ProfileError(failure.message, profile: currentProfile)),
      (_) async {
        // Get updated profile after phone verification
        final profileResult = await getProfileUseCase();
        profileResult.fold(
          (failure) => emit(ProfileError(failure.message, profile: currentProfile)),
          (profile) => emit(PhoneVerified(profile: profile)),
        );
      },
    );
  }

  /// Helper method to get current profile from state
  UserProfile? _getCurrentProfile() {
    final currentState = state;
    if (currentState is ProfileLoaded) return currentState.profile;
    if (currentState is ProfileUpdating) return currentState.profile;
    if (currentState is AvatarUpdating) return currentState.profile;
    if (currentState is EmailVerificationSent) return currentState.profile;
    if (currentState is PhoneVerificationSent) return currentState.profile;
    if (currentState is PhoneVerified) return currentState.profile;
    if (currentState is ProfileError) return currentState.profile;
    return null;
  }
}
