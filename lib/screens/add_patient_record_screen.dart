// ignore_for_file: unused_import, unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';

class AddPatientRecordScreen extends StatefulWidget {
  final String patientId;
  const AddPatientRecordScreen({super.key, required this.patientId});

  @override
  State<AddPatientRecordScreen> createState() => _AddPatientRecordScreenState();
}

class _AddPatientRecordScreenState extends State<AddPatientRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final bpController = TextEditingController();
  final oxygenController = TextEditingController();
  final heartRateController = TextEditingController();
  final respiratoryRateController = TextEditingController();

  late Box localBox;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _initHive();
    _checkConnection();
  }

  Future<void> _initHive() async {
    localBox = await Hive.openBox('offlinePatientRecords');
    _loadLastRecord();
  }

  void _loadLastRecord() {
    final record = localBox.get(widget.patientId);
    if (record != null) {
      bpController.text = record['bloodPressure'] ?? '';
      oxygenController.text = record['oxygenLevel'] ?? '';
      heartRateController.text = record['heartRate'] ?? '';
      respiratoryRateController.text = record['respiratoryRate'] ?? '';
    }
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() => isOffline = result == ConnectivityResult.none);
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create records in the format expected by the API
        final records = [
          {
            'patientId': widget.patientId,
            'type': 'Blood Pressure',
            'value': bpController.text.trim(),
            'timestamp': DateTime.now().toIso8601String(),
          },
          {
            'patientId': widget.patientId,
            'type': 'Blood Oxygen Level',
            'value': oxygenController.text.trim(),
            'timestamp': DateTime.now().toIso8601String(),
          },
          {
            'patientId': widget.patientId,
            'type': 'Heart Rate',
            'value': heartRateController.text.trim(),
            'timestamp': DateTime.now().toIso8601String(),
          },
          {
            'patientId': widget.patientId,
            'type': 'Respiratory Rate',
            'value': respiratoryRateController.text.trim(),
            'timestamp': DateTime.now().toIso8601String(),
          },
        ];

        if (isOffline) {
          // Save each record to Hive
          for (var record in records) {
            final key = '${widget.patientId}_${record['type']}_${DateTime.now().millisecondsSinceEpoch}';
            await localBox.put(key, record);
          }
          if (!mounted) return;
          _showSnackbar('✅ Records saved locally. Will sync when online.');
          Navigator.pop(context);
        } else {
          // Save records to API
          for (var record in records) {
            await ApiService.addRecord(record);
          }
          if (!mounted) return;
          _showSnackbar('✅ Records saved successfully!');
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        _showSnackbar('❌ Failed to save records: $e');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.startsWith('✅') ? Colors.green : Colors.red,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    String? unit,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(icon, color: Colors.blueAccent),
                suffixText: unit,
                suffixStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Patient Record',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📊 Patient Vitals',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Record the patient\'s vital signs below',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Blood Pressure',
                    icon: Icons.bloodtype,
                    controller: bpController,
                    hintText: 'e.g., 120/80',
                    unit: 'mmHg',
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: 'Oxygen Level',
                    icon: Icons.bubble_chart,
                    controller: oxygenController,
                    hintText: 'e.g., 98',
                    unit: '%',
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: 'Heart Rate',
                    icon: Icons.monitor_heart,
                    controller: heartRateController,
                    hintText: 'e.g., 72',
                    unit: 'bpm',
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    label: 'Respiratory Rate',
                    icon: Icons.air,
                    controller: respiratoryRateController,
                    hintText: 'e.g., 16',
                    unit: 'breaths/min',
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _saveRecord,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              isOffline ? 'Save Offline' : 'Save Record',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isOffline) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber, color: Colors.orange.shade800),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You are currently offline. Records will be saved locally and synced when online.',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bpController.dispose();
    oxygenController.dispose();
    heartRateController.dispose();
    respiratoryRateController.dispose();
    super.dispose();
  }
}
