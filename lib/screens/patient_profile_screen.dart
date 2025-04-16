import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'add_patient_record_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetail('👤 Name', patient['name'])
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0),
                      _buildDetail('🎂 Age', patient['age'].toString())
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 200.milliseconds),
                      _buildDetail('📞 Contact', patient['contact'])
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 400.milliseconds),
                      _buildDetail('📝 Medical History', patient['history'])
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 600.milliseconds),
                      _buildDetail('⚥ Gender', patient['gender'] ?? 'Not specified')
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 800.milliseconds),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPatientRecordScreen(patientId: patient['_id']),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add New Record'),
              )
                .animate()
                .fadeIn(duration: 600.milliseconds)
                .slideY(begin: 0.2, end: 0, delay: 1.seconds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
