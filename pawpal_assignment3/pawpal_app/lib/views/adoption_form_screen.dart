import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/pet.dart';
import '../myconfig.dart';

class AdoptionFormScreen extends StatefulWidget {
  final User user;
  final Pet pet;

  const AdoptionFormScreen({super.key, required this.user, required this.pet});

  @override
  State<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _messageController = TextEditingController();
  late double screenHeight, screenWidth;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adoption Request"),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Info
                Text(
                  "Adopt ${widget.pet.petName}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Pet ID: ${widget.pet.petId}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Divider(height: 30),

                // 2. Motivation Text Field
                const Text(
                  "Why do you want to adopt this pet?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _messageController,
                  keyboardType: TextInputType.multiline,
                  minLines: 3,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: "Tell us about your home environment and experience with pets...",
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a motivation message';
                    }
                    if (value.length < 10) {
                      return 'Please write at least 10 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // 3. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      submitAdoption();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text(
                      "Submit Application",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitAdoption() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    String message = _messageController.text;

    http.post(
      Uri.parse("${MyConfig.servername}/insert_adoption.php"),
      body: {
        "user_id": widget.user.userId!,
        "pet_id": widget.pet.petId!,
        "motivation_message": message,
      },
    ).then((response) {
      Navigator.of(context).pop(); // Close progress dialog

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Adoption Request Sent Successfully!"),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop(); // Go back to details screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to send request"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Server Error"),
          backgroundColor: Colors.red,
        ));
      }
    }).catchError((error) {
      Navigator.of(context).pop(); // Close progress dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $error"),
        backgroundColor: Colors.red,
      ));
    });
  }
}