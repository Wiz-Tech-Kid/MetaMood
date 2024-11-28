import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hacks/pages/Login/login.dart';
import 'package:hacks/pages/Home/user_management.dart';

const primaryGreen = Color(0xFF4CAF50);
const secondaryGreen = Color(0xFF388E3C);
const backgroundColor = Color(0xFFF5F5F5);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool journalReminders = false;
  bool exerciseReminders = false;
  String language = "english";
  bool darkMode = false;

  final List<Map<String, String>> languages = [
    {"label": "English", "value": "english"},
    {"label": "Spanish", "value": "spanish"},
    {"label": "French", "value": "french"},
    {"label": "German", "value": "german"},
    {"label": "Portuguese", "value": "portuguese"},
  ];

  void handleDataExport() {
    // Placeholder for export functionality
    print("Exporting data...");
  }

  void handleDataDelete() {
    // Placeholder for delete functionality
    print("Deleting data...");
  }

  Future<void> handleLogout() async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Cancel', style: TextStyle(color: secondaryGreen)),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _auth.signOut();
                    // Navigate to LoginPage and remove all previous routes
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                    );
                  } catch (e) {
                    // Show error message if logout fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Logout', style: TextStyle(color: Colors.red)),
              )
            ],
          );
        },
      );
    } catch (e) {
      // Show error message if dialog fails to show
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(darkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              setState(() {
                darkMode = !darkMode;
              });
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: darkMode ? Colors.black : backgroundColor,
        child: ListView(
          children: [
            _buildCard(_buildNotificationCard()),
            _buildCard(_buildPreferencesCard()),
            _buildCard(_buildDataManagementCard()),
            _buildCard(_buildAboutCard()),
            _buildCard(_buildLogoutCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondaryGreen),
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Journal Reminders',
          subtitle: 'Daily reminders to write in your journal',
          value: journalReminders,
          onChanged: (value) {
            setState(() {
              journalReminders = value;
            });
          },
        ),
        _buildSwitchTile(
          title: 'Exercise Reminders',
          subtitle: 'Reminders for daily exercise routines',
          value: exerciseReminders,
          onChanged: (value) {
            setState(() {
              exerciseReminders = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: secondaryGreen)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: primaryGreen,
    );
  }

  Widget _buildPreferencesCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferences',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondaryGreen),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: language,
          decoration: InputDecoration(
            labelText: 'Language',
            labelStyle: const TextStyle(color: primaryGreen),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: primaryGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: const BorderSide(color: primaryGreen),
            ),
          ),
          onChanged: (String? newValue) {
            setState(() {
              language = newValue!;
            });
          },
          items: languages.map((Map<String, String> lang) {
            return DropdownMenuItem<String>(
              value: lang['value'],
              child: Text(lang['label']!, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserAccountManagementPage(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: const Text(
            'User Account Management',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDataManagementCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondaryGreen),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: handleDataExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: const Text(
            'Export All Data',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: handleDataDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: const Text(
            'Delete All Data',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutCard() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: secondaryGreen),
        ),
        SizedBox(height: 16),
        Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
        Text('Developed by Mental Health Tech Team', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildLogoutCard() {
    return ElevatedButton(
      onPressed: handleLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}