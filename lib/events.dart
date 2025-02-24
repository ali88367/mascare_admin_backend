import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'event_details.dart';

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('events').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading events"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No events available"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var event = snapshot.data!.docs[index];
                  String title = event['title'] ?? "No Title";
                  String date = event['date'] ?? "No Date";
                  String image_url = event['image_url'] ?? "";
                  debugPrint("Fetched image URL: $image_url");


                  // Convert date string to a readable format
                  String formattedDate;
                  try {
                    DateTime parsedDate = DateTime.parse(date);
                    formattedDate = DateFormat.yMMMMd().format(parsedDate);
                  } catch (e) {
                    formattedDate = date;
                  }

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => EventDetails(event: event));
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image_url.isNotEmpty
                              ? Image.network(
                            image_url,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                width: 60,
                                height: 60,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint("Error loading image: $error"); // Debugging
                              return Image.asset(
                                "assets/images/logo.png",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset(
                            "assets/images/logo.png",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),

                        title: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          formattedDate,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
