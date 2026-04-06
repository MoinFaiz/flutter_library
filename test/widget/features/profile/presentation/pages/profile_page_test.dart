import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/core/navigation/navigation_service.dart';
import 'package:flutter_library/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter_library/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

class MockProfileBloc extends Mock implements ProfileBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

class FakeProfileEvent extends Fake implements ProfileEvent {}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('ProfilePage Tests', () {
    late MockProfileBloc mockProfileBloc;
    late MockNavigationService mockNavigationService;
    late GetIt sl;

    setUp(() {
      sl = GetIt.instance;
      mockProfileBloc = MockProfileBloc();
      mockNavigationService = MockNavigationService();

      if (!sl.isRegistered<NavigationService>()) {
        sl.registerLazySingleton<NavigationService>(() => mockNavigationService);
      }

      registerFallbackValue(FakeProfileEvent());
    });

    tearDown(() async {
      await sl.reset();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<ProfileBloc>(
            create: (context) => mockProfileBloc,
            child: const ProfilePage(),
          ),
        ),
      );
    }

    UserProfile createMockProfile({
      String id = '1',
      String name = 'John Doe',
      String email = 'john@example.com',
      String? phoneNumber,
      String? avatarUrl,
      bool isEmailVerified = false,
      bool isPhoneVerified = false,
    }) {
      return UserProfile(
        id: id,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        isEmailVerified: isEmailVerified,
        isPhoneVerified: isPhoneVerified,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
    }

    testWidgets('displays profile header and app bar', (WidgetTester tester) async {
      // Arrange
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('displays loading state correctly', (WidgetTester tester) async {
      // Arrange
      when(() => mockProfileBloc.state).thenReturn(const ProfileLoading());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state correctly', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Network error occurred';
      when(() => mockProfileBloc.state).thenReturn(const ProfileError(errorMessage));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load profile'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays profile when loaded', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.text('John Doe'), findsAtLeast(1));
      expect(find.text('john@example.com'), findsAtLeast(1));
    });

    testWidgets('triggers load profile on init', (WidgetTester tester) async {
      // Arrange
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      verify(() => mockProfileBloc.add(const LoadProfile())).called(1);
    });

    testWidgets('triggers retry on error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load profile';
      when(() => mockProfileBloc.state).thenReturn(const ProfileError(errorMessage));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Retry'));

      // Assert
      verify(() => mockProfileBloc.add(const LoadProfile())).called(2); // Once on init, once on retry
    });

    testWidgets('supports pull to refresh', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - RefreshIndicator should be present
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Test pull to refresh by calling onRefresh directly
      final refreshIndicator = find.byType(RefreshIndicator);
      final RefreshIndicator widget = tester.widget(refreshIndicator);
      await widget.onRefresh();

      // Verify refresh event is triggered
      verify(() => mockProfileBloc.add(const LoadProfile())).called(2); // Once on init, once on refresh
    });

    testWidgets('shows success snackbar on profile update success', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.fromIterable([
        ProfileLoaded(profile: mockProfile, successMessage: 'Profile updated successfully'),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Profile updated successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error snackbar on profile error', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.fromIterable([
        ProfileError('Update failed', profile: mockProfile),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows email verification success snackbar', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.fromIterable([
        EmailVerificationSent(profile: mockProfile),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Verification email sent successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows phone verification success snackbar', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      const phoneNumber = '+1234567890';
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.fromIterable([
        PhoneVerificationSent(profile: mockProfile, phoneNumber: phoneNumber),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Verification code sent to $phoneNumber'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows phone verified success snackbar', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(const ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.fromIterable([
        PhoneVerified(profile: mockProfile),
      ]));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Phone number verified successfully'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('displays profile header widget', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets); // Multiple columns expected
    });

    testWidgets('displays profile updating state', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(ProfileUpdating(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('John Doe'), findsAtLeast(1));
      expect(find.text('john@example.com'), findsAtLeast(1));
    });

    testWidgets('displays avatar updating state', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(AvatarUpdating(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('John Doe'), findsAtLeast(1));
      expect(find.text('john@example.com'), findsAtLeast(1));
    });

    testWidgets('has proper layout structure', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile();
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Scaffold), findsAtLeast(1)); // Outer + inner scaffolds
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('shows profile with verified email', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile(isEmailVerified: true);
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('John Doe'), findsAtLeast(1));
      expect(find.text('john@example.com'), findsAtLeast(1));
    });

    testWidgets('shows profile with verified phone', (WidgetTester tester) async {
      // Arrange
      final mockProfile = createMockProfile(
        phoneNumber: '+1234567890',
        isPhoneVerified: true,
      );
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(profile: mockProfile));
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.empty());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('John Doe'), findsAtLeast(1));
      expect(find.text('john@example.com'), findsAtLeast(1));
    });


  });
}
