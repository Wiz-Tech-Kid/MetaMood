import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserAccountManagementPage extends StatefulWidget {
  const UserAccountManagementPage({super.key});

  @override
  UserAccountManagementPageState createState() => UserAccountManagementPageState();
}

class UserAccountManagementPageState extends State<UserAccountManagementPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late User? currentUser;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;

  File? _profileImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  // User preferences and settings
  Map<String, dynamic> _userPreferences = {
    'darkMode': false,
    'notifications': {
      'email': true,
      'push': true,
    },
    'language': 'english',
  };

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    _initializeControllers();
    _fetchUserData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: currentUser?.displayName ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) return;

    try {
      // Fetch additional user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc.get('profileImageUrl');
          _userPreferences = Map<String, dynamic>.from(
              userDoc.get('preferences') ?? _userPreferences
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching user data: ${e.toString()}');
    }
  }

  Future<void> _updateProfile() async {
    if (_validateProfileUpdate()) {
      setState(() => _isLoading = true);

      try {
        // Update display name
        await currentUser?.updateDisplayName(_nameController.text);

        // Upload profile image if selected
        if (_profileImage != null) {
          await _uploadProfileImage();
        }

        // Update Firestore document
        await _firestore.collection('users').doc(currentUser!.uid).set({
          'displayName': _nameController.text,
          'email': _emailController.text,
          'profileImageUrl': _profileImageUrl,
          'preferences': _userPreferences,
        }, SetOptions(merge: true));

        _showSuccessSnackBar('Profile updated successfully');
      } catch (e) {
        _showErrorSnackBar('Update failed: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;

    try {
      // Create a reference to the location you want to store the file
      Reference ref = _storage
          .ref()
          .child('user_profile_images')
          .child('${currentUser!.uid}.jpg');

      // Upload the file
      await ref.putFile(_profileImage!);

      // Get the download URL
      _profileImageUrl = await ref.getDownloadURL();
    } catch (e) {
      _showErrorSnackBar('Image upload failed: ${e.toString()}');
    }
  }

  Future<void> _changePassword() async {
    if (_validatePasswordChange()) {
      setState(() => _isLoading = true);

      try {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser!.email!,
          password: _currentPasswordController.text,
        );
        await currentUser?.reauthenticateWithCredential(credential);

        // Update password
        await currentUser?.updatePassword(_newPasswordController.text);

        _showSuccessSnackBar('Password changed successfully');
        _clearPasswordFields();
      } catch (e) {
        _showErrorSnackBar('Password change failed: ${e.toString()}');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  bool _validateProfileUpdate() {
    if (_nameController.text.isEmpty) {
      _showErrorSnackBar('Name cannot be empty');
      return false;
    }
    return true;
  }

  bool _validatePasswordChange() {
    if (_currentPasswordController.text.isEmpty) {
      _showErrorSnackBar('Current password is required');
      return false;
    }
    if (_newPasswordController.text.length < 6) {
      _showErrorSnackBar('New password must be at least 6 characters');
      return false;
    }
    return true;
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Section
            _buildProfileImageSection(),

            // Profile Information Card
            _buildProfileInformationCard(),

            // Password Change Card
            _buildPasswordChangeCard(),

            // User Preferences Card
            _buildUserPreferencesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : (_profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : null),
              child: _profileImage == null && _profileImageUrl == null
                  ? const Icon(Icons.camera_alt, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap to change profile picture',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInformationCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordChangeCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _changePassword,
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPreferencesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _userPreferences['darkMode'],
              onChanged: (bool value) {
                setState(() {
                  _userPreferences['darkMode'] = value;
                });
                // Implement theme switching logic
              },
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: _userPreferences['notifications']['email'],
              onChanged: (bool value) {
                setState(() {
                  _userPreferences['notifications']['email'] = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: _userPreferences['notifications']['push'],
              onChanged: (bool value) {
                setState(() {
                  _userPreferences['notifications']['push'] = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Language',
                prefixIcon: Icon(Icons.language),
              ),
              value: _userPreferences['language'],
              items: [
                'english',
                'spanish',
                'french',
                'german',
                'portuguese'
              ].map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang.capitalize()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _userPreferences['language'] = newValue!;
                });
                // Implement language change logic
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateUserPreferences,
              child: const Text('Save Preferences'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserPreferences() async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .update({
        'preferences': _userPreferences,
      });

      _showSuccessSnackBar('Preferences updated successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to update preferences: ${e.toString()}');
    }
  }
}

// Extension to capitalize first letter of strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}