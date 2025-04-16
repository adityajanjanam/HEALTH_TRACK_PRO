// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../config/env.dart';

class ApiService {
  // Add a static http client instance
  static http.Client _httpClient = http.Client();

  // Add a setter for testing purposes
  @visibleForTesting
  static set httpClient(http.Client client) {
    _httpClient = client;
  }
  // Add a resetter for testing teardown
  @visibleForTesting
  static void resetHttpClient() {
     _httpClient = http.Client();
  }

  static String get baseUrl => Environment.apiBaseUrl;
  static const _connectionTimeout = Duration(milliseconds: Environment.connectionTimeout);

  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-Version': Environment.appVersion,
  };

  static void updateAuthToken(String token) {
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else {
      headers.remove('Authorization');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = _decodeResponse(response);

    switch (statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw ApiException('Bad Request: ${body?['error'] ?? 'Invalid request'}');
      case 401:
        throw UnauthorizedException(body?['error'] ?? 'Unauthorized');
      case 403:
        throw ForbiddenException(body?['error'] ?? 'Access denied');
      case 404:
        throw NotFoundException(body?['error'] ?? 'Resource not found');
      case 500:
        throw ServerException(body?['error'] ?? 'Internal server error');
      default:
        throw ApiException('Request failed with status: $statusCode');
    }
  }

  static dynamic _decodeResponse(http.Response res) {
    try {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    } catch (e) {
      if (kDebugMode) print('❌ JSON decode error: $e');
      return null;
    }
  }

  /// ------------------ PATIENTS ------------------

  static Future<List<dynamic>> getPatients() async {
    try {
      // Use the static _httpClient instance
      final response = await _httpClient.get(
        Uri.parse('$baseUrl${Environment.patientsEndpoint}'),
        headers: headers,
      ).timeout(_connectionTimeout);
      
      final data = _handleResponse(response);
      return data is List ? data : [];
    } on TimeoutException {
      throw ApiException('Connection timeout. Please try again.');
    } catch (e) {
      // Ensure specific exception types are thrown based on _handleResponse
      if (e is ApiException) rethrow;
      throw ApiException('Failed to load patients: $e'); 
    }
  }

  static Future<bool> addPatient(Map<String, dynamic> patient) async {
    try {
      // Use the static _httpClient instance
      final response = await _httpClient.post(
        Uri.parse('$baseUrl${Environment.patientsEndpoint}'),
        headers: headers,
        body: jsonEncode(patient),
      ).timeout(const Duration(milliseconds: Environment.connectionTimeout));

      _handleResponse(response); // Throws on non-2xx
      return true;
    } catch (e) {
      if (kDebugMode) print('Add patient error: $e');
      rethrow; // Rethrow the specific ApiException or other error
    }
  }

  /// Optional: Add patient with image (multipart/form-data)
  static Future<bool> addPatientWithImage(Map<String, String> fields, File? imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl${Environment.patientsEndpoint}');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll(headers);
      request.fields.addAll(fields);

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));
      }

      final streamedResponse = await request.send()
          .timeout(const Duration(milliseconds: Environment.connectionTimeout));
      final response = await http.Response.fromStream(streamedResponse);
      
      _handleResponse(response);
      return true;
    } catch (e) {
      if (kDebugMode) print('Add patient with image error: $e');
      rethrow;
    }
  }

  static Future<bool> updatePatient(String id, Map<String, dynamic> patient) async {
    final url = Uri.parse('$baseUrl/patients/$id');
    // Use the static _httpClient instance
    final response = await _httpClient.put(
      url,
      headers: headers,
      body: jsonEncode(patient),
    );
     _handleResponse(response); // Use handler
     return true;
  }

  static Future<bool> deletePatient(String id) async {
    try {
      final url = Uri.parse('$baseUrl${Environment.patientsEndpoint}/$id');
       // Use the static _httpClient instance
      final response = await _httpClient.delete(
        url,
        headers: headers,
      ).timeout(_connectionTimeout);
      
      _handleResponse(response);
      return true;
    } catch (e) {
      if (kDebugMode) print('Delete patient error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPatientById(String id) async {
    // Use the static _httpClient instance
    final response = await _httpClient.get(Uri.parse('$baseUrl/patients/$id'));
    _handleResponse(response); // Use handler
    final data = _decodeResponse(response);
    return data;
  }

  static Future<http.Response> exportPatientsAsPDF() async {
    // Use the static _httpClient instance
    final response = await _httpClient.get(Uri.parse('$baseUrl/patients/export/pdf'));
    _handleResponse(response);
    return response;
  }

  /// ------------------ RECORDS ------------------

  static Future<List<dynamic>> getPatientRecords(String patientId) async {
    try {
       // Use the static _httpClient instance
      final response = await _httpClient.get(
        Uri.parse('$baseUrl${Environment.recordsEndpoint}/$patientId'),
        headers: headers,
      ).timeout(_connectionTimeout);

      final data = _handleResponse(response);
      return data is List ? data : [];
    } on NotFoundException { 
      if (kDebugMode) print('No records found for patient $patientId (API returned 404).');
      return []; 
    } catch (e) {
      if (kDebugMode) print('Get patient records error: $e');
      // Ensure specific exception types are thrown
      if (e is ApiException) rethrow;
      throw ApiException('Failed to get records: $e'); 
    }
  }

  static Future<bool> addRecord(Map<String, dynamic> record) async {
    try {
       // Use the static _httpClient instance
      final response = await _httpClient.post(
        Uri.parse('$baseUrl${Environment.recordsEndpoint}'),
        headers: headers,
        body: jsonEncode(record),
      ).timeout(Duration(milliseconds: Environment.connectionTimeout));

      _handleResponse(response);
      return true;
    } catch (e) {
      if (kDebugMode) print('Add record error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateRecord(String recordId, Map<String, dynamic> recordData) async {
    try {
      // Only send fields allowed for update (e.g., type, value)
      final Map<String, dynamic> updatePayload = {};
      if (recordData.containsKey('type')) {
        updatePayload['type'] = recordData['type'];
      }
      if (recordData.containsKey('value')) {
        updatePayload['value'] = recordData['value'];
      }

      if (updatePayload.isEmpty) {
        throw ApiException('No valid fields provided for update.');
      }

      final targetUrl = Uri.parse('$baseUrl${Environment.recordsEndpoint}/$recordId');
      if (kDebugMode) {
        print('Attempting to update record via PUT to: ${targetUrl.toString()}');
        print('Update payload: ${jsonEncode(updatePayload)}');
      }
      // Use the static _httpClient instance
      final response = await _httpClient.put(
        targetUrl, 
        headers: headers,
        body: jsonEncode(updatePayload),
      ).timeout(_connectionTimeout);

      final data = _handleResponse(response); 
      return data is Map<String, dynamic> ? data : {};
    } catch (e) {
      if (kDebugMode) print('Update record error for ID $recordId: $e');
      rethrow; 
    }
  }

  static Future<bool> syncOfflineRecords(List<Map<String, dynamic>> records) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/records/sync'),
        headers: headers,
        body: jsonEncode({'records': records}),
      ).timeout(_connectionTimeout); // Added timeout
       _handleResponse(response); // Use handler
       return true;
    } catch (e) {
       if (kDebugMode) print('Sync failed: $e');
       rethrow; // Rethrow
    }
  }

  /// ------------------ USERS / AUTH ------------------

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
       // Use the static _httpClient instance
      final response = await _httpClient.post(
        Uri.parse('$baseUrl${Environment.registerEndpoint}'),
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(milliseconds: Environment.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) print('Registration error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    try {
       // Use the static _httpClient instance
      final response = await _httpClient.post(
        Uri.parse('$baseUrl${Environment.loginEndpoint}'),
        headers: headers,
        body: jsonEncode(credentials),
      ).timeout(const Duration(milliseconds: Environment.connectionTimeout));

      final data = _handleResponse(response);
      if (data['token'] != null) {
        updateAuthToken(data['token']);
      }
      return data;
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      rethrow;
    }
  }

  static Future<String> forgotPassword(String email) async {
    try {
       // Use the static _httpClient instance
      final response = await _httpClient.post(
        Uri.parse('$baseUrl${Environment.forgotPasswordEndpoint}'),
        headers: headers,
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(milliseconds: Environment.connectionTimeout));

      final data = _handleResponse(response);
      return data['message'] ?? 'Reset email sent';
    } catch (e) {
      if (kDebugMode) print('Forgot password error: $e');
      rethrow;
    }
  }

  /// ------------------ OFFLINE SYNC ------------------

  static Future<void> syncOfflineData() async {
    if (kDebugMode) print('Attempting to sync offline data...');
    
    Box? localBox;
    try {
      localBox = await Hive.openBox('offlinePatientRecords');
      final recordsToSync = localBox.toMap();
      int successCount = 0;
      int failCount = 0;

      if (recordsToSync.isEmpty) {
        if (kDebugMode) print('No offline records to sync.');
        return;
      }

      if (kDebugMode) print('Found ${recordsToSync.length} records to sync.');

      for (var entry in recordsToSync.entries) {
        final key = entry.key;
        final record = Map<String, dynamic>.from(entry.value as Map);
        
        if (kDebugMode) print('Syncing record with key: $key');
        
        try {
          await addRecord(record); // Already uses injected client
          await localBox.delete(key);
          successCount++;
          if (kDebugMode) print('Successfully synced and deleted record: $key');
        } catch (e) {
          failCount++;
          if (kDebugMode) print('Failed to sync record $key: $e');
        }
      }
      
      if (kDebugMode) print('Sync attempt finished. Success: $successCount, Failed: $failCount');

    } catch (e) {
      if (kDebugMode) print('Error during sync process: $e');
    } 
  }
}

/// ------------------ EXCEPTIONS ------------------

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
