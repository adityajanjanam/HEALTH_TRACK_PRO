// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'add_patient_screen.dart';
import 'list_patients_screen.dart';
import 'add_records_screen.dart' as records;
import 'view_records_screen.dart' as records_view;
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  final String welcomeName;

  const HomeScreen({super.key, required this.welcomeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(welcomeName: welcomeName),
            transitionDuration: Duration.zero,
          ),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserProfile(context),
              const SizedBox(height: 25),
              _buildSectionTitle('Manage Patients'),
              _buildFeatureGrid(context, [
                _FeatureItem(
                  icon: Icons.person_add,
                  text: 'Add Patient',
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPatientScreen()),
                  ),
                ),
                _FeatureItem(
                  icon: Icons.people,
                  text: 'View Patients',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListPatientsScreen(patientId: null)),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _buildSectionTitle('Patient Records'),
              _buildFeatureGrid(context, [
                _FeatureItem(
                  icon: Icons.add_chart,
                  text: 'Add Records',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const records.AddRecordsScreen()),
                  ),
                ),
                _FeatureItem(
  icon: Icons.view_list,
  text: 'View Records',
  color: Colors.purple,
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const records_view.ViewRecordsScreen(patientId: null),
    ),
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
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(Icons.medical_services, color: Colors.blueAccent, size: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Welcome, ${welcomeName.isNotEmpty ? welcomeName : 'User'}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<_FeatureItem> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) => item.build(context)).toList(),
    );
  }

  Widget _buildFeatureIcons() {
    final features = [
      {'icon': Icons.favorite, 'text': 'Heart Rate', 'color': Colors.blue},
      {'icon': Icons.health_and_safety, 'text': 'Clinical Info', 'color': Colors.red},
      {'icon': Icons.insert_chart, 'text': 'Health Records', 'color': Colors.green},
      {'icon': Icons.monitor_heart, 'text': 'Blood Pressure', 'color': Colors.orange},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: features.map((feature) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (feature['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(feature['icon'] as IconData, size: 35, color: feature['color'] as Color),
            ),
            const SizedBox(height: 4),
            Text(
              feature['text'] as String,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: feature['color'] as Color),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onTap;

  _FeatureItem({
    required this.icon,
    required this.text,
    required this.color,
    required this.onTap,
  });

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 28,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}