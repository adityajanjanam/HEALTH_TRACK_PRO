import 'package:flutter/material.dart';

class ViewRecordsScreen extends StatelessWidget {
  const ViewRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> records = [
      {'type': 'Blood Pressure', 'value': '120/80 mmHg', 'date': '2025-03-02'},
      {'type': 'Heart Rate', 'value': '75 bpm', 'date': '2025-03-01'},
      {'type': 'Oxygen Level', 'value': '98%', 'date': '2025-02-28'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('View Records')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: ListTile(
                leading: Icon(
                  records[index]['type'] == 'Blood Pressure'
                      ? Icons.favorite
                      : Icons.monitor_heart,
                  color: Colors.blueAccent,
                  size: 30,
                ),
                title: Text(records[index]['type']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Value: ${records[index]['value']}\nDate: ${records[index]['date']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
