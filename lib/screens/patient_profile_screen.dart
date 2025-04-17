import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:health_track_pro/services/api_service.dart';
import 'add_patient_record_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late bool isCritical;
  late TextEditingController criticalNotesController;

  @override
  void initState() {
    super.initState();
    isCritical = widget.patient['isCritical'] ?? false;
    criticalNotesController = TextEditingController(text: widget.patient['criticalNotes'] ?? '');
  }

  Future<void> _updateCriticalStatus() async {
    try {
      await ApiService.updatePatient(widget.patient['_id'], {
        'isCritical': isCritical,
        'criticalNotes': criticalNotesController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Patient status updated'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to update status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        backgroundColor: isCritical ? Colors.red.shade800 : Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCritical
                ? [Colors.red.shade800, Colors.red.shade400, Colors.red.shade600]
                : [Colors.blue.shade800, Colors.lightBlue.shade400, Colors.blue.shade600],
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
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Critical Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: isCritical,
                            onChanged: (value) {
                              setState(() => isCritical = value);
                              _updateCriticalStatus();
                            },
                            activeColor: Colors.red,
                          ),
                        ],
                      ),
                      if (isCritical) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: criticalNotesController,
                          decoration: const InputDecoration(
                            labelText: 'Critical Notes',
                            border: OutlineInputBorder(),
                            hintText: 'Enter notes about critical condition',
                          ),
                          maxLines: 3,
                          onChanged: (_) => _updateCriticalStatus(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.patient['lastVitals'] != null) ...[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Vitals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isCritical ? Colors.red.shade900 : Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildVitalCard(
                              'Blood Pressure',
                              widget.patient['lastVitals']['bloodPressure'] ?? 'N/A',
                              Icons.favorite,
                              isCritical,
                            ),
                            _buildVitalCard(
                              'Heart Rate',
                              '${widget.patient['lastVitals']['heartRate'] ?? 'N/A'} bpm',
                              Icons.favorite_border,
                              isCritical,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildVitalCard(
                              'Oxygen Level',
                              '${widget.patient['lastVitals']['oxygenLevel'] ?? 'N/A'}%',
                              Icons.air,
                              isCritical,
                            ),
                            _buildVitalCard(
                              'Respiratory Rate',
                              '${widget.patient['lastVitals']['respiratoryRate'] ?? 'N/A'}',
                              Icons.airline_seat_recline_normal,
                              isCritical,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetail('👤 Name', widget.patient['name'])
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0),
                      _buildDetail('🎂 Age', widget.patient['age'].toString())
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 200.milliseconds),
                      _buildDetail('📞 Contact', widget.patient['contact'])
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 400.milliseconds),
                      _buildDetail('📝 Medical History', widget.patient['history'])
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 600.milliseconds),
                      _buildDetail('⚥ Gender', widget.patient['gender'] ?? 'Not specified')
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
                    builder: (_) => AddPatientRecordScreen(patientId: widget.patient['_id']),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: isCritical ? Colors.red.shade800 : Colors.blue.shade800,
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

  Widget _buildVitalCard(String title, String value, IconData icon, bool isCritical) {
    return Card(
      color: isCritical ? Colors.red.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCritical ? Colors.red.shade300 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: isCritical ? Colors.red.shade700 : Colors.blue.shade700,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isCritical ? Colors.red.shade900 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCritical ? Colors.red.shade900 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
