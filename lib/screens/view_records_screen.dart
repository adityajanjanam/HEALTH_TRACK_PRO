import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';

class ViewRecordsScreen extends StatefulWidget {
  final String? patientId;
  final String? patientName;
  const ViewRecordsScreen({super.key, this.patientId, this.patientName});

  @override
  State<ViewRecordsScreen> createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  late Future<Map<String, dynamic>> _patientFuture;
  late Future<List<dynamic>> _recordsFuture;
  bool showChart = false;
  String selectedType = 'Blood Pressure';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    if (widget.patientId != null && widget.patientId!.isNotEmpty) {
      _patientFuture = ApiService.getPatientById(widget.patientId!);
      _recordsFuture = ApiService.getPatientRecords(widget.patientId!);
    } else {
      _patientFuture = Future.value({});
      _recordsFuture = ApiService.getRecords('');
    }
  }

  void _shareRecords(List<dynamic> records) {
    final export = records.map((e) {
      final time = e['timestamp'] ?? e['date'] ?? e['createdAt'] ?? 'Unknown';
      return '${e['type']}: ${e['value']} at $time';
    }).join('\n');
    Share.share(export, subject: 'Patient Record History');
  }

  List<FlSpot> _buildChartPoints(List<dynamic> records, String type) {
    final filtered = records.where((e) => e['type'].toString().toLowerCase() == type.toLowerCase()).toList();
    return List.generate(filtered.length, (i) {
      final value = double.tryParse(filtered[i]['value'].toString().split('/').first) ?? 0;
      return FlSpot(i.toDouble(), value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientName != null ? '${widget.patientName}\'s Records' : 'Patient Records'),
        backgroundColor: Colors.teal.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final records = await _recordsFuture;
              _shareRecords(records);
            },
          ),
          IconButton(
            icon: Icon(showChart ? Icons.list : Icons.bar_chart),
            onPressed: () => setState(() => showChart = !showChart),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _patientFuture,
        builder: (context, patientSnap) {
          if (patientSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (patientSnap.hasError) {
            return Center(child: Text('Error loading patient: ${patientSnap.error}'));
          }

          final patient = patientSnap.data ?? {};

          return FutureBuilder<List<dynamic>>(
            future: _recordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading records: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No records found.'));
              }

              final records = snapshot.data!;
              return Column(
                children: [
                  _buildPatientDetails(patient),
                  if (showChart) _buildChartSection(records),
                  if (!showChart)
                    Expanded(
                      child: ListView.builder(
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final type = record['type'] ?? 'Unknown';
                          final value = record['value'] ?? '-';
                          final rawTimestamp = record['timestamp'] ?? record['date'] ?? record['createdAt'] ?? '';
                          final formattedDate = _formatTimestamp(rawTimestamp.toString());
                          final pendingSync = record['offline'] == true;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                              color: pendingSync ? Colors.yellow.shade100 : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade100,
                                  child: Icon(_getIconForType(type), color: Colors.teal),
                                ),
                                title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Value: $value\n$formattedDate'),
                                trailing: pendingSync
                                    ? const Text('Pending', style: TextStyle(color: Colors.orange))
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPatientDetails(Map<String, dynamic> patient) {
    if (patient.isEmpty) return const SizedBox();

    final String name = patient['name'] ?? 'Patient';
    final String? photoUrl = patient['photo'];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.teal.shade200,
            backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? Text(name.isNotEmpty ? name[0] : '?',
                    style: const TextStyle(fontSize: 24, color: Colors.white))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Age: ${patient['age'] ?? '-'}'),
                Text('Gender: ${patient['gender'] ?? '-'}'),
                Text('Contact: ${patient['contact'] ?? '-'}'),
                Text('Email: ${patient['email'] ?? '-'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(List<dynamic> records) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            value: selectedType,
            items: [
              'Blood Pressure',
              'Heart Rate',
              'Oxygen Level',
              'Temperature',
              'Respiratory Rate'
            ].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) {
              if (value != null) setState(() => selectedType = value);
            },
            decoration: const InputDecoration(
              labelText: 'Record Type',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text('${value.toInt() + 1}'),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(show: true),
                gridData: FlGridData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: _buildChartPoints(records, selectedType),
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.orange,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'blood pressure':
        return Icons.favorite;
      case 'heart rate':
      case 'heartbeat rate':
        return Icons.monitor_heart;
      case 'oxygen level':
      case 'blood oxygen level':
        return Icons.bubble_chart;
      case 'temperature':
        return Icons.thermostat;
      case 'respiratory rate':
        return Icons.air;
      default:
        return Icons.healing;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'No Date';
    try {
      return DateFormat('EEE, MMM d • hh:mm a').format(DateTime.parse(timestamp));
    } catch (_) {
      return 'Invalid Date';
    }
  }
}