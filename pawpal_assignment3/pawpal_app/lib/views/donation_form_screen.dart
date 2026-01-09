import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/pet.dart';
import '../myconfig.dart';

class DonationFormScreen extends StatefulWidget {
  final User user;
  final Pet pet;

  const DonationFormScreen({super.key, required this.user, required this.pet});

  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedDonationType = "Money";
  late double screenHeight, screenWidth;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Make a Donation"),
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
                  "Donate to ${widget.pet.petName}",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  "Pet ID: ${widget.pet.petId}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Divider(height: 30),

                // 2. Donation Type Dropdown
                const Text(
                  "Donation Type",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedDonationType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: const [
                    DropdownMenuItem(value: "Money", child: Text("Money")),
                    DropdownMenuItem(value: "Food", child: Text("Food")),
                    DropdownMenuItem(value: "Medical", child: Text("Medical")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDonationType = value!;
                      // Clear fields when type changes
                      _amountController.clear();
                      _descriptionController.clear();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a donation type';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 3. Conditional Fields based on Donation Type
                if (_selectedDonationType == "Money")
                  // Amount Field for Money
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Amount (RM)",
                      hintText: "Enter donation amount",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the donation amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Amount must be greater than 0';
                      }
                      return null;
                    },
                  )
                else
                  // Description Field for Food/Medical
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: "Describe the ${_selectedDonationType.toLowerCase()} donation (e.g., type, quantity, brand, etc.)",
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a description for ${_selectedDonationType.toLowerCase()} donation';
                          }
                          if (value.length < 10) {
                            return 'Please provide more details (at least 10 characters)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 30),

                // 4. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      submitDonation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text(
                      "Submit Donation",
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

  void submitDonation() {
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

    // Prepare request body
    Map<String, String> body = {
      "user_id": widget.user.userId!,
      "pet_id": widget.pet.petId!,
      "donation_type": _selectedDonationType,
    };

    if (_selectedDonationType == "Money") {
      body["amount"] = _amountController.text.trim();
      body["description"] = ""; // Empty for money donations
    } else {
      body["amount"] = "0.00"; // Zero for non-money donations
      body["description"] = _descriptionController.text.trim();
    }

    http.post(
      Uri.parse("${MyConfig.servername}/insert_donation.php"),
      body: body,
    ).then((response) {
      Navigator.of(context).pop(); // Close progress dialog

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Donation Submitted Successfully!"),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop(); // Go back to details screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(data['message'] ?? "Failed to submit donation"),
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
