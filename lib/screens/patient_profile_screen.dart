import 'package:flutter/material.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile')),
      body: Center(child: Text('Patient details will be displayed here.')),
    );
  }
}
