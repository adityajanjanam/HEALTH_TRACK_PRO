import 'package:flutter/material.dart';

// Modular route configuration
import 'routes.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/patient_profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleThemeMode() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthTrack Pro',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF121212),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      themeMode: _themeMode,

      // Initial screen
      home: const WelcomeScreen(),

      // Static routes
      routes: appRoutes,

      // Dynamic routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/patientProfile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PatientProfileScreen(patient: args),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("❌ 404 - Page not found")),
              ),
            );
        }
      },
    );
  }
}
