import 'package:flutter/material.dart';
import '../myconfig.dart';
import '../models/pet.dart';
import '../models/user.dart';
import 'adoption_form_screen.dart';
import 'donation_form_screen.dart';

class DetailsScreen extends StatefulWidget {
  final Pet pet;
  final User user;
  const DetailsScreen({super.key, required this.pet, required this.user});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late String _mainImage;

  @override
  void initState() {
    super.initState();
    if (widget.pet.imagePaths != null && widget.pet.imagePaths!.isNotEmpty) {
      _mainImage = widget.pet.imagePaths![0];
    } else {
      _mainImage = "";
    }
  }

  // Button visibility logic
  bool get _isOwner {
    return widget.user.userId.toString() == widget.pet.userId.toString();
  }

  bool get _needsDonation {
    return widget.pet.needsDonation == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) Display Main Image 
                  SizedBox(
                    height: 350,
                    width: double.infinity,
                    child: _mainImage.isNotEmpty
                        ? Image.network(
                            "${MyConfig.servername}/uploads/$_mainImage",
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
                          )
                        : const Center(child: Icon(Icons.pets, size: 100, color: Colors.grey)),
                  ),

                  // 2) Display More Than One Image
                  if (widget.pet.imagePaths != null && widget.pet.imagePaths!.length > 1)
                    Container(
                      height: 80,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      color: Colors.grey[100],
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.pet.imagePaths!.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _mainImage = widget.pet.imagePaths![index];
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                border: _mainImage == widget.pet.imagePaths![index] 
                                    ? Border.all(color: Colors.orange, width: 2) 
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  "${MyConfig.servername}/uploads/${widget.pet.imagePaths![index]}",
                                  width: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // 3) Display Pet Details
                  Container(
                    transform: Matrix4.translationValues(0.0, -20.0, 0.0), // Pull up slightly
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // a) Display Pet Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.pet.petName ?? "Unknown Name",
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                widget.pet.category ?? "General",
                                style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text("Type: ${widget.pet.petType}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        // b) Display Description
                        const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          widget.pet.description ?? "No description provided.",
                          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                        ),

                        const SizedBox(height: 25),

                        // Display Location 
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[50],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.blueGrey, size: 30),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Last Known Location", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                  Text("${widget.pet.lat}, ${widget.pet.lng}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Add bottom padding to account for the fixed bottom bar
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Persistent Bottom Navigation Bar with Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Builder(
                builder: (context) {
                  // Button visibility logic
                  bool isOwner = widget.user.userId.toString() == widget.pet.userId.toString();
                  bool needsHelp = widget.pet.needsDonation == 1;

                  if (isOwner) {
                    // Owner View: Show disabled button
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Your Pet",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else {
                    // Non-Owner View: Show action buttons
                    return Row(
                      children: [
                        // Request to Adopt Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdoptionFormScreen(
                                    user: widget.user,
                                    pet: widget.pet,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite),
                            label: const Text("Request to Adopt"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        // Spacing between buttons
                        if (needsHelp) const SizedBox(width: 12),
                        // Donate Button (only if needsHelp is true)
                        if (needsHelp)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DonationFormScreen(
                                      user: widget.user,
                                      pet: widget.pet,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.volunteer_activism),
                              label: const Text("Donate"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
