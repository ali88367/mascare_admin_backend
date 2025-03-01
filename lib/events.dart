import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'SideBar/sidebar_controller.dart';
import 'add_event.dart';
import 'event_details.dart';

class Events extends StatefulWidget {
  const Events({Key? key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final SidebarController sidebarController = Get.find<SidebarController>();

  // Method to navigate to the AddEvent screen with pre-filled data
  void _navigateToEditEvent(DocumentSnapshot event) {
    Get.to(() => AddEvent(eventData: event.data() as Map<String, dynamic>, eventId: event.id));
  }


  void _deleteEvent(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Event"),
          content: const Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(eventId)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      backgroundColor: darkBlue,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width < 768 ? 20 : 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Get.width < 768
                ? GestureDetector(
                onTap: () {
                  sidebarController.showsidebar.value = true;

                },
                child: const Padding(
                    padding: EdgeInsets.only(left: 10, top: 10),
                    child: Icon(Icons.menu, color: Colors.white,))) // Ensure the icon is visible
                : const SizedBox.shrink(),

            Expanded( // Use Expanded to make the rest of the content fill the space
              child: Center(
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

                          // Use a static test URL if the fetched URL is empty or causes an error
                          const String testImageUrl =
                              "https://via.placeholder.com/150"; // Placeholder image
                          image_url = image_url.isNotEmpty ? image_url : testImageUrl;

                          debugPrint("Using image URL: $image_url");

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
                                  child: Image.network(
                                    image_url,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 60,
                                        height: 60,
                                        child: const Center(
                                            child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint("Error loading image: $error");
                                      return Image.asset(
                                        "assets/images/logo.png",
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      );
                                    },
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _navigateToEditEvent(event), // Navigate to AddEvent screen
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteEvent(context, event.id),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}