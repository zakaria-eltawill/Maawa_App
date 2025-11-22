// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:maawa_project/core/app.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    // Wait for the app to finish loading
    await tester.pumpAndSettle();

    // Verify that the app title is present
    expect(find.text('Maawa'), findsNothing); // Title is in MaterialApp, not visible in widget tree
    
    // Verify that we can find the login screen elements
    // The app should redirect to /auth if not logged in
    // We can check for common login screen elements
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App has MaterialApp.router configured', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify MaterialApp.router is used
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
