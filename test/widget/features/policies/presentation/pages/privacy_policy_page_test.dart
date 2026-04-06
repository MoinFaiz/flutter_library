import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_library/features/policies/presentation/pages/privacy_policy_page.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_bloc.dart';
import 'package:flutter_library/features/policies/presentation/bloc/policy_state.dart';
import 'package:flutter_library/features/policies/presentation/pages/policy_page.dart';

class MockPolicyBloc extends Mock implements PolicyBloc {
  @override
  Future<void> close() async {
    return Future.value();
  }
}

void main() {
  late MockPolicyBloc mockPolicyBloc;

  setUp(() {
    mockPolicyBloc = MockPolicyBloc();
    
    // Stub the state and stream
    when(() => mockPolicyBloc.state).thenReturn(PolicyInitial());
    when(() => mockPolicyBloc.stream).thenAnswer((_) => Stream.value(PolicyInitial()));

    // Setup GetIt
    if (GetIt.instance.isRegistered<PolicyBloc>()) {
      GetIt.instance.unregister<PolicyBloc>();
    }
    GetIt.instance.registerFactory<PolicyBloc>(() => mockPolicyBloc);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createTestWidget() {
    return const MaterialApp(
      home: PrivacyPolicyPage(),
    );
  }

  group('PrivacyPolicyPage Tests', () {
    testWidgets('renders correctly with proper structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(PrivacyPolicyPage), findsOneWidget);
      expect(find.byType(PolicyPage), findsOneWidget);
    });

    testWidgets('provides correct policy parameters to PolicyPage', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final policyPage = tester.widget<PolicyPage>(find.byType(PolicyPage));
      expect(policyPage.policyId, equals('privacy'));
      expect(policyPage.title, equals('Privacy Policy'));
    });

    testWidgets('creates PolicyBloc instance', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check that PolicyPage exists
      expect(find.byType(PolicyPage), findsOneWidget);
    });

    testWidgets('has proper widget hierarchy', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(PrivacyPolicyPage), findsOneWidget);
      expect(find.byType(PolicyPage), findsOneWidget);
    });

    testWidgets('displays privacy policy title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      expect(find.text('Privacy Policy'), findsOneWidget);
    });
  });
}
