import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../myconfig.dart';

class DonationHistoryScreen extends StatefulWidget {
  final User user;

  const DonationHistoryScreen({super.key, required this.user});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  List<dynamic> donationList = [];
  String status = "Loading...";
  late double screenHeight, screenWidth;
  final df = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    loadDonations();
  }

  Future<void> loadDonations() async {
    String url = "${MyConfig.servername}/load_donations.php?userid=${widget.user.userId}";
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status'] == "success") {
        // Check if the data list is empty
        if (data['data'] != null && data['data'] is List && data['data'].isNotEmpty) {
          setState(() {
            donationList = data['data'];
            status = "";
          });
        } else {
          // Empty list - show "No history found" message
          setState(() {
            donationList = [];
            status = "No donation history found.";
          });
        }
      } else {
        setState(() {
          donationList = [];
          status = "No donation history found.";
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
        title: const Text("My Donations"),
        backgroundColor: Colors.amber,
      ),
      body: donationList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volunteer_activism, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    status,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadDonations,
              child: ListView.builder(
                itemCount: donationList.length,
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
                              child: donationList[index]['pet_image'] != null &&
                                      donationList[index]['pet_image'].toString().isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          "${MyConfig.servername}/uploads/${donationList[index]['pet_image']}",
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.pets,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : const Icon(Icons.pets, size: 40, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Donation Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donationList[index]['pet_name'] ?? 'Unknown Pet',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Type: ${donationList[index]['donation_type']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                // Show Amount for Money donations
                                if (donationList[index]['donation_type'] == 'Money')
                                  Text(
                                    "Amount: RM ${double.parse(donationList[index]['amount'] ?? '0').toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.green),
                                  ),
                                // Show Description for Food/Medical donations
                                if (donationList[index]['donation_type'] != 'Money' &&
                                    donationList[index]['description'] != null &&
                                    donationList[index]['description'].toString().isNotEmpty)
                                  Text(
                                    "Description: ${donationList[index]['description']}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  "Date: ${df.format(DateTime.parse(donationList[index]['donation_date']))}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    );
  }
}
