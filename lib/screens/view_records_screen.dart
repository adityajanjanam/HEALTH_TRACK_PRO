// ignore_for_file: unused_local_variable, unnecessary_to_list_in_spreads, deprecated_member_use, deprecated_member_use, duplicate_ignore, no_leading_underscores_for_local_identifiers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';

class ViewRecordsScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const ViewRecordsScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<ViewRecordsScreen> createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  late Future<List<dynamic>> _recordsFuture;
  bool showChart = false;
  String selectedType = 'Blood Pressure';

  @override
  void initState() {
    super.initState();
    _recordsFuture = ApiService.getPatientRecords(widget.patientId);
  }

  Future<void> _refreshRecords() async {
    setState(() {
      _recordsFuture = ApiService.getPatientRecords(widget.patientId);
    });
  }

  Future<void> _shareRecords(List<dynamic> records) async {
    try {
    final export = records.map((e) {
      final time = e['timestamp'] ?? e['date'] ?? e['createdAt'] ?? 'Unknown';
      return '${e['type']}: ${e['value']} at $time';
    }).join('\n');
      await Share.share(export, subject: 'Patient Record History');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to share records: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to show the edit dialog
  Future<void> _showEditRecordDialog(Map<String, dynamic> record) async {
    final recordId = record['id'];
    if (recordId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Record ID is missing'), backgroundColor: Colors.red),
      );
      return;
    }

    // Use separate controllers for the dialog
    final typeController = TextEditingController(text: record['type']?.toString() ?? '');
    final valueController = TextEditingController(text: record['value']?.toString() ?? '');
    final _dialogFormKey = GlobalKey<FormState>();

    final updatedData = await showDialog<Map<String, String>?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Record'),
        content: Form(
          key: _dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simple TextFormField for Type (could be Dropdown later)
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Record Type'),
                validator: (value) => value == null || value.isEmpty ? 'Type cannot be empty' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Value'),
                validator: (value) => value == null || value.isEmpty ? 'Value cannot be empty' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (_dialogFormKey.currentState!.validate()) {
                Navigator.pop(ctx, {
                  'type': typeController.text.trim(),
                  'value': valueController.text.trim(),
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updatedData != null) {
      try {
        await ApiService.updateRecord(recordId.toString(), updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Record updated successfully'), backgroundColor: Colors.green),
        );
        _refreshRecords(); // Refresh the list after update
      } catch (e) {
        if (kDebugMode) {
          print('Update API Error: $e');
        } 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Update failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildRecordCard(dynamic record) {
    final time = record['timestamp'] ?? record['date'] ?? record['createdAt'] ?? 'Unknown';
    final formattedTime = DateTime.tryParse(time)?.let((date) => DateFormat.yMMMd().add_jm().format(date)) ?? time;
    final recordMap = Map<String, dynamic>.from(record as Map);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          _getIconForType(recordMap['type']),
          color: Colors.blueAccent,
          size: 32,
        ),
        title: Text(
          recordMap['type'] ?? 'Unknown Type', // Handle null type
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Value: ${recordMap['value'] ?? 'N/A'}', // Handle null value
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'Recorded: $formattedTime',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        // Add an Edit button to the trailing part
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.grey.shade600),
          tooltip: 'Edit Record',
          onPressed: () {
            // Debug print the FULL record map
            if (kDebugMode) { 
              print('Record map for edit: $recordMap');
            }
            _showEditRecordDialog(recordMap);
          },
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'blood pressure':
        return Icons.bloodtype;
      case 'blood oxygen level':
        return Icons.bubble_chart;
      case 'heart rate':
        return Icons.monitor_heart;
      case 'respiratory rate':
        return Icons.air;
      default:
        return Icons.medical_services;
    }
  }

  Widget _buildChart(List<dynamic> records) {
    final recordsOfType = records.where((r) => r['type'] == selectedType).toList();
    if (recordsOfType.isEmpty) {
      return Center(
        child: Text(
          'No $selectedType records found',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    final spots = recordsOfType.asMap().entries.map((entry) {
      final value = double.tryParse(entry.value['value'].toString().split('/').first) ?? 0;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blueAccent,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blueAccent.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
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
        title: Text(
          '${widget.patientName}\'s Records',
          style: const TextStyle(
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
            onPressed: _refreshRecords,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              final records = await _recordsFuture;
              _shareRecords(records);
            },
          ),
          IconButton(
            icon: Icon(
              showChart ? Icons.list : Icons.bar_chart,
              color: Colors.white,
            ),
            onPressed: () => setState(() => showChart = !showChart),
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
          child: FutureBuilder<List<dynamic>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError) {
                // Show specific error, but not the generic "Resource not found" if handled by ApiService
                final errorMessage = snapshot.error is NotFoundException 
                  ? 'No records found for this patient.' // Handled case
                  : 'Error loading records: ${snapshot.error}'; // Other errors
                return Center(
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                         mainAxisSize: MainAxisSize.min,
                children: [
                           Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
                           const SizedBox(height: 16),
                           Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.red.shade900),
                           ),
                           const SizedBox(height: 16),
                           ElevatedButton.icon(
                             icon: const Icon(Icons.refresh),
                             label: const Text('Retry'),
                             onPressed: _refreshRecords,
                           )
                         ],
                      ),
                    ),
      ),
    );
  }
              if (snapshot.hasData) {
                final records = snapshot.data!;
                // Check if the list is empty AFTER confirming snapshot.hasData
                if (records.isEmpty) {
                  return Center(
                    child: Card(
      margin: const EdgeInsets.all(16),
                       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
                       child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
        children: [
                             Icon(Icons.folder_off, size: 48, color: Colors.grey.shade400),
                             const SizedBox(height: 16),
                             const Text(
                              'No Records Found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add some records for this patient first.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              onPressed: _refreshRecords, 
                            )
              ],
            ),
          ),
                    ),
                  );
                }
                // If records exist, show list or chart
                return showChart
                    ? _buildChart(records)
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return _buildRecordCard(records[index]);
                          },
      ),
    );
  }
              // Should not happen with FutureBuilder, but added as fallback
              return const Center(child: Text('Something went wrong.', style: TextStyle(color: Colors.white)));
            },
            ),
          ),
        ),
    );
  }
}

extension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}