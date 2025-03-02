import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For Date Formatting

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  AddPatientScreenState createState() => AddPatientScreenState();
}

class AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController historyController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Form Key for Validation

  // Function to Select Date
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient Added Successfully!')),
      );
      Navigator.pop(context); // Close the screen after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Section Title
                      const Text(
                        '➕ Add Patient',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Patient Name Field
                      _buildInputField(
                        controller: nameController,
                        label: 'Enter patient\'s name',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Name is required' : null,
                      ),

                      const SizedBox(height: 10),

                      // ✅ Date of Birth Picker
                      _buildDateField(
                        controller: dobController,
                        label: 'Select Date of Birth',
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                      ),

                      const SizedBox(height: 10),

                      // ✅ Contact Number Field
                      _buildInputField(
                        controller: contactController,
                        label: 'Enter contact number (10 digits)',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) return 'Contact number is required';
                          if (value.length != 10) return 'Enter a valid 10-digit number';
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      // ✅ Medical History Field
                      _buildInputField(
                        controller: historyController,
                        label: 'Enter medical history (e.g., allergies, past illnesses)',
                        icon: Icons.history,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Submit Button
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

  // ✅ Generic Input Field Widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  // ✅ Date Picker Field Widget
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      onTap: onTap,
    );
  }
}
