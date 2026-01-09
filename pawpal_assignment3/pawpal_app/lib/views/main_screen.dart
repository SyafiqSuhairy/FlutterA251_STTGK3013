import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../myconfig.dart';
import '../models/user.dart';
import '../models/pet.dart';
import 'submit_pet_screen.dart';
import 'details_screen.dart';
import 'login_screen.dart';
import 'adoption_screen.dart';
import 'donation_history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Pet> petList = [];
  List<Pet> filteredPetList = [];
  bool isLoading = true;
  String statusMessage = "Loading data...";
  
  // Search and Filter Controllers
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = "All";
  final List<String> _petTypes = ["All", "Cat", "Dog", "Other"];

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadPets() async {
    setState(() {
      isLoading = true;
      statusMessage = "Loading...";
    });

    try {
      // Build URL with search and filter parameters
      String url = "${MyConfig.servername}/load_all_pets.php";
      
      // Add search parameter if not empty
      if (_searchController.text.isNotEmpty) {
        url += "&search=${Uri.encodeComponent(_searchController.text)}";
      }
      
      // Add type filter if not "All"
      if (_selectedType != "All") {
        url += "&type=${Uri.encodeComponent(_selectedType)}";
      }
      
      // Replace first & with ? if no search was added
      if (!url.contains("?")) {
        url = url.replaceFirst("&", "?");
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          petList.clear();
          filteredPetList.clear();
          
          if (data['data'] != null && data['data'] is List) {
            for (var item in data['data']) {
              try {
                petList.add(Pet.fromJson(item));
              } catch (e) {
                // Skip invalid items
              }
            }
          }
          
          // Apply local filtering (in case we need additional client-side filtering)
          _applyFilters();
          
          setState(() {
            statusMessage = filteredPetList.isEmpty ? "No pets found." : "";
          });
        } else {
          setState(() {
            statusMessage = "No pets found.";
            petList.clear();
            filteredPetList.clear();
          });
        }
      } else {
        setState(() {
          statusMessage = "Server Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Error connecting to server.";
      });
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    // Server-side filtering is already done, but we can add client-side filtering here if needed
    filteredPetList = List.from(petList);
  }

  void _onSearchChanged(String value) {
    // Debounce: reload after user stops typing for 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == value) {
        loadPets();
      }
    });
  }

  void _onTypeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedType = newValue;
      });
      loadPets();
    }
  }

  void _logout() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PawPal - Public Feed"),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: loadPets,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.amber,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: widget.user.profileImage != null &&
                            widget.user.profileImage!.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  "${MyConfig.servername}/uploads/${widget.user.profileImage}",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person, size: 30),
                            ),
                          )
                        : const Icon(Icons.person, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.name ?? "User",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.user.email ?? "",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home / Public Feed"),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text("My Adoption History"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdoptionScreen(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text("My Donation History"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DonationHistoryScreen(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("My Profile"),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: widget.user),
                  ),
                );
                // If user was updated, we could refresh here if needed
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search pets by name...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              loadPets();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                // Filter Dropdown
                Row(
                  children: [
                    const Text(
                      "Filter by Type: ",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _petTypes.map((String type) {
                            return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: _onTypeChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Grid View Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadPets,
              color: Colors.amber,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : filteredPetList.isEmpty && statusMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.pets, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                statusMessage,
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(10.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredPetList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailsScreen(
                                          pet: filteredPetList[index],
                                          user: widget.user,
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Pet Image with "Needs Help" Badge
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              color: Colors.grey[200],
                                              child: (filteredPetList[index].imagePaths != null &&
                                                      filteredPetList[index].imagePaths!.isNotEmpty)
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          "${MyConfig.servername}/uploads/${filteredPetList[index].imagePaths![0]}",
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) =>
                                                          const Center(
                                                            child: CircularProgressIndicator(),
                                                          ),
                                                      errorWidget: (context, url, error) =>
                                                          const Center(
                                                            child: Icon(Icons.pets,
                                                                size: 40, color: Colors.grey),
                                                          ),
                                                    )
                                                  : const Center(
                                                      child: Icon(Icons.pets,
                                                          size: 40, color: Colors.grey),
                                                    ),
                                            ),
                                          ),
                                          // "Needs Help" Badge
                                          if (filteredPetList[index].needsDonation == "1" ||
                                              filteredPetList[index].needsDonation == 1)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  "Needs Help",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Pet Info
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            filteredPetList[index].petName ?? "Unknown",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                filteredPetList[index].petType ?? "",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber[100],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  filteredPetList[index].category ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.deepOrange,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (content) => SubmitPetScreen(user: widget.user),
            ),
          );
          loadPets(); // Refresh after returning
        },
        backgroundColor: Colors.amber,
        icon: const Icon(Icons.add),
        label: const Text("Add Pet"),
      ),
    );
  }
}
