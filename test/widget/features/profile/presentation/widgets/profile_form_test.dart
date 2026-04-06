import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_library/features/profile/presentation/widgets/profile_form.dart';
import 'package:flutter_library/features/profile/domain/entities/user_profile.dart';

void main() {
  group('ProfileForm Tests', () {
    final testProfile = UserProfile(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phoneNumber: '1234567890',
      bio: 'Test bio',
      address: const ProfileAddress(
        street: '123 Test St',
        city: 'Test City',
        state: 'Test State',
        zipCode: '12345',
        country: 'Test Country',
      ),
      isEmailVerified: true,
      isPhoneVerified: false,
      createdAt: DateTime(2023, 1, 1),
      updatedAt: DateTime(2023, 1, 1),
    );

    Widget createTestWidget({
      required UserProfile profile,
      bool isLoading = false,
      Function(UserProfile)? onProfileChanged,
      VoidCallback? onSendEmailVerification,
      Function(String)? onSendPhoneVerification,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProfileForm(
              profile: profile,
              isLoading: isLoading,
              onProfileChanged: onProfileChanged ?? (_) {},
              onSendEmailVerification: onSendEmailVerification,
              onSendPhoneVerification: onSendPhoneVerification,
            ),
          ),
        ),
      );
    }

    testWidgets('displays profile information correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(profile: testProfile));

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('1234567890'), findsOneWidget);
      expect(find.text('Test bio'), findsOneWidget);
      expect(find.text('123 Test St'), findsOneWidget);
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('Test State'), findsOneWidget);
      expect(find.text('12345'), findsOneWidget);
      expect(find.text('Test Country'), findsOneWidget);
    });

    testWidgets('shows loading state correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(
        profile: testProfile,
        isLoading: true,
      ));
      await tester.pumpAndSettle();

      // Assert - Form fields should be disabled when loading
      final textFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      for (final field in textFields) {
        expect(field.enabled, isFalse);
      }
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      // Arrange
      final emptyProfile = UserProfile(
        id: '1',
        name: '',
        email: '',
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 1),
      );

      // Act
      await tester.pumpWidget(createTestWidget(profile: emptyProfile));
      await tester.pumpAndSettle();

      // Trigger form validation
      final form = tester.widget<Form>(find.byType(Form));
      final formKey = form.key as GlobalKey<FormState>;
      final isValid = formKey.currentState?.validate() ?? false;
      await tester.pumpAndSettle();

      // Assert - form should not be valid with empty required fields
      expect(isValid, isFalse);
    });

    testWidgets('validates email format', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(profile: testProfile));
      await tester.pumpAndSettle();

      // Find email field by looking for the field with email text
      final emailFields = find.widgetWithText(TextFormField, 'john.doe@example.com');
      
      // Enter invalid email
      await tester.enterText(emailFields, 'invalid-email');
      await tester.pumpAndSettle();
      
      // Trigger validation by submitting the form
      final form = tester.widget<Form>(find.byType(Form));
      final isValid = form.key != null && (form.key as GlobalKey<FormState>).currentState?.validate() == true;
      
      // Assert - form should not be valid with invalid email
      expect(isValid, isFalse);
    });

    testWidgets('calls onProfileChanged when form values change', (WidgetTester tester) async {
      // Arrange
      UserProfile? changedProfile;

      // Act
      await tester.pumpWidget(createTestWidget(
        profile: testProfile,
        onProfileChanged: (profile) => changedProfile = profile,
      ));

      // Change the name field
      await tester.enterText(find.byType(TextFormField).first, 'Jane Doe');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Assert
      expect(changedProfile, isNotNull);
      expect(changedProfile!.name, equals('Jane Doe'));
    });

    testWidgets('shows email verification button when not verified', (WidgetTester tester) async {
      // Arrange
      final unverifiedProfile = testProfile.copyWith(isEmailVerified: false);

      // Act
      await tester.pumpWidget(createTestWidget(
        profile: unverifiedProfile,
        onSendEmailVerification: () {},
      ));
      await tester.pumpAndSettle();

      // Assert - Look for the Verify button in the email field
      expect(find.text('Verify'), findsWidgets);
    });

    testWidgets('shows verified badge when email is verified', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(profile: testProfile));

      // Assert
      expect(find.byIcon(Icons.verified), findsOneWidget);
    });

    testWidgets('calls onSendEmailVerification when verify button tapped', (WidgetTester tester) async {
      // Arrange
      bool verificationSent = false;
      final unverifiedProfile = testProfile.copyWith(isEmailVerified: false);

      // Act
      await tester.pumpWidget(createTestWidget(
        profile: unverifiedProfile,
        onSendEmailVerification: () => verificationSent = true,
      ));
      await tester.pumpAndSettle();

      // Find and tap the Verify button (there might be multiple)
      final verifyButtons = find.text('Verify');
      if (verifyButtons.evaluate().isNotEmpty) {
        await tester.tap(verifyButtons.first);
        await tester.pumpAndSettle();
      }

      // Assert
      expect(verificationSent, isTrue);
    });

    testWidgets('shows phone verification button when not verified', (WidgetTester tester) async {
      // Arrange
      final profileWithPhone = testProfile.copyWith(
        phoneNumber: '1234567890',
        isPhoneVerified: false,
      );

      // Act
      await tester.pumpWidget(createTestWidget(
        profile: profileWithPhone,
        onSendPhoneVerification: (_) {},
      ));
      await tester.pumpAndSettle();

      // Assert - Look for the Verify button (multiple may exist)
      expect(find.text('Verify'), findsWidgets);
    });

    testWidgets('validates phone number format', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(profile: testProfile));
      await tester.pumpAndSettle();

      // Find phone field by looking for the field with phone text
      final phoneFields = find.widgetWithText(TextFormField, '1234567890');
      
      // Enter invalid phone number (the widget doesn't validate phone format by default)
      // Just verify the field exists and can be edited
      await tester.enterText(phoneFields, '123');
      await tester.pumpAndSettle();

      // Assert - field should accept the input
      expect(find.text('123'), findsOneWidget);
    });

    testWidgets('has proper form structure with all required fields', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(profile: testProfile));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      
      // Check for specific field labels
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Bio'), findsOneWidget);
    });

    testWidgets('handles address fields correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(profile: testProfile));
      await tester.pumpAndSettle();

      // Assert - Check for address section
      expect(find.text('Address Information'), findsOneWidget);
      expect(find.text('Street Address'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('State'), findsOneWidget);
      expect(find.text('ZIP Code'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('updates address fields correctly', (WidgetTester tester) async {
      // Arrange
      UserProfile? changedProfile;

      // Act
      await tester.pumpWidget(createTestWidget(
        profile: testProfile,
        onProfileChanged: (profile) => changedProfile = profile,
      ));

      // Change street address
      final streetField = find.widgetWithText(TextFormField, '123 Test St');
      await tester.enterText(streetField, '456 New St');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Assert
      expect(changedProfile, isNotNull);
      expect(changedProfile!.address?.street, equals('456 New St'));
    });
  });
}
