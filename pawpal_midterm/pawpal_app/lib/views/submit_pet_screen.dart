import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../myconfig.dart';
import '../models/user.dart';

class SubmitPetScreen extends StatefulWidget {
  final User user; 
  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  String _selectedType = 'Cat';
  String _selectedCategory = 'Adoption';
  String _lat = "";
  String _lng = "";
  List<File> _images = []; 

  final List<String> _petTypes = ['Cat', 'Dog', 'Rabbit', 'Other'];
  final List<String> _categories = ['Adoption', 'Donation Request', 'Help/Rescue'];

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Automatically get the location
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Pet Submission"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1) Multi-Image Picker Inputs
            GestureDetector(
              onTap: _images.length < 3 ? _showImagePickerModal : null,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _images.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Tap to add images (Max 3)", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                // Show Image Preview
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _images[index], 
                                    height: 160, 
                                    width: 160, 
                                    fit: BoxFit.cover
                                  ),
                                ),
                                // Have a Delete Option
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      color: Colors.white.withOpacity(0.7),
                                      child: const Icon(Icons.cancel, color: Colors.red),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Text("${_images.length}/3 Images Selected", style: const TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 20),

            // 2) Pet Details Form Inputs
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Pet Name", 
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets)
              ),
            ),
            const SizedBox(height: 15),
            
            DropdownButtonFormField(
              value: _selectedType,
              decoration: const InputDecoration(labelText: "Pet Type", border: OutlineInputBorder()),
              items: _petTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
              items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description (min 10 chars)", 
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 15),

            // 3) Location Display & Refresh Features
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _lat.isEmpty 
                      ? const Text("Detecting Location...", style: TextStyle(fontStyle: FontStyle.italic))
                      : Text(
                          "Lat: $_lat\nLng: $_lng", 
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.orange), 
                    onPressed: _determinePosition
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 4) Confirmation Submit Button 
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: _submitPet,
                child: const Text("Submit Pet", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LOGIC 1: GEOLOCATOR 
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    // Get current position
    Position position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _lat = position.latitude.toString();
      _lng = position.longitude.toString();
    });
  }

  // LOGIC 2: IMAGE PICKER MODAL
  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _iconBtn(Icons.camera_alt, "Camera", ImageSource.camera),
            _iconBtn(Icons.image, "Gallery", ImageSource.gallery),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context); 
        final XFile? picked = await ImagePicker().pickImage(source: source);
        if (picked != null) {
          setState(() {
            _images.add(File(picked.path));
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 50, color: Colors.orange), Text(label)]
      ),
    );
  }

  // LOGIC 3: SUBMIT TO PHP
  void _submitPet() async { 
    // 1) Validation for Each Input Field
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a pet name")));
      return;
    }
    if (_descController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Description must be at least 10 characters")));
      return;
    }
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least 1 image")));
      return;
    }
    if (_lat.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Waiting for GPS location...")));
      return;
    }

    // 2. Prepare Data to Send
    Map<String, String> body = {
      'userid': widget.user.userId.toString(),
      'pet_name': _nameController.text,
      'pet_type': _selectedType,
      'category': _selectedCategory,
      'description': _descController.text,
      'lat': _lat,
      'lng': _lng,
      'image_count': _images.length.toString(),
    };

    // 3. Encode Images (Loop)
    for (int i = 0; i < _images.length; i++) {
      String base64Image = base64Encode(_images[i].readAsBytesSync());
      body['image_data_$i'] = base64Image;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator(color: Colors.orange)),
      );

      var res = await http.post(
        Uri.parse("${MyConfig.baseUrl}/pawpal_api/submit_pet.php"), 
        body: body
      );

      if (mounted) Navigator.pop(context); 

      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Submission Successful!"), backgroundColor: Colors.green));
          Navigator.pop(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']), backgroundColor: Colors.red));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server Error: ${res.statusCode}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error connecting to server"), backgroundColor: Colors.red));
    }
  }
}