import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../myconfig.dart';
import '../models/user.dart';
import '../models/pet.dart';
import 'submit_pet_screen.dart';
import 'details_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Pet> petList = [];
  bool isLoading = true;
  String statusMessage = "Loading data...";

  @override
  void initState() {
    super.initState();
    loadPets();
  }


  Future<void> loadPets() async {
    setState(() {
      isLoading = true;
      statusMessage = "Loading...";
    });

    try {
      final url = "${MyConfig.baseUrl}/pawpal_api/get_my_pet.php?userid=${widget.user.userId}";
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          petList.clear();
          
          if (data['data'] != null && data['data'] is List) {
            for (var item in data['data']) {
              try {
                petList.add(Pet.fromJson(item));
              } catch (e) {
                // Skip invalid items silently or log to a real error service
              }
            }
          }
          
          setState(() {
            statusMessage = petList.isEmpty ? "No pets found." : "";
          });
        } else {
          setState(() {
            statusMessage = "No pets found.";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PawPal Dashboard"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadPets, 
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Data",
          ),
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (content) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  widget.user.name ?? "User", 
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.orange
                  ),
                ),
              ],
            ),
          ),

          // Grid View Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: loadPets,
              color: Colors.orange,
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                  : petList.isEmpty && statusMessage.isNotEmpty
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
                              const SizedBox(height: 8),
                              Text(
                                "Debug: petList.length = ${petList.length}",
                                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      // +1 to make spaces for "Add Button" Section
                      itemCount: petList.length + 1,
                      itemBuilder: (context, index) {
                        
                        // 1) Add New Submission Button Section
                        if (index == petList.length) {
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (content) => SubmitPetScreen(user: widget.user))
                              );
                              loadPets(); 
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.orange, width: 2, style: BorderStyle.solid),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle, size: 50, color: Colors.orange),
                                  SizedBox(height: 8),
                                  Text("New Submission", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                                ],
                              ),
                            ),
                          );
                        }

                        // 2) Existed Pet Cards Section
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => DetailsScreen(pet: petList[index]))
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // a) Added Main Image
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: (petList[index].imagePaths != null && petList[index].imagePaths!.isNotEmpty)
                                          ? Image.network(
                                              "${MyConfig.baseUrl}/pawpal_api/uploads/${petList[index].imagePaths![0]}",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(child: Icon(Icons.pets, size: 40, color: Colors.grey));
                                              },
                                            )
                                          : const Center(child: Icon(Icons.pets, size: 40, color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                // b) Added Text Info
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        petList[index].petName ?? "Unknown", 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1, 
                                        overflow: TextOverflow.ellipsis
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            petList[index].petType ?? "", 
                                            style: const TextStyle(fontSize: 12, color: Colors.grey)
                                          ),
                                          // 3) Added Category Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius: BorderRadius.circular(4)
                                            ),
                                            child: Text(
                                              petList[index].category ?? "",
                                              style: const TextStyle(fontSize: 10, color: Colors.deepOrange),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
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
    );
  }
}