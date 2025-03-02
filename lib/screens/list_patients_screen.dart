import 'package:flutter/material.dart';

class ListPatientsScreen extends StatelessWidget {
  const ListPatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient List')),
      body: Center(child: Text('List of Patients will be displayed here.')),
    );
  }
}
