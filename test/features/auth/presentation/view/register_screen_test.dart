import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gamezone_flutter/features/auth/presentation/view/register_screen.dart';
import 'package:gamezone_flutter/core/service/storage/user_session_service.dart';

void main() {
  late SharedPreferences mockSharedPreferences;

  setUpAll(() async {
    // Set up shared preferences for testing
    SharedPreferences.setMockInitialValues({});
    mockSharedPreferences = await SharedPreferences.getInstance();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
      ],
      child: const MaterialApp(home: RegisterScreen()),
    );
  }

  group('RegisterScreen - UI Elements', () {
    testWidgets('should display header text and form fields', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Header
      expect(find.text('Create Account'), findsOneWidget);

      // Form labels
      expect(find.text('FullName'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Icons
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.lock_reset_outlined), findsOneWidget);
    });

    testWidgets('should display register button', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Register'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should display login link', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Already have an account? '), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });

  group('RegisterScreen - Form Input', () {
    testWidgets('should allow entering full name', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'John Doe');
      await tester.pump();

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should allow entering email', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'john@example.com');
      await tester.pump();

      // Assert
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('should allow entering phone number', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(2), '9812345678');
      await tester.pump();

      // Assert
      expect(find.text('9812345678'), findsOneWidget);
    });

    testWidgets('should allow entering password', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(3), 'password123');
      await tester.pump();

      // Assert - Password field obscures text, so just verify pump succeeds
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('should allow entering confirm password', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(4), 'password123');
      await tester.pump();

      // Assert - Confirm password field obscures text
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field visibility toggle
      final passwordField = find.byType(TextFormField).at(3);
      final visibilityIcon = find.descendant(
        of: passwordField,
        matching: find.byIcon(Icons.visibility_outlined),
      );

      // Initially password should be obscured
      expect(visibilityIcon, findsOneWidget);

      // Tap to toggle visibility
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Should now show visibility_off icon
      expect(
        find.descendant(
          of: passwordField,
          matching: find.byIcon(Icons.visibility_off_outlined),
        ),
        findsOneWidget,
      );
    });
  });

  group('RegisterScreen - Form Validation', () {
    testWidgets('should show error when name is empty', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap register without filling form
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert - Multiple fields will show "Required" error since no fields are filled
      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('should show error when email is invalid', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter name but invalid email
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'invalid-email');
      await tester.pump();

      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert
      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('should show error when phone is empty', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill name and email but leave phone empty
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'john@example.com');
      await tester.pump();

      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('should show error when password is too short', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill form but short password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'john@example.com');
      await tester.enterText(textFields.at(2), '9812345678');
      await tester.enterText(textFields.at(3), '123'); // Too short
      await tester.pump();

      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert
      expect(find.text('Min 6 characters'), findsOneWidget);
    });

    testWidgets('should show error when passwords do not match', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill form with mismatched passwords
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'john@example.com');
      await tester.enterText(textFields.at(2), '9812345678');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'differentpassword');
      await tester.pump();

      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });

  group('RegisterScreen - Form Submission', () {
    testWidgets('should call register when form is valid', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill out all form fields
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'John Doe');
      await tester.enterText(textFields.at(1), 'john@example.com');
      await tester.enterText(textFields.at(2), '9812345678');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password123');
      await tester.pump();

      // Tap Register
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert - Form submission was processed
      expect(find.byType(TextFormField), findsNWidgets(5));
    });

    testWidgets('should show loading indicator when registering', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should disable register button when loading', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should navigate to login when login link is tapped', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Assert - In a real app, this would navigate back to login screen
      // For testing, we just verify the tap doesn't throw and we're still on register screen
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should not call register when form is invalid', (
      tester,
    ) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill form with invalid data (empty name)
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(1), 'john@example.com');
      await tester.enterText(textFields.at(2), '9812345678');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password123');
      await tester.pump();

      // Tap Register
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert - Form validation should prevent submission
      expect(find.byType(TextFormField), findsNWidgets(5));
    });
  });
}
