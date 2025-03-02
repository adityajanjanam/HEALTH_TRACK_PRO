import 'package:flutter/material.dart';

class ViewPatientRecordsScreen extends StatelessWidget {
  const ViewPatientRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Patient Records')),
      body: Center(child: Text('List of patient records will be displayed here.')),
    );
  }
}
