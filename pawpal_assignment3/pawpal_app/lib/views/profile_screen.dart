import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../myconfig.dart';
import 'edit_profile.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Image
              currentUser.profileImage != null && currentUser.profileImage!.isNotEmpty
                  ? CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: NetworkImage(
                          "${MyConfig.servername}/uploads/${currentUser.profileImage}"),
                      onBackgroundImageError: (exception, stackTrace) {
                        // Image failed to load, will show child icon
                      },
                      child: const Icon(Icons.person, size: 60, color: Colors.grey),
                    )
                  : CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 60, color: Colors.grey),
                    ),
              const SizedBox(height: 20),

              // User Info Card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow("Name", currentUser.name ?? "Not set"),
                      const Divider(),
                      _buildInfoRow("Email", currentUser.email ?? "Not set"),
                      const Divider(),
                      _buildInfoRow("Phone", currentUser.phone ?? "Not set"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to edit profile and wait for result
                    final updatedUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: currentUser),
                      ),
                    );

                    // If user was updated, refresh the screen
                    if (updatedUser != null && updatedUser is User) {
                      setState(() {
                        currentUser = updatedUser;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showLogoutDialog();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Clear SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigate to login screen and remove all previous routes
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (content) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
