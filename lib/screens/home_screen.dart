import 'package:flutter/material.dart';
import 'add_patient_screen.dart';
import 'view_patient_screen.dart' as view;
import 'add_records_screen.dart' as records;
import 'view_records_screen.dart' as records_view;
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfile(context),
            const SizedBox(height: 25),
            _buildSectionTitle('Manage Patients'),
            const SizedBox(height: 10),
            _buildFeatureRow(context, [
              _buildFeatureCard(
                context,
                icon: Icons.person_add,
                text: 'Add Patient',
                color: Colors.blueAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPatientScreen()),
                ),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.people,
                text: 'View Patients',
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const view.ViewPatientScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionTitle('Patient Records'),
            const SizedBox(height: 10),
            _buildFeatureRow(context, [
              _buildFeatureCard(
                context,
                icon: Icons.add_chart,
                text: 'Add Records',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const records.AddRecordsScreen()),
                ),
              ),
              _buildFeatureCard(
                context,
                icon: Icons.view_list,
                text: 'View Records',
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const records_view.ViewRecordsScreen()),
                ),
              ),
            ]),
            const SizedBox(height: 30),
            _buildSectionTitle('App Features'),
            const SizedBox(height: 10),
            _buildFeatureIcons(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.medical_services, color: Colors.blueAccent, size: 40),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Welcome, Adi!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
            onPressed: () => _confirmLogout(context),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String text, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 45, color: color),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureIcon(Icons.favorite, 'Heart Rate', Colors.blue),
        _buildFeatureIcon(Icons.health_and_safety, 'Clinical Info', Colors.red),
        _buildFeatureIcon(Icons.insert_chart, 'Health Records', Colors.green),
        _buildFeatureIcon(Icons.monitor_heart, 'Blood Pressure', Colors.orange),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String text, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 35, color: color),
        ),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
