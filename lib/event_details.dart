import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mascare_admin_backend/colors.dart';

class EventDetails extends StatelessWidget {
  final DocumentSnapshot event;
  const EventDetails({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    String title = event['title'] ?? "No Title";
    String date = event['date'] ?? "No Date";
    String description = event['description'] ?? "No Description";
    String imageUrl =
        event['image_url'] ?? ""; // Fetch image URL from Firestore

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/logo.png",
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      "assets/images/logo.png",
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 16),

            // Event Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),


            // Event Date
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 5),
                Text(
                  date,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Event Description
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
