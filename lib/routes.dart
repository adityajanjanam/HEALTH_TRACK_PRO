import 'package:flutter/material.dart';
import 'package:health_track_pro/screens/home_screen.dart' as home;
import 'package:health_track_pro/screens/view_patient_screen.dart' as view;
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/list_patients_screen.dart';
import 'screens/add_patient_record_screen.dart';
import 'screens/view_patient_records_screen.dart';
import 'screens/patient_profile_screen.dart';
import 'screens/appointments_list_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) =>  WelcomeScreen(),
  '/login': (context) =>  LoginScreen(),
  '/home': (context) =>  home.HomeScreen(),
  '/add_patient': (context) =>  AddPatientScreen(),
  '/view_patient': (context) =>  view.ViewPatientScreen(),
       '/listPatients': (context) => ListPatientsScreen(),
      '/addPatientRecord': (context) => AddPatientRecordScreen(),
      '/viewPatientRecords': (context) => ViewPatientRecordsScreen(),
      '/patientProfile': (context) => PatientProfileScreen(),
      '/appointments': (context) => AppointmentsListScreen(),
};
