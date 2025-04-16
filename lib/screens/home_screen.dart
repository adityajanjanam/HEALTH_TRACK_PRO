// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'add_patient_screen.dart';
import 'list_patients_screen.dart';
import 'add_records_screen.dart' as records;
// ignore: unused_import
import 'view_records_screen.dart' as records_view;
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';

class HomeScreen extends StatelessWidget {
  final String welcomeName;

  const HomeScreen({super.key, required this.welcomeName});

  Future<String> _getUserName() async {
    if (welcomeName.isNotEmpty && welcomeName != 'User') {
      return welcomeName;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'User';
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildUserProfile(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        final displayName = snapshot.data ?? welcomeName;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 32 : 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: isDesktop ? 50 : 40,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: isDesktop ? 36 : 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, $displayName!',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Healthcare Professional',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<_FeatureItem> items, bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final childAspectRatio = isDesktop ? 1.2 : (isTablet ? 1.1 : 1.0);
    final spacing = isDesktop ? 24.0 : 16.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: items.map((item) => _buildFeatureCard(context, item, isDesktop)).toList(),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem item, bool isDesktop) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => item.onTap(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: isDesktop ? 36 : 32,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  item.text,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (item.subtitle != null) ...[
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    item.subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.brightness_6),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: themeService.isDarkMode,
                  onChanged: (_) => themeService.toggleTheme(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.contrast),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'High Contrast',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: themeService.isHighContrast,
                  onChanged: (_) => themeService.toggleContrast(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HealthTrack Pro',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
              theme.colorScheme.secondary.withOpacity(0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
        onRefresh: () async => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(welcomeName: welcomeName),
            transitionDuration: Duration.zero,
          ),
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? screenWidth * 0.1 : 16.0,
              vertical: 24.0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    _buildUserProfile(context, isDesktop)
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 24),
                    _buildThemeToggle(context)
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Quick Actions')
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: -0.2, end: 0, delay: 200.milliseconds),
                    _buildFeatureGrid(
                      context,
                      [
                _FeatureItem(
                  icon: Icons.person_add,
                  text: 'Add Patient',
                          subtitle: 'Register new patients',
                          color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddPatientScreen()),
                  ),
                ),
                _FeatureItem(
                  icon: Icons.people,
                  text: 'View Patients',
                          subtitle: 'Manage patient list',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                            MaterialPageRoute(builder: (_) => const ListPatientsScreen()),
                  ),
                ),
                _FeatureItem(
                  icon: Icons.add_chart,
                  text: 'Add Records',
                          subtitle: 'Record vital signs',
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const records.AddRecordsScreen()),
                  ),
                ),
                _FeatureItem(
                          icon: Icons.assessment,
  text: 'View Records',
                          subtitle: 'Check patient history',
  color: Colors.purple,
  onTap: () => Navigator.push(
    context,
                            MaterialPageRoute(builder: (_) => const ListPatientsScreen()),
                          ),
                        ),
                      ],
                      isDesktop,
                      isTablet,
                    ).animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideY(begin: 0.2, end: 0, delay: 400.milliseconds),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Upcoming Feautures: Analytics & Reports')
                        .animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideX(begin: 0.2, end: 0, delay: 600.milliseconds),
                    _buildFeatureGrid(
                      context,
                      [
                        _FeatureItem(
                          icon: Icons.analytics,
                          text: 'Statistics',
                          subtitle: 'View patient statistics',
                          color: Colors.indigo,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        _FeatureItem(
                          icon: Icons.trending_up,
                          text: 'Trends',
                          subtitle: 'Analyze health trends',
                          color: Colors.teal,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        _FeatureItem(
                          icon: Icons.summarize,
                          text: 'Reports',
                          subtitle: 'Generate reports',
                          color: Colors.deepPurple,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                        _FeatureItem(
                          icon: Icons.notifications,
                          text: 'Alerts',
                          subtitle: 'Health alerts',
                          color: Colors.red,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Coming soon!')),
                            );
                          },
                        ),
                      ],
                      isDesktop,
                      isTablet,
                    ).animate()
                        .fadeIn(duration: 600.milliseconds)
                        .slideY(begin: 0.2, end: 0, delay: 800.milliseconds),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String text;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  _FeatureItem({
    required this.icon,
    required this.text,
    this.subtitle,
    required this.color,
    required this.onTap,
  });
}