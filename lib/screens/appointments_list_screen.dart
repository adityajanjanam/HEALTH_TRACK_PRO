import 'package:flutter/material.dart';

class AppointmentsListScreen extends StatelessWidget {
  const AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments List')),
      body: Center(child: Text('List of appointments will be displayed here.')),
    );
  }
}
