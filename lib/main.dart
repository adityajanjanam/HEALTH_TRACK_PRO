import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthTrack Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(), // Removed unsupported fontFamily
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(), // Ensures WelcomeScreen is properly referenced
    );
  }
}
