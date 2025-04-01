import 'package:flutter/material.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart' as signup;
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart' as home;
import 'screens/add_patient_screen.dart';
import 'screens/list_patients_screen.dart' as view;
import 'screens/add_patient_record_screen.dart';
import 'screens/view_records_screen.dart'; // Import the unified screen here

/// Static route mappings (no arguments required)
final Map<String, WidgetBuilder> appRoutes = {
  // Authentication
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const signup.SignupScreen(),
  '/forgotPassword': (context) => const ForgotPasswordScreen(),

  // Home
  '/home': (context) => const home.HomeScreen(welcomeName: ''),

  // Patients
  '/addPatient': (context) => const AddPatientScreen(),
  '/listPatients': (context) => const view.ListPatientsScreen(patientId: null),

  // Records
  '/addPatientRecord': (context) => const AddPatientRecordScreen(patientId: ''),
  '/viewRecords': (context) => const ViewRecordsScreen(), // Open records screen without patientId
};

/// Dynamic routes for pages that require parameters
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/viewPatient':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => view.ListPatientsScreen(patientId: args['patientId']),
      );

    case '/viewPatientRecords':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) => ViewRecordsScreen(patientId: args['patientId']),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('❌ 404 - Page Not Found')),
        ),
      );
  }
}
