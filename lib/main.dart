// ignore_for_file: unused_import, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

// Modular route configuration
import 'routes.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/patient_profile_screen.dart';
import 'screens/login_screen.dart';
import 'services/theme_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive with the correct path
  await Hive.initFlutter('C:\\Users\\janja\\Work\\health_track_pro\\data');
  await Hive.openBox('offlinePatients');
  await Hive.openBox('offlinePatientRecords');
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Check if welcome screen has been seen
  final bool hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

  runApp(MyApp(prefs: prefs, hasSeenWelcome: hasSeenWelcome));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  final bool hasSeenWelcome;
  
  const MyApp({super.key, required this.prefs, required this.hasSeenWelcome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  ConnectivityResult _previousResult = ConnectivityResult.none;

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
    _attemptInitialSync();
  }

  Future<void> _attemptInitialSync() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      await ApiService.syncOfflineData();
    }
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (_previousResult == ConnectivityResult.none && 
          (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi)) {
        print('Connection restored, attempting sync...');
        ApiService.syncOfflineData();
      }
      _previousResult = result;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeService(widget.prefs),
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'HealthTrack Pro',
            theme: themeService.currentTheme,
            debugShowCheckedModeBanner: false,
            home: widget.hasSeenWelcome ? const LoginScreen() : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
