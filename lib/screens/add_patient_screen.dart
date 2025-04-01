// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  AddPatientScreenState createState() => AddPatientScreenState();
}

class AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController historyController = TextEditingController();
  String? selectedGender;
  bool isOffline = false;
  late Box localBox;

  @override
  void initState() {
    super.initState();
    _initLocalStorage();
    _checkConnectivity();
  }

  Future<void> _initLocalStorage() async {
    await Hive.initFlutter();
    localBox = await Hive.openBox('offlinePatients');
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      isOffline = result == ConnectivityResult.none;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final patient = {
        'name': nameController.text.trim(),
        'age': _calculateAge(dobController.text),
        'gender': selectedGender ?? 'Unknown',
        'contact': contactController.text.trim(),
        'history': historyController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (isOffline) {
        await localBox.put(patient['contact'], patient);
        if (!mounted) return;
        _showSnackbar('Saved offline. Will sync when online.');
        Navigator.pop(context);
      } else {
        try {
          await ApiService.addPatient(patient);
          if (!mounted) return;
          _showSnackbar('✅ Patient added successfully');
          Navigator.pop(context); // Return to previous screen
        } catch (e) {
          if (!mounted) return;
          _showSnackbar('❌ Failed to add patient: $e');
        }
      }
    }
  }

  int _calculateAge(String dob) {
    final birthDate = DateFormat('yyyy-MM-dd').parse(dob);
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final fillColor = isDark ? Colors.grey[850] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
        backgroundColor: Colors.blueAccent,
        actions: [
          Icon(isOffline ? Icons.cloud_off : Icons.cloud_done, color: Colors.white),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '➕ Add Patient',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: nameController,
                        label: 'Enter patient\'s name',
                        icon: Icons.person,
                        textColor: textColor,
                        fillColor: fillColor!,
                        validator: (value) => value!.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 10),

                      _buildDateField(
                        controller: dobController,
                        label: 'Select Date of Birth',
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                        textColor: textColor,
                        fillColor: fillColor,
                      ),
                      const SizedBox(height: 10),

                      _buildGenderDropdown(textColor, fillColor),
                      const SizedBox(height: 10),

                      _buildInputField(
                        controller: contactController,
                        label: 'Enter contact number (10 digits)',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        textColor: textColor,
                        fillColor: fillColor,
                        validator: (value) {
                          if (value!.isEmpty) return 'Contact is required';
                          if (value.length != 10) return 'Enter a valid 10-digit number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      _buildInputField(
                        controller: historyController,
                        label: 'Enter medical history (optional)',
                        icon: Icons.history,
                        maxLines: 2,
                        textColor: textColor,
                        fillColor: fillColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('Submit', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    required Color fillColor,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color textColor,
    required Color fillColor,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: fillColor,
      ),
    );
  }

  Widget _buildGenderDropdown(Color textColor, Color fillColor) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      decoration: InputDecoration(
        labelText: 'Select Gender',
        labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
        prefixIcon: const Icon(Icons.transgender, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: fillColor,
      ),
      dropdownColor: fillColor,
      style: TextStyle(color: textColor),
      items: ['Male', 'Female', 'Other'].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: (value) => setState(() => selectedGender = value),
      validator: (value) => value == null ? 'Please select gender' : null,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    contactController.dispose();
    historyController.dispose();
    Hive.close();
    super.dispose();
  }
}
