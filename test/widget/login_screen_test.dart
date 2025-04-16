// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_track_pro/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:health_track_pro/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:health_track_pro/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  MockClientHandler createMockHandler(int statusCode, String body, {Duration delay = Duration.zero}) {
    return (http.Request request) async {
      await Future.delayed(delay);
      return http.Response(body, statusCode);
    };
  }

  group('LoginScreen Widget Tests', () {
    tearDown(() {
      ApiService.resetHttpClient();
    });
    
    late Widget testWidget;
    late SharedPreferences mockPrefs;

    setUp(() async {
      mockPrefs = await SharedPreferences.getInstance();
      ApiService.resetHttpClient();
      testWidget = ChangeNotifierProvider<ThemeService>(
        create: (_) => ThemeService(mockPrefs),
        child: const MaterialApp(home: LoginScreen()),
      );
    });

    testWidgets('renders login screen with all elements', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Verify welcome text and description
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);

      // Verify form fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Verify icons
      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Find and tap the login button
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation messages
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      // Find and tap the login button
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify validation message
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows loading state during login attempt', (WidgetTester tester) async {
      final mockClient = MockClient(createMockHandler(
        200, 
        jsonEncode({
          'message': 'Login successful',
          'user': {'id': 'userId1', 'name': 'Test User', 'email': 'test@example.com'},
          'token': 'fake-jwt-token'
        }),
        delay: const Duration(milliseconds: 100)
      ));
      ApiService.httpClient = mockClient;

      await tester.pumpWidget(testWidget);
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      
      final loginButtonFinder = find.byType(ElevatedButton);
      expect(find.descendant(of: loginButtonFinder, matching: find.text('Login')), findsOneWidget);
      await tester.tap(loginButtonFinder);
      
      await tester.pump();

      final buttonAfterTap = tester.widget<ElevatedButton>(loginButtonFinder);
      expect(buttonAfterTap.child, isA<CircularProgressIndicator>());

      await tester.pumpAndSettle();
      
      expect(find.text('Quick Actions'), findsOneWidget);
    });
  });
} 