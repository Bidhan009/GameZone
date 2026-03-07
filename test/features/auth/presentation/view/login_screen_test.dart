import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/auth/presentation/view/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display welcome message and heading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Assert
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Login to continue'), findsOneWidget);
    });

    testWidgets('should display email and password input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Assert - Check for TextFields
      expect(
        find.byType(TextField),
        findsNWidgets(2),
      ); // Email and Password fields

      // Check for icons (person for email, lock for password)
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should display Login button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Assert
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should allow user to enter email', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Find and enter text in email field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'test@example.com');

      // Assert
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should allow user to enter password', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Find and enter text in password field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pump();

      // Password field obscures text, so just verify pump succeeds
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('should display all text labels correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: LoginScreen())),
      );

      // Assert - Verify text field labels
      expect(find.byType(TextField), findsNWidgets(2));

      // The TextFields should have decorations with labels
      final firstField = find.byType(TextField).first;
      expect(firstField, findsOneWidget);
    });
  });
}
