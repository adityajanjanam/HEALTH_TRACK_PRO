// ignore_for_file: use_build_context_synchronously, unused_element

import 'package:flutter/material.dart';
import 'package:health_track_pro/services/api_service.dart';
import 'package:health_track_pro/screens/patient_profile_screen.dart';
import 'package:health_track_pro/screens/view_records_screen.dart';

class ListPatientsScreen extends StatefulWidget {
  final String? patientId;

  const ListPatientsScreen({super.key, this.patientId});

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
        SnackBar(
          content: Text('❌ Failed to load patients: $e'),
          backgroundColor: Colors.red,
        ),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
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
        setState(() {
          patients.removeWhere((p) => p['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Patient deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to delete patient: $e'),
            backgroundColor: Colors.red,
          ),
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

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final secondaryTextColor = colorScheme.onSurfaceVariant;
    final isCritical = patient['isCritical'] ?? false;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      color: isCritical ? Colors.red.shade50 : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCritical ? BorderSide(color: Colors.red.shade300, width: 2) : BorderSide.none,
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCritical ? Colors.red.shade200 : colorScheme.primaryContainer,
                    child: Text(
                      patient['name']?.toString().substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(
                        color: isCritical ? Colors.red.shade900 : colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              patient['name'] ?? 'Unknown',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isCritical) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          'Age: ${patient['age'] ?? 'N/A'} | Gender: ${patient['gender'] ?? 'N/A'}',
                          style: textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: secondaryTextColor), 
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('View Records'), 
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: colorScheme.error),
                            const SizedBox(width: 8),
                            const Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewRecordsScreen(
                                patientId: patient['_id'],
                                patientName: patient['name'],
                              ),
                            ),
                          );
                          break;
                        case 'delete':
                          deletePatient(patient['_id']);
                          break;
                      }
                    },
                  ),
                ],
              ),
              if (isCritical && patient['criticalNotes']?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          patient['criticalNotes'],
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (patient['lastVitals'] != null) ...[
                const SizedBox(height: 8),
                _buildVitalsRow(patient['lastVitals']),
              ],
              if (patient['contact'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: secondaryTextColor),
                    const SizedBox(width: 4),
                    Text(
                      patient['contact'],
                      style: textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                    ),
                  ],
                ),
              ],
              if (patient['history'] != null && patient['history'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Medical History:',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient['history'],
                  style: textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalsRow(Map<String, dynamic> vitals) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildVitalItem('BP', vitals['bloodPressure'] ?? 'N/A'),
        _buildVitalItem('HR', '${vitals['heartRate'] ?? 'N/A'} bpm'),
        _buildVitalItem('SpO2', '${vitals['oxygenLevel'] ?? 'N/A'}%'),
        _buildVitalItem('RR', '${vitals['respiratoryRate'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildVitalItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patients',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchPatients,
          ),
        ],
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : patients.isEmpty
                  ? Center(
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No patients found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add a new patient to get started',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: paginatedPatients.length,
                            itemBuilder: (context, index) {
                              return _buildPatientCard(paginatedPatients[index]);
                            },
                          ),
                        ),
                        if (patients.length > pageSize)
                          Card(
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                                    icon: const Icon(Icons.chevron_left),
                                    onPressed: currentPage > 1
                                        ? () => setState(() => currentPage--)
                                        : null,
                                  ),
                                  Text(
                                    'Page $currentPage of ${(patients.length / pageSize).ceil()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          IconButton(
                                    icon: const Icon(Icons.chevron_right),
                                    onPressed: currentPage < (patients.length / pageSize).ceil()
                                        ? () => setState(() => currentPage++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
    );
  }
}
