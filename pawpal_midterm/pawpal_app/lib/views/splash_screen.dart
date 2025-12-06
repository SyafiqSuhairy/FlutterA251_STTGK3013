import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../myconfig.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // execute auto login immediately
    autoLogin();
  }

  void autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');
    bool remember = prefs.getBool('remember') ?? false;

    // Check if "Remember Me" is true and we have stored data
    if (remember && email != null && password != null) {
      try {
        final response = await http.post(
          Uri.parse("${MyConfig.baseUrl}/pawpal_api/login_user.php"),
          body: {"email": email, "password": password},
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['success']) {
            // Login Success: Create User object
            User user = User.fromJson(data['data'][0]);
            
            if (!mounted) return;
            Timer(const Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (content) => MainScreen(user: user)),
              );
            });
            return; 
          }
        }
      } catch (e) {
        // If internet is down or server error, we fail silently and go to Login
        print("Auto login failed: $e");
      }
    }

    // If no stored data, or login failed, go to Login Screen after 3 seconds
    if (!mounted) return;
    Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (content) => const LoginScreen()),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pawpal.png', 
              scale: 3,
              errorBuilder: (context, error, stackTrace) {
                // Shows a paw icon if the image file is missing
                return const Icon(Icons.pets, size: 80, color: Colors.orange);
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "PawPal",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.orange),
            const SizedBox(height: 10),
            const Text("Loading..."),
          ],
        ),
      ),
    );
  }
}