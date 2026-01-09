import 'package:flutter/material.dart';
import 'views/splash_screen.dart'; // Make sure this import matches your folder structure

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPal',
      theme: ThemeData(
        primarySwatch: Colors.amber, // Matches your app's yellow theme
        useMaterial3: true,
      ),
      home: const SplashScreen(), // This tells the app to start at the Splash Screen
    );
  }
}