// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'login_screen.dart'; // Adjust path if needed

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Function to handle navigation and setting the flag
  Future<void> _proceedToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true); // Set the flag

    if (context.mounted) { // Check if widget is still mounted
      // Use pushReplacement to prevent going back to WelcomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade800,
              Colors.lightBlue.shade400,
              Colors.blue.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Animated background elements
              Positioned(
                top: height * 0.1,
                left: width * 0.1,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ).animate()
                  .fadeIn(duration: 1.seconds)
                  .scale(delay: 500.milliseconds),
              ),
              Positioned(
                bottom: height * 0.2,
                right: width * 0.1,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ).animate()
                  .fadeIn(duration: 1.seconds)
                  .scale(delay: 700.milliseconds),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animation
                    Image.asset(
                      'assets/logo.png',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                         // Fallback if logo is missing
                         return const Icon(Icons.health_and_safety, size: 180, color: Colors.white);
                      },
                    )
                      .animate()
                      .fadeIn(duration: 800.milliseconds)
                      .scale(delay: 200.milliseconds)
                      .shimmer(delay: 1.seconds, duration: 2.seconds),
                    const SizedBox(height: 30),
                    // App name with animation
                    const Text(
                      'HealthTrack Pro',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    )
                      .animate()
                      .fadeIn(duration: 600.milliseconds)
                      .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 15),
                    // Tagline with animation
                    const Text(
                      'Efficiently manage patient data with ease',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    )
                      .animate()
                      .fadeIn(duration: 600.milliseconds)
                      .slideY(begin: 0.3, end: 0, delay: 200.milliseconds),
                    const SizedBox(height: 50),
                    // Get Started button with animation
                    ElevatedButton(
                      // Call the new function onPressed
                      onPressed: () => _proceedToLogin(context), 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                      .animate()
                      .fadeIn(duration: 800.milliseconds)
                      .scale(delay: 1.seconds)
                      .shimmer(delay: 1.5.seconds),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
