import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../myconfig.dart';

class AdoptionScreen extends StatefulWidget {
  final User user;

  const AdoptionScreen({super.key, required this.user});

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  List<dynamic> adoptionList = [];
  String status = "Loading...";
  late double screenHeight, screenWidth;
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    loadMyAdoptions();
  }

  Future<void> loadMyAdoptions() async {
    String url = "${MyConfig.servername}/load_my_adoptions.php?userid=${widget.user.userId}";
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == "success") {
        // Check if the data list is empty
        if (data['data'] != null && data['data'] is List && data['data'].isNotEmpty) {
          setState(() {
            adoptionList = data['data'];
            status = "";
          });
        } else {
          // Empty list - show "No history found" message
          setState(() {
            adoptionList = [];
            status = "No adoption history found.";
          });
        }
      } else {
        setState(() {
          adoptionList = [];
          status = "No adoption history found.";
        });
      }
    } else {
      setState(() {
        status = "Error loading data.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Adoption Applications"),
        backgroundColor: Colors.amber,
      ),
      body: adoptionList.isEmpty
          ? Center(child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))
          : ListView.builder(
              itemCount: adoptionList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pet Image
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: adoptionList[index]['pet_image'] != null &&
                                    adoptionList[index]['pet_image'].toString().isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: "${MyConfig.servername}/uploads/${adoptionList[index]['pet_image']}",
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.pets, size: 40, color: Colors.grey),
                                  )
                                : const Icon(Icons.pets, size: 40, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 10),
                        
                        // Adoption Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                adoptionList[index]['pet_name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text("Status: ${adoptionList[index]['status']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  color: getStatusColor(adoptionList[index]['status'])
                                )
                              ),
                              const SizedBox(height: 4),
                              Text("Date: ${df.format(DateTime.parse(adoptionList[index]['request_date']))}",
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text("Message: ${adoptionList[index]['motivation_message']}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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
    );
  }

  Color getStatusColor(String status) {
    if (status == "Pending") return Colors.orange;
    if (status == "Approved") return Colors.green;
    if (status == "Rejected") return Colors.red;
    return Colors.black;
  }
}