// ignore_for_file: unused_local_variable

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart'; // Import MockClient from testing
// ignore: unused_import
import 'dart:convert'; // Still needed for jsonEncode in one test
// Remove unused imports
// import 'package:mockito/mockito.dart'; 
// import 'dart:convert'; 

import 'package:health_track_pro/services/api_service.dart';
// Remove unused import
// import 'package:health_track_pro/config/env.dart';
// We don't generate mocks for http.Client anymore
// import 'api_service_test.mocks.dart'; 

// Remove mock generation
// @GenerateMocks([http.Client])

void main() {
  group('ApiService Tests', () {

    // Helper to create a MockClient handler
    MockClientHandler createMockHandler(int statusCode, String body) {
      return (http.Request request) async {
        // Print request details for debugging (optional)
        // print('MockClient received: ${request.method} ${request.url}');
        // print('MockClient headers: ${request.headers}');
        // if (request.method == 'POST' || request.method == 'PUT') {
        //   print('MockClient body: ${request.body}');
        // }
        return http.Response(body, statusCode);
      };
    }

    // Use setUp and tearDown to manage the httpClient injection
    setUp(() {
      // Create a default mock client before each test if needed, 
      // or create specific ones inside each test.
    });

    tearDown(() {
      // Reset the client back to the default after each test
      ApiService.resetHttpClient();
    });

    test('getPatients returns list of patients on success', () async {
      const patientsJson = '''[
        {"id": "id1", "name": "John Doe"}, 
        {"id": "id2", "name": "Jane Smith"}
      ]''';
      // Set the mock client specifically for this test
      ApiService.httpClient = MockClient(createMockHandler(200, patientsJson));
      
      final patients = await ApiService.getPatients();
      expect(patients, isA<List>());
      expect(patients.length, 2);
      expect(patients[0]['name'], 'John Doe'); 
      expect(patients[1]['name'], 'Jane Smith');
    });

    test('addPatient returns true on success', () async {
       const responseJson = '{"id": "newId", "name": "John Doe"}';
       // Set the mock client specifically for this test
       ApiService.httpClient = MockClient(createMockHandler(201, responseJson));
       
       // Add ALL required fields based on backend model
       const patientData = { 
         'name': 'John Doe', 
         'age': 30, 
         'gender': 'Male', // Added
         'contact':'1234567', // Adjusted to 7 digits min
         'timestamp': '2024-01-01T00:00:00Z' // Added
       }; 
       final result = await ApiService.addPatient(patientData);
       expect(result, true);
    });

    test('getPatientRecords returns list of records on success', () async {
      const patientId = '67ec1a008df8a6407fe21e3b'; 
      const recordsJson = '''[{"id": "rec1", "type": "BP"}, {"id": "rec2", "type": "HR"}]''';
       // Set the mock client specifically for this test
       ApiService.httpClient = MockClient(createMockHandler(200, recordsJson));
      
      final records = await ApiService.getPatientRecords(patientId);
      expect(records, isA<List>());
      expect(records.length, 2);
      expect(records[0]['type'], 'BP');
      expect(records[1]['type'], 'HR');
    });

    test('getPatients throws ApiException on server error', () async {
       // Set the mock client specifically for this test
       // The mock body has {"error": "Server exploded"}
       ApiService.httpClient = MockClient(createMockHandler(500, '{"error": "Server exploded"}'));

      expect(
        () => ApiService.getPatients(), 
        // Expect ServerException with the message from the mocked body
        throwsA(isA<ServerException>().having((e) => e.message, 'message', 'Server exploded'))
      );
    });

     test('getPatientRecords returns empty list on 404', () async {
      const patientId = '67ec1a008df8a6407fe21e3b'; 
       // Set the mock client specifically for this test
       ApiService.httpClient = MockClient(createMockHandler(404, '{"error": "Not found"}'));

      final records = await ApiService.getPatientRecords(patientId);
      expect(records, isA<List>());
      expect(records.isEmpty, true);
    });

  });
} 