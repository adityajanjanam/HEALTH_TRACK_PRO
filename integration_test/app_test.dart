import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_track_pro/config/env.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('full app flow test', (tester) async {
      SharedPreferences.setMockInitialValues({});

      expect(find.byType(TextFormField), findsNWidgets(2));

      // Enter login credentials
      await tester.enterText(
        find.byType(TextFormField).first,
        Environment.testEmail
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        Environment.testPassword
      );

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.text('Quick Actions'), findsOneWidget);

      // Navigate to Add Patient
      await tester.tap(find.text('Add Patient').first);
      await tester.pumpAndSettle();

      // Fill in patient details
      await tester.enterText(
        find.byType(TextFormField).first,
        'John Doe'
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '30'
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Male'
      );
      
      // Save patient
      await tester.tap(find.text('Save Patient'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Patient added successfully'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Navigate to View Patients
      await tester.tap(find.text('View Patients').first);
      await tester.pumpAndSettle();

      // Should see the added patient
      expect(find.text('John Doe'), findsOneWidget);

      // Open patient details
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Add a record
      await tester.tap(find.text('Add Record'));
      await tester.pumpAndSettle();

      // Fill in record details
      await tester.enterText(
        find.byType(TextFormField).first,
        '120/80'
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '98'
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        '72'
      );
      await tester.enterText(
        find.byType(TextFormField).at(3),
        '16'
      );

      // Save record
      await tester.tap(find.text('Save Record'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Record added successfully'), findsOneWidget);

      // Navigate back to patient details
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify record is displayed
      expect(find.text('Blood Pressure: 120/80'), findsOneWidget);
      expect(find.text('Oxygen Level: 98%'), findsOneWidget);
      expect(find.text('Heart Rate: 72 bpm'), findsOneWidget);
      expect(find.text('Respiratory Rate: 16/min'), findsOneWidget);
    });
  });
} 