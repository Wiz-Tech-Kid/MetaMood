import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
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
        color: darkMode ? Colors.black : Colors.grey[50],
        child: ListView(
          children: [
            _buildNotificationCard(),
            _buildPreferencesCard(),
            _buildDataManagementCard(),
            _buildAboutCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: language,
              decoration: const InputDecoration(labelText: 'Language'),
              onChanged: (String? newValue) {
                setState(() {
                  language = newValue!;
                });
              },
              items: languages.map((Map<String, String> lang) {
                return DropdownMenuItem<String>(
                  value: lang['value'],
                  child: Text(lang['label']!),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleDataExport,
              child: const Text('Export All Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: handleDataDelete,
              child: const Text('Delete All Data'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
            const Text('Developed by Mental Health Tech Team', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            AlertDialog(
              title: const Text('Mission'),
              content: const Text('Our mission is to provide supportive tools for mental wellness.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}