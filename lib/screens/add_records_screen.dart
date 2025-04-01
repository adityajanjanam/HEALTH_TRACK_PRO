import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';

class AddRecordsScreen extends StatefulWidget {
  const AddRecordsScreen({super.key});

  @override
  AddRecordsScreenState createState() => AddRecordsScreenState();
}

class AddRecordsScreenState extends State<AddRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPatientId;
  String? recordType;
  final TextEditingController valueController = TextEditingController();
  List<dynamic> patients = [];
  bool isOffline = false;
  late Box offlineBox;

  @override
  void initState() {
    super.initState();
    fetchPatients();
    initHive();
    checkConnectivity();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    offlineBox = await Hive.openBox('offlinePatientRecords');
  }

  Future<void> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }

  Future<void> fetchPatients() async {
    try {
      final data = await ApiService.getPatients();
      if (!mounted) return;
      setState(() {
        patients = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error loading patients: $e')),
      );
    }
  }

  Future<void> _submitRecord() async {
    if (_formKey.currentState!.validate()) {
      final record = {
        'patientId': selectedPatientId,
        'type': recordType,
        'value': valueController.text.trim(),
        'date': DateTime.now().toIso8601String(),
      };

      if (isOffline) {
        await offlineBox.add(record);
        if (!mounted) return;
        _showSnackbar('✅ Record saved offline. Will sync later.');
        Navigator.pop(context);
      } else {
        try {
          await ApiService.addRecord(record);
          if (!mounted) return;
          _showSnackbar('✅ Record added successfully!');
          Navigator.pop(context);
        } catch (e) {
          if (!mounted) return;
          _showSnackbar('❌ Error: $e');
        }
      }
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String getHintText(String? type) {
    switch (type) {
      case 'Blood Pressure':
        return 'e.g., 120/80';
      case 'Blood Oxygen Level':
        return 'e.g., 98';
      case 'Heartbeat Rate':
        return 'e.g., 72';
      case 'Respiratory Rate':
        return 'e.g., 18';
      default:
        return 'Enter the record value';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Records'),
        backgroundColor: Colors.orange,
        actions: [
          Icon(isOffline ? Icons.cloud_off : Icons.cloud_done, color: Colors.white),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedPatientId,
                items: patients.map<DropdownMenuItem<String>>((patient) {
                  return DropdownMenuItem(
                    value: patient['_id'],
                    child: Text(patient['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedPatientId = value),
                validator: (value) => value == null ? 'Select a patient' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text('Record Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: recordType,
                items: [
                  'Blood Pressure',
                  'Respiratory Rate',
                  'Blood Oxygen Level',
                  'Heartbeat Rate',
                ].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => recordType = value),
                validator: (value) => value == null ? 'Select a record type' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text('Value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: valueController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: getHintText(recordType),
                ),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a value' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _submitRecord,
                icon: const Icon(Icons.save),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size.fromHeight(50),
                ),
                label: const Text('Save Record', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    valueController.dispose();
    Hive.close();
    super.dispose();
  }
}
