import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:everyday_christian/main.dart';
import 'package:everyday_christian/screens/auth_screen.dart';

void main() {
  testWidgets('App launches with authentication screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EverydayChristianApp());
    await tester.pumpAndSettle();

    // Verify that auth screen is displayed
    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Sign in to continue your spiritual journey'), findsOneWidget);
  });

  testWidgets('Auth form toggles between sign in and sign up', (WidgetTester tester) async {
    await tester.pumpWidget(const EverydayChristianApp());
    await tester.pumpAndSettle();

    // Initially should show Sign In as selected
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Tap Sign Up
    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    // Should now show name field for sign up
    expect(find.text('Full Name'), findsOneWidget);
  });

  testWidgets('Guest option is available', (WidgetTester tester) async {
    await tester.pumpWidget(const EverydayChristianApp());
    await tester.pumpAndSettle();

    // Should show guest option
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Not ready to create an account?'), findsOneWidget);
  });
}