import 'package:flutter/material.dart';
import '../models/user.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PawPal Home"),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate back to Login and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (content) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome,",
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              // Display the user's name, or "User" if null
              widget.user.name ?? "User",
              style: const TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: Colors.orange
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Pet Adoption Journey Starts Here!",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}