import 'package:flutter/material.dart';

class AddRecordsScreen extends StatefulWidget {
  const AddRecordsScreen({super.key});

  @override
  AddRecordsScreenState createState() => AddRecordsScreenState();
}

class AddRecordsScreenState extends State<AddRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedPatient;
  String? recordType;
  final TextEditingController valueController = TextEditingController();

  // Dummy list of patients
  final List<String> patients = [
    'John Doe',
    'Jane Smith',
    'Michael Johnson',
    'Emily Davis'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Records')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Patient',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: selectedPatient,
                items: patients.map((patient) {
                  return DropdownMenuItem(
                    value: patient,
                    child: Text(patient),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPatient = value;
                  });
                },
                validator: (value) => value == null ? 'Select a patient' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text(
                'Record Type',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: recordType,
                items: [
                  'Blood Pressure',
                  'Heart Rate',
                  'Oxygen Level',
                  'Temperature'
                ].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    recordType = value;
                  });
                },
                validator: (value) => value == null ? 'Select a record type' : null,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              const Text(
                'Value',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter the record value',
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a value' : null,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Record Added Successfully!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, minimumSize: const Size.fromHeight(50)),
                child: const Text('Save Record', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
