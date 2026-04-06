import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_library/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/update_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/send_email_verification_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/send_phone_verification_usecase.dart';
import 'package:flutter_library/features/profile/domain/usecases/verify_phone_number_usecase.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';
import 'package:flutter_library/core/error/failures.dart';

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}
class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}
class MockUpdateAvatarUseCase extends Mock implements UpdateAvatarUseCase {}
class MockDeleteAvatarUseCase extends Mock implements DeleteAvatarUseCase {}
class MockSendEmailVerificationUseCase extends Mock implements SendEmailVerificationUseCase {}
class MockSendPhoneVerificationUseCase extends Mock implements SendPhoneVerificationUseCase {}
class MockVerifyPhoneNumberUseCase extends Mock implements VerifyPhoneNumberUseCase {}

void main() {
  group('ProfileBloc Tests', () {
    late ProfileBloc profileBloc;
    late MockGetProfileUseCase mockGetProfileUseCase;
    late MockUpdateProfileUseCase mockUpdateProfileUseCase;
    late MockUpdateAvatarUseCase mockUpdateAvatarUseCase;
    late MockDeleteAvatarUseCase mockDeleteAvatarUseCase;
    late MockSendEmailVerificationUseCase mockSendEmailVerificationUseCase;
    late MockSendPhoneVerificationUseCase mockSendPhoneVerificationUseCase;
    late MockVerifyPhoneNumberUseCase mockVerifyPhoneNumberUseCase;

    setUp(() {
      mockGetProfileUseCase = MockGetProfileUseCase();
      mockUpdateProfileUseCase = MockUpdateProfileUseCase();
      mockUpdateAvatarUseCase = MockUpdateAvatarUseCase();
      mockDeleteAvatarUseCase = MockDeleteAvatarUseCase();
      mockSendEmailVerificationUseCase = MockSendEmailVerificationUseCase();
      mockSendPhoneVerificationUseCase = MockSendPhoneVerificationUseCase();
      mockVerifyPhoneNumberUseCase = MockVerifyPhoneNumberUseCase();
      
      profileBloc = ProfileBloc(
        getProfileUseCase: mockGetProfileUseCase,
        updateProfileUseCase: mockUpdateProfileUseCase,
        updateAvatarUseCase: mockUpdateAvatarUseCase,
        deleteAvatarUseCase: mockDeleteAvatarUseCase,
        sendEmailVerificationUseCase: mockSendEmailVerificationUseCase,
        sendPhoneVerificationUseCase: mockSendPhoneVerificationUseCase,
        verifyPhoneNumberUseCase: mockVerifyPhoneNumberUseCase,
      );
    });

    tearDown(() {
      profileBloc.close();
    });

    final mockProfile = UserProfile(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '+1234567890',
      bio: 'Test bio',
      avatarUrl: 'https://example.com/avatar.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('initial state should be ProfileInitial', () {
      expect(profileBloc.state, const ProfileInitial());
    });

    group('LoadProfile', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileLoaded] when profile is loaded successfully',
        build: () {
          when(() => mockGetProfileUseCase())
              .thenAnswer((_) async => Right(mockProfile));
          return profileBloc;
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          const ProfileLoading(),
          ProfileLoaded(profile: mockProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileLoading, ProfileError] when profile loading fails',
        build: () {
          when(() => mockGetProfileUseCase())
              .thenAnswer((_) async => const Left(ServerFailure()));
          return profileBloc;
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          const ProfileLoading(),
          const ProfileError('Server error occurred'),
        ],
      );
    });

    group('UpdateProfile', () {
      final updatedProfile = mockProfile.copyWith(
        name: 'Jane Smith',
        bio: 'Updated bio',
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileLoaded] when profile is updated successfully',
        build: () {
          when(() => mockUpdateProfileUseCase(updatedProfile))
              .thenAnswer((_) async => Right(updatedProfile));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(UpdateProfile(updatedProfile)),
        expect: () => [
          ProfileUpdating(profile: mockProfile),
          ProfileLoaded(profile: updatedProfile, successMessage: 'Profile updated successfully'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when profile update fails',
        build: () {
          when(() => mockUpdateProfileUseCase(updatedProfile))
              .thenAnswer((_) async => const Left(ValidationFailure('Invalid data')));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(UpdateProfile(updatedProfile)),
        expect: () => [
          ProfileUpdating(profile: mockProfile),
          ProfileError('Invalid data', profile: mockProfile),
        ],
      );
    });

    group('UpdateAvatar', () {
      const avatarPath = '/path/to/avatar.jpg';

      blocTest<ProfileBloc, ProfileState>(
        'emits [AvatarUpdating, ProfileLoaded] when avatar is updated successfully',
        build: () {
          final updatedProfile = mockProfile.copyWith(
            avatarUrl: 'https://example.com/new-avatar.jpg',
          );
          when(() => mockUpdateAvatarUseCase(avatarPath))
              .thenAnswer((_) async => Right(updatedProfile));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const UpdateAvatar(avatarPath)),
        expect: () => [
          AvatarUpdating(profile: mockProfile),
          ProfileLoaded(profile: mockProfile.copyWith(
            avatarUrl: 'https://example.com/new-avatar.jpg',
          ), successMessage: 'Avatar updated successfully'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [AvatarUpdating, ProfileError] when avatar update fails',
        build: () {
          when(() => mockUpdateAvatarUseCase(avatarPath))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const UpdateAvatar(avatarPath)),
        expect: () => [
          AvatarUpdating(profile: mockProfile),
          ProfileError('Server error occurred', profile: mockProfile),
        ],
      );
    });

    group('DeleteAvatar', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [AvatarUpdating, ProfileLoaded] when avatar is deleted successfully',
        build: () {
          final updatedProfile = mockProfile.copyWith(avatarUrl: null);
          when(() => mockDeleteAvatarUseCase())
              .thenAnswer((_) async => Right(updatedProfile));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const DeleteAvatar()),
        expect: () => [
          AvatarUpdating(profile: mockProfile),
          ProfileLoaded(profile: mockProfile.copyWith(avatarUrl: null), successMessage: 'Avatar removed successfully'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [AvatarUpdating, ProfileError] when avatar deletion fails',
        build: () {
          when(() => mockDeleteAvatarUseCase())
              .thenAnswer((_) async => const Left(ServerFailure()));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const DeleteAvatar()),
        expect: () => [
          AvatarUpdating(profile: mockProfile),
          ProfileError('Server error occurred', profile: mockProfile),
        ],
      );
    });

    group('SendEmailVerification', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [EmailVerificationSent] when email verification is sent successfully',
        build: () {
          when(() => mockSendEmailVerificationUseCase())
              .thenAnswer((_) async => const Right(null));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const SendEmailVerification()),
        expect: () => [
          EmailVerificationSent(profile: mockProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileError] when email verification fails',
        build: () {
          when(() => mockSendEmailVerificationUseCase())
              .thenAnswer((_) async => const Left(ServerFailure()));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const SendEmailVerification()),
        expect: () => [
          ProfileError('Server error occurred', profile: mockProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const SendEmailVerification()),
        expect: () => [],
      );
    });

    group('SendPhoneVerification', () {
      const phoneNumber = '+1234567890';

      blocTest<ProfileBloc, ProfileState>(
        'emits [PhoneVerificationSent] when phone verification is sent successfully',
        build: () {
          when(() => mockSendPhoneVerificationUseCase(phoneNumber))
              .thenAnswer((_) async => const Right(null));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const SendPhoneVerification(phoneNumber)),
        expect: () => [
          PhoneVerificationSent(profile: mockProfile, phoneNumber: phoneNumber),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileError] when phone verification fails',
        build: () {
          when(() => mockSendPhoneVerificationUseCase(phoneNumber))
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const SendPhoneVerification(phoneNumber)),
        expect: () => [
          ProfileError('No internet connection', profile: mockProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const SendPhoneVerification(phoneNumber)),
        expect: () => [],
      );
    });

    group('Error handling edge cases', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles network failure',
        build: () {
          when(() => mockGetProfileUseCase())
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return profileBloc;
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          const ProfileLoading(),
          const ProfileError('No internet connection'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles cache failure',
        build: () {
          when(() => mockGetProfileUseCase())
              .thenAnswer((_) async => const Left(CacheFailure('Cache error')));
          return profileBloc;
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          const ProfileLoading(),
          const ProfileError('Cache error'),
        ],
      );
    });

    group('State management edge cases', () {
      blocTest<ProfileBloc, ProfileState>(
        'maintains previous profile state when update fails',
        build: () {
          final updatedProfile = mockProfile.copyWith(name: 'Jane Smith');
          when(() => mockUpdateProfileUseCase(updatedProfile))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) {
          final updatedProfile = mockProfile.copyWith(name: 'Jane Smith');
          bloc.add(UpdateProfile(updatedProfile));
        },
        verify: (bloc) {
          expect(bloc.state, isA<ProfileError>());
          if (bloc.state is ProfileError) {
            final errorState = bloc.state as ProfileError;
            expect(errorState.message, 'Server error occurred');
          }
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles concurrent updates gracefully',
        build: () {
          final updatedProfile1 = mockProfile.copyWith(name: 'Jane Smith');
          final updatedProfile2 = mockProfile.copyWith(bio: 'New bio');
          
          when(() => mockUpdateProfileUseCase(updatedProfile1))
              .thenAnswer((_) async => Right(updatedProfile1));
          when(() => mockUpdateProfileUseCase(updatedProfile2))
              .thenAnswer((_) async => Right(updatedProfile2));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) async {
          final updatedProfile1 = mockProfile.copyWith(name: 'Jane Smith');
          final updatedProfile2 = mockProfile.copyWith(bio: 'New bio');
          bloc.add(UpdateProfile(updatedProfile1));
          bloc.add(UpdateProfile(updatedProfile2));
        },
        skip: 3, // Skip intermediate states
        expect: () => [
          ProfileLoaded(profile: mockProfile.copyWith(bio: 'New bio'), successMessage: 'Profile updated successfully'),
        ],
      );
    });

    group('VerifyPhoneNumber', () {
      const phoneNumber = '+1234567890';
      const verificationCode = '123456';

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, PhoneVerified] when phone verification succeeds',
        build: () {
          when(() => mockVerifyPhoneNumberUseCase(phoneNumber, verificationCode))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetProfileUseCase())
              .thenAnswer((_) async => Right(mockProfile.copyWith(phoneNumber: phoneNumber)));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const VerifyPhoneNumber(phoneNumber, verificationCode)),
        expect: () => [
          ProfileUpdating(profile: mockProfile),
          PhoneVerified(profile: mockProfile.copyWith(phoneNumber: phoneNumber)),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when phone verification fails',
        build: () {
          when(() => mockVerifyPhoneNumberUseCase(phoneNumber, verificationCode))
              .thenAnswer((_) async => const Left(ValidationFailure('Invalid verification code')));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const VerifyPhoneNumber(phoneNumber, verificationCode)),
        expect: () => [
          ProfileUpdating(profile: mockProfile),
          ProfileError('Invalid verification code', profile: mockProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'emits [ProfileUpdating, ProfileError] when getting updated profile fails after successful verification',
        build: () {
          when(() => mockVerifyPhoneNumberUseCase(phoneNumber, verificationCode))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetProfileUseCase())
              .thenAnswer((_) async => const Left(ServerFailure()));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const VerifyPhoneNumber(phoneNumber, verificationCode)),
        expect: () => [
          ProfileUpdating(profile: mockProfile),
          ProfileError('Server error occurred', profile: mockProfile),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const VerifyPhoneNumber(phoneNumber, verificationCode)),
        expect: () => [],
      );
    });

    group('Success Messages', () {
      blocTest<ProfileBloc, ProfileState>(
        'includes success message when profile is updated',
        build: () {
          final updatedProfile = mockProfile.copyWith(name: 'Jane Smith');
          when(() => mockUpdateProfileUseCase(updatedProfile))
              .thenAnswer((_) async => Right(updatedProfile));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) {
          final updatedProfile = mockProfile.copyWith(name: 'Jane Smith');
          bloc.add(UpdateProfile(updatedProfile));
        },
        expect: () => [
          ProfileUpdating(profile: mockProfile),
          ProfileLoaded(profile: mockProfile.copyWith(name: 'Jane Smith'), successMessage: 'Profile updated successfully'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'includes success message when avatar is updated',
        build: () {
          final updatedProfile = mockProfile.copyWith(
            avatarUrl: 'https://example.com/new-avatar.jpg',
          );
          when(() => mockUpdateAvatarUseCase('path/to/avatar.jpg'))
              .thenAnswer((_) async => Right(updatedProfile));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const UpdateAvatar('path/to/avatar.jpg')),
        expect: () => [
          AvatarUpdating(profile: mockProfile),
          ProfileLoaded(profile: mockProfile.copyWith(
            avatarUrl: 'https://example.com/new-avatar.jpg',
          ), successMessage: 'Avatar updated successfully'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'includes success message when avatar is deleted',
        build: () {
          final updatedProfile = mockProfile.copyWith(avatarUrl: null);
          when(() => mockDeleteAvatarUseCase())
              .thenAnswer((_) async => Right(updatedProfile));
          return profileBloc;
        },
        seed: () => ProfileLoaded(profile: mockProfile),
        act: (bloc) => bloc.add(const DeleteAvatar()),
        expect: () => [
          AvatarUpdating(profile: mockProfile),
          ProfileLoaded(profile: mockProfile.copyWith(avatarUrl: null), successMessage: 'Avatar removed successfully'),
        ],
      );
    });

    group('Operations without current profile', () {
      blocTest<ProfileBloc, ProfileState>(
        'UpdateProfile does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) => bloc.add(UpdateProfile(mockProfile)),
        expect: () => [],
      );

      blocTest<ProfileBloc, ProfileState>(
        'UpdateAvatar does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const UpdateAvatar('path/to/avatar.jpg')),
        expect: () => [],
      );

      blocTest<ProfileBloc, ProfileState>(
        'DeleteAvatar does nothing when no current profile exists',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const DeleteAvatar()),
        expect: () => [],
      );
    });

    group('Additional failure types', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles unknown failure',
        build: () {
          when(() => mockGetProfileUseCase())
              .thenAnswer((_) async => const Left(UnknownFailure('Unknown error')));
          return profileBloc;
        },
        act: (bloc) => bloc.add(const LoadProfile()),
        expect: () => [
          const ProfileLoading(),
          const ProfileError('Unknown error'),
        ],
      );
    });
  });
}

