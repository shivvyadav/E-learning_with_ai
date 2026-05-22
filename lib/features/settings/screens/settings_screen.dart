import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/services/api_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../storage/secure_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ============================================
  // Profile Update
  // ============================================
  Future<void> _showProfileDialog() async {
    final authProvider = context.read<AuthProvider>();
    final usernameController = TextEditingController(text: authProvider.currentUserName ?? '');

    var isLoading = false;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Profile'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 12),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: authProvider.currentUserEmail ?? '',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final newName = usernameController.text.trim();
                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Username cannot be empty')),
                          );
                          return;
                        }

                        setState(() => isLoading = true);
                        final success = await _updateUsername(newName);
                        setState(() => isLoading = false);

                        if (success) {
                          await authProvider.updateName(newName);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated successfully')),
                          );
                          Navigator.pop(context);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _updateUsername(String newName) async {
    try {
      final token = await SecureStorageService.getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final apiService = ApiService();
      final uri = Uri.parse('${apiService.baseUrl}/auth/profile');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'username': newName}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final message = body is Map && body['message'] != null ? body['message'].toString() : 'Update failed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }

      return false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
      return false;
    }
  }

  // ============================================
  // Change Password (Using Existing Backend Endpoint)
  // ============================================
  Future<void> _showChangePasswordDialog() async {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isLoading = false;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final current = currentPasswordController.text.trim();
                      final next = newPasswordController.text.trim();
                      final confirm = confirmPasswordController.text.trim();

                      if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All fields are required')),
                        );
                        return;
                      }

                      if (next.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must be at least 6 characters')),
                        );
                        return;
                      }

                      if (next != confirm) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New passwords do not match')),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      final success = await _changePassword(
                        currentPassword: current,
                        newPassword: next,
                        confirmPassword: confirm,
                      );

                      setState(() => isLoading = false);

                      if (success) {
                        if (!mounted) return;
                        Navigator.pop(context);
                        // Clear the password fields
                        currentPasswordController.clear();
                        newPasswordController.clear();
                        confirmPasswordController.clear();
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}

  Future<bool> _changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  try {
    final token = await SecureStorageService.getAccessToken();
    
    print("🔑 Token exists: ${token != null}");
    
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login again'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    // Create ApiService instance
    final apiService = ApiService();
    final uri = Uri.parse('${apiService.baseUrl}/changepassword');
    
    print("📤 URL: $uri");
    print("📤 Current Password: $currentPassword");
    print("📤 New Password: $newPassword");
    
    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldpassword': currentPassword,
        'newpassword': newPassword,
        'confirmpassword': confirmPassword,
      }),
    );

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response body: ${response.body}");

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    }

    final message = body is Map && body['message'] != null
        ? body['message'].toString()
        : 'Password update failed';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }

    return false;
  } catch (e) {
    print("❌ Error: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update password: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }
}

  // ============================================
  // Help & Support Dialog
  // ============================================
  Future<void> _showHelpSupportDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '📞 Contact Us',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('Phone: +977 980-1234567'),
              const Text('Email: support@elearning.com'),
              const SizedBox(height: 16),
              const Text(
                '📱 Social Media',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('Facebook: @elearning.official'),
              const Text('Instagram: @elearning_app'),
              const Text('Twitter: @elearning'),
              const SizedBox(height: 16),
              const Text(
                '⏰ Support Hours',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('Monday - Friday: 9:00 AM - 6:00 PM'),
              const Text('Saturday: 10:00 AM - 4:00 PM'),
              const Text('Sunday: Closed'),
              const SizedBox(height: 16),
              const Text(
                '💬 Live Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text('Available on our website: www.elearning.com/chat'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // About Dialog
  // ============================================
  Future<void> _showAboutDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const SingleChildScrollView(
          child: Text(
            'App Name: E-Learning Mobile App\n'
            'Version: 1.0.0\n\n'
            'This application is a mobile e-learning platform developed as an academic group project. It allows users to browse available courses, enroll in them, and learn through structured lesson videos. The system integrates a backend server for authentication, course management, enrollments, and learning progress tracking.\n\n'
            'The mobile app focuses on providing a simple and accessible learning experience for students.\n\n'
            '© 2024 E-Learning Platform. All rights reserved.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // Build UI
  // ============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Account Section
          _buildSectionTitle('Account'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Manage your account',
            onTap: _showProfileDialog,
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Password',
            subtitle: 'Change your password',
            onTap: _showChangePasswordDialog,
          ),
          const SizedBox(height: 24),

          // Support Section
          _buildSectionTitle('Support'),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact us',
            onTap: _showHelpSupportDialog,
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version 1.0.0',
            onTap: _showAboutDialog,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade600),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}