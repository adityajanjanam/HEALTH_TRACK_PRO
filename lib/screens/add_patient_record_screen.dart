import 'package:flutter/material.dart';

class AddPatientRecordScreen extends StatelessWidget {
  const AddPatientRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient Record')),
      body: Center(child: Text('Form to add a patient record.')),
    );
  }
}
