import 'dart:convert';
import 'dart:developer'; 

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../myconfig.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late double height, width;
  bool visible = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    
    if (width > 400) {
      width = 400;
    } else {
      width = width;
    }
    
    return Scaffold(
      appBar: AppBar(title: const Text('Register Page')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/pawpal.png', 
                      scale: 3, 
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.pets, size: 100, color: Colors.orange),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),  
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                        icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            visible = !visible;
                          });
                        },
                        icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        registerDialog();
                      },
                      child: const Text('Register'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text('Already have an account? Login here'),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void registerDialog() {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || name.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Passwords do not match'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password must be at least 6 characters'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    // Basic email regex
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid email address'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register this account?'),
        content: const Text('Are you sure you want to register this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              registerUser(email, password, name, phone);
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void registerUser(String email, String password, String name, String phone) async {
    setState(() {
      isLoading = true;
    });
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(width: 20),
              Text('Registering...'),
            ],
          ),
        );
      },
    );

    try {
      await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal_api/register_user.php'),
        body: {
          'email': email, 
          'name': name,
          'phone': phone,
          'password': password
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var jsonResponse = response.body;
          var resarray = jsonDecode(jsonResponse);
          log(jsonResponse); // Debug print
          
          if (resarray['success'] == true) {
            if (!mounted) return;

            if (isLoading) {
              Navigator.pop(context); 
            }
            setState(() {
              isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Registration successful'),
              backgroundColor: Colors.green,
            ));
            
            // Go back to Login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            if (!mounted) return;

            if (isLoading) {
              Navigator.pop(context);
              setState(() { isLoading = false; });
            }
            
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(resarray['message']),
              backgroundColor: Colors.red,
            ));
          }
        } else {
          if (!mounted) return;
          if (isLoading) {
              Navigator.pop(context);
              setState(() { isLoading = false; });
          }
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Registration failed. Server Error.'),
            backgroundColor: Colors.red,
          ));
        }
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (!mounted) return;
          if (isLoading) {
              Navigator.pop(context);
              setState(() { isLoading = false; });
          }
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Request timed out. Please try again.'),
            backgroundColor: Colors.red,
          ));
        },
      );
    } catch (e) {
      if (!mounted) return;
      if (isLoading) {
          Navigator.pop(context);
          setState(() { isLoading = false; });
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error connecting to server.'),
        backgroundColor: Colors.red,
      ));
    }
  }
}