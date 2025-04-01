// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:health_track_pro/services/api_service.dart';
import 'package:health_track_pro/screens/patient_profile_screen.dart';

class ListPatientsScreen extends StatefulWidget {
  const ListPatientsScreen({super.key, required patientId});

  @override
  State<ListPatientsScreen> createState() => _ListPatientsScreenState();
}

class _ListPatientsScreenState extends State<ListPatientsScreen> {
  List<dynamic> patients = [];
  bool isLoading = true;
  int currentPage = 1;
  final int pageSize = 5;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    try {
      setState(() => isLoading = true);
      final data = await ApiService.getPatients();
      setState(() {
        patients = data;
        isLoading = false;
        currentPage = 1;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to load patients: $e')),
      );
    }
  }

  List<dynamic> get paginatedPatients {
    final start = (currentPage - 1) * pageSize;
    return patients.skip(start).take(pageSize).toList();
  }

  Future<void> deletePatient(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient'),
        content: const Text('Are you sure you want to delete this patient?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.deletePatient(id);
        await fetchPatients();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Patient deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _editPatient(BuildContext context, Map patient) async {
    final nameController = TextEditingController(text: patient['name']);
    final contactController = TextEditingController(text: patient['contact']);

    final updated = await showDialog<Map<String, String>?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contactController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final contact = contactController.text.trim();
              if (name.isNotEmpty && contact.isNotEmpty) {
                Navigator.pop(ctx, {'name': name, 'contact': contact});
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (updated != null) {
      try {
        await ApiService.updatePatient(patient['_id'], updated);
        await fetchPatients();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Patient updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Update failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (patients.length / pageSize).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
        backgroundColor: Colors.teal.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
              ? const Center(child: Text('No patients found.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: paginatedPatients.length,
                        itemBuilder: (context, index) {
                          final patient = paginatedPatients[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Card(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade900
                                  : Colors.white,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientProfileScreen(patient: patient),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.teal.shade100,
                                        child: const Icon(Icons.person, color: Colors.teal),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              patient['name'] ?? 'Unknown',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text("📞 Phone: ${patient['contact']}"),
                                            Text("🎂 Age: ${patient['age']}"),
                                            Text("⚧ Gender: ${patient['gender']}"),
                                            if (patient['history'] != null)
                                              Text("📋 Medical History: ${patient['history']}"),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            onPressed: () => _editPatient(context, patient),
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                          ),
                                          IconButton(
                                            onPressed: () => deletePatient(patient['_id']),
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
                            icon: const Icon(Icons.arrow_back),
                          ),
                          Text('Page $currentPage of $totalPages'),
                          IconButton(
                            onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
                            icon: const Icon(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
