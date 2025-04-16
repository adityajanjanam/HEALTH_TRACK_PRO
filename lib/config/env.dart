import 'package:flutter/foundation.dart';

class Environment {
  static const bool isDevelopment = kDebugMode;
  
  static String get apiBaseUrl {
    if (isDevelopment) {
      // Use localhost for web, host IP for mobile
      if (kIsWeb) {
        return 'http://localhost:5000/api';
      } else {
        return 'http://192.168.1.10:5000/api'; 
      }
    }
    // Production URL
    return 'https://api.healthtrackpro.com/api';
  }

  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  static const String appName = 'HealthTrack Pro';
  static const String appVersion = '1.0.0';

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;

  // Cache configuration
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const int maxCacheSize = 10 * 1024 * 1024; // 10MB

  // API Endpoints
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String forgotPasswordEndpoint = '/users/forgot-password';
  static const String patientsEndpoint = '/patients';
  static const String recordsEndpoint = '/records';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';

  // Test credentials
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test@123';
} 