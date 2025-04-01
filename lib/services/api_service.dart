import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.6:5000/api';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static dynamic _decodeResponse(http.Response res) {
    try {
      return jsonDecode(res.body);
    } catch (e) {
      if (kDebugMode) print('❌ JSON decode error: $e');
      return null;
    }
  }

  /// ------------------ PATIENTS ------------------

  static Future<List<dynamic>> getPatients() async {
    final response = await http.get(Uri.parse('$baseUrl/patients'));
    final data = _decodeResponse(response);
    if (response.statusCode == 200) return data is List ? data : [];
    throw Exception('Failed to load patients: ${response.body}');
  }

  static Future<bool> addPatient(Map<String, dynamic> patient) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: headers,
      body: jsonEncode(patient),
    );
    if (response.statusCode == 201) return true;
    if (kDebugMode) print('Add patient error: ${response.body}');
    throw Exception('Failed to add patient: ${response.body}');
  }

  /// Optional: Add patient with image (multipart/form-data)
  static Future<bool> addPatientWithImage(Map<String, String> fields, File? imageFile) async {
    final uri = Uri.parse('$baseUrl/patients');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(fields);

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) return true;
    if (kDebugMode) print('Add patient with image error: ${response.body}');
    throw Exception('Failed to add patient with image: ${response.body}');
  }

  static Future<bool> updatePatient(String id, Map<String, dynamic> patient) async {
    final url = Uri.parse('$baseUrl/patients/$id');
    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(patient),
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to update patient: ${response.body}');
  }

  static Future<bool> deletePatient(String id) async {
    final url = Uri.parse('$baseUrl/patients/$id');
    final response = await http.delete(url);
    if (response.statusCode == 200) return true;
    throw Exception('Failed to delete patient: ${response.body}');
  }

  static Future<Map<String, dynamic>> getPatientById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/patients/$id'));
    final data = _decodeResponse(response);
    if (response.statusCode == 200) return data;
    throw Exception('Failed to fetch patient details: ${response.body}');
  }

  static Future<http.Response> exportPatientsAsPDF() async {
    final response = await http.get(Uri.parse('$baseUrl/patients/export/pdf'));
    if (response.statusCode == 200) return response;
    throw Exception('Failed to export patients: ${response.body}');
  }

  /// ------------------ RECORDS ------------------

  static Future<List<dynamic>> getPatientRecords(String patientId) async {
    final response = await http.get(Uri.parse('$baseUrl/records/$patientId'));
    final data = _decodeResponse(response);
    if (response.statusCode == 200) return data is List ? data : [];
    throw Exception('Failed to load patient records: ${response.body}');
  }

  static Future<bool> addRecord(Map<String, dynamic> record) async {
    final response = await http.post(
      Uri.parse('$baseUrl/records'),
      headers: headers,
      body: jsonEncode(record),
    );
    if (response.statusCode == 201) return true;
    if (kDebugMode) print('Add record error: ${response.body}');
    throw Exception('Failed to add record: ${response.body}');
  }

  static Future<bool> syncOfflineRecords(List<Map<String, dynamic>> records) async {
    final response = await http.post(
      Uri.parse('$baseUrl/records/sync'),
      headers: headers,
      body: jsonEncode({'records': records}),
    );
    if (response.statusCode == 200) return true;
    throw Exception('Sync failed: ${response.body}');
  }

  static Future<List<dynamic>> getRecords(String patientId) async {
    final response = await http.get(Uri.parse('$baseUrl/records/$patientId'));
    final data = _decodeResponse(response);
    if (response.statusCode == 200) return data is List ? data : [];
    throw Exception('Failed to load records: ${response.body}');
  }

  /// ------------------ USERS / AUTH ------------------

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: headers,
      body: jsonEncode(data),
    );
    final resData = _decodeResponse(response);
    if (response.statusCode == 201) return resData;
    throw Exception('Registration failed: ${resData?['error'] ?? response.body}');
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> credentials) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: headers,
      body: jsonEncode(credentials),
    );
    final resData = _decodeResponse(response);
    if (response.statusCode == 200) return resData;
    throw Exception('Login failed: ${resData?['error'] ?? response.body}');
  }

  static Future<String> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/forgot-password'),
      headers: headers,
      body: jsonEncode({'email': email}),
    );
    final resData = _decodeResponse(response);
    if (response.statusCode == 200) return resData['message'] ?? 'Reset email sent';
    throw Exception('Password reset failed: ${resData?['error'] ?? response.body}');
  }
}
