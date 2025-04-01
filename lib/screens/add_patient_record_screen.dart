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
    await Hive.initFlutter();
    localBox = await Hive.openBox('offlineRecords');
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

  Future<void> _syncOfflineData() async {
    final records = localBox.toMap();
    for (var entry in records.entries) {
      try {
        await ApiService.addRecord(entry.value);
        await localBox.delete(entry.key);
      } catch (_) {
        // Ignore and retry next time
      }
    }
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final recordData = {
        'patientId': widget.patientId,
        'bloodPressure': bpController.text.trim(),
        'oxygenLevel': oxygenController.text.trim(),
        'heartRate': heartRateController.text.trim(),
        'respiratoryRate': respiratoryRateController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (isOffline) {
        await localBox.put('${widget.patientId}_${DateTime.now().millisecondsSinceEpoch}', recordData);
        if (!mounted) return;
        _showSnackbar('✅ Saved locally. Will sync when online.');
        Navigator.pop(context);
      } else {
        try {
          await ApiService.addRecord(recordData);
          if (!mounted) return;
          _showQRCode(recordData);
          await _syncOfflineData();
        } catch (e) {
          if (!mounted) return;
          _showSnackbar('❌ Failed to save: $e');
        }
      }
    }
  }

  void _showQRCode(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code for Record'),
        content: QrImageView(
          data: data.toString(),
          version: QrVersions.auto,
          size: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/viewPatient')),
            child: const Text('Back to Patient Details'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    String? unit,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixText: unit,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildOfflineRecordList() {
    final items = localBox.toMap().entries.where((e) => e.key.toString().startsWith(widget.patientId));
    final sortedItems = items.toList()
      ..sort((a, b) => b.key.toString().compareTo(a.key.toString()));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pending Sync Records', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...sortedItems.map((entry) {
          final ts = DateTime.tryParse(entry.value['timestamp'] ?? '') ?? DateTime.now();
          return ListTile(
            leading: const Icon(Icons.sync_problem, color: Colors.red),
            title: Text('BP: ${entry.value['bloodPressure']}, HR: ${entry.value['heartRate']}'),
            subtitle: Text(DateFormat.yMd().add_jm().format(ts)),
            trailing: const Icon(Icons.warning, color: Colors.orange),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient Record'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              ElevatedButton(
                onPressed: _saveRecord,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Record', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 30),
              if (localBox.isOpen && localBox.isNotEmpty) _buildOfflineRecordList(),
            ],
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
    Hive.close();
    super.dispose();
  }
}
