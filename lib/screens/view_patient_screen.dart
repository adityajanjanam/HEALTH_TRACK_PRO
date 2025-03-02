import 'package:flutter/material.dart';
import 'package:health_track_pro/screens/add_patient_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patient Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home', style: TextStyle(color: Colors.white))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewPatientScreen()));
              },
              child: const Text('View Patients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPatientScreen()));
              },
              child: const Text('Add Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewPatientScreen extends StatefulWidget {
  const ViewPatientScreen({super.key});

  @override
  ViewPatientScreenState createState() => ViewPatientScreenState();
}

class ViewPatientScreenState extends State<ViewPatientScreen> {
  List<Map<String, dynamic>> patients = [];
  bool showCriticalOnly = false;

  void _deletePatient(int index) {
    setState(() {
      patients.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Patient deleted successfully!')));
  }

  List<Map<String, dynamic>> getFilteredPatients() {
    if (!showCriticalOnly) return patients;

    return patients.where((patient) {
      int systolic = int.parse(patient['bloodPressure'].split('/')[0]);
      int diastolic = int.parse(patient['bloodPressure'].split('/')[1]);
      int heartRate = int.parse(patient['heartRate']);
      int oxygenLevel = int.parse(patient['oxygenLevel']);

      return systolic > 180 || diastolic > 120 || heartRate < 50 || heartRate > 120 || oxygenLevel < 90;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredPatients = getFilteredPatients();

    return Scaffold(
      appBar: AppBar(title: const Text('Patient List', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search patients...',
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showCriticalOnly = !showCriticalOnly;
                    });
                  },
                  icon: Icon(showCriticalOnly ? Icons.visibility_off : Icons.warning, color: Colors.white),
                  label: Text(showCriticalOnly ? 'Show All Patients' : 'Show Critical Patients'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPatientScreen()));
                  },
                  child: const Text('Add Patient', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredPatients.isEmpty
                  ? const Center(child: Text('No patients found.', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        bool isCritical = getFilteredPatients().contains(filteredPatients[index]);

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          color: isCritical ? Colors.red[100] : Colors.white,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(filteredPatients[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('📞 Phone: ${filteredPatients[index]['phone']}'),
                                Text('📅 DOB: ${filteredPatients[index]['dob']}'),
                                Text('✉️ Email: ${filteredPatients[index]['email']}'),
                                Text('🩺 Medical History: ${filteredPatients[index]['history']}'),
                                Text('💓 Heart Rate: ${filteredPatients[index]['heartRate']} bpm'),
                                Text('🩸 Blood Pressure: ${filteredPatients[index]['bloodPressure']}'),
                                Text('🫁 Oxygen Level: ${filteredPatients[index]['oxygenLevel']}%'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePatient(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
