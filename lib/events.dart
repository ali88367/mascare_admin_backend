import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(title: const Text("Events")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Show loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading events"));
          }

          // If no events found
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No events available"));
          }

          // Display list of events
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var event = snapshot.data!.docs[index];
              String title = event['title'] ?? "No Title";
              String date = event['date'] ?? "No Date";

              // Check if 'image' field exists
            //  String? imageUrl = event.data().toString().contains('image') ? event['image'] : null;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  // leading: ClipRRect(
                  //   borderRadius: BorderRadius.circular(8), // Rounded corners
                  //   child: imageUrl != null && imageUrl.isNotEmpty
                  //       ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                  //       : Image.asset("assets/default_event.png", width: 50, height: 50, fit: BoxFit.cover), // Default image
                  // ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(date),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to event details screen or show more info
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
