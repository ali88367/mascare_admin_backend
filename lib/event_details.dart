import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mascare_admin_backend/colors.dart';

class EventDetails extends StatelessWidget {
  final DocumentSnapshot event;

  const EventDetails({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title = event['title'] ?? "No Title";
    String date = event['date'] ?? "No Date";
    String description = event['description'] ?? "No Description";
    String imageUrl = event['image_url'] ?? "";
    String organizer = event['organizer'] ?? "No Organizer";
    String fromTime = event['from_time'] ?? "No From Time";
    String toTime = event['to_time'] ?? "No To Time";
    String ticketPrice = event['ticket_price'] ?? "No Ticket Price";
    String contactNumber = event['contact_number'] ?? "No Contact Number";
    String address = event['address'] ?? "No Address";

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: orange)),
        backgroundColor:darkBlue,
        iconTheme: const IconThemeData(color: orange),
      ),
      body: Center( // Center the content
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
              children: [
                // Event Image
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/images/logo.png",
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          : Image.asset(
                        "assets/images/logo.png",
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildReadOnlyInputField("Title", title),
                const SizedBox(height: 16),

                _buildReadOnlyInputField("Description", description, maxLines: 3),
                const SizedBox(height: 16),

                _buildReadOnlyInputField("Organizer", organizer),
                const SizedBox(height: 16),

                _buildReadOnlyInputField("Date", date),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildReadOnlyInputField("From Time", fromTime),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildReadOnlyInputField("To Time", toTime),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildReadOnlyInputField("Ticket Price", ticketPrice),
                const SizedBox(height: 16),

                _buildReadOnlyInputField("Contact Number", contactNumber),
                const SizedBox(height: 16),

                _buildReadOnlyInputField("Address", address, maxLines: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyInputField(String label, String value, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1), //Optional, adds a slight background color
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: true, // Make it read-only
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: orange),
          border: InputBorder.none, // Remove the border
          contentPadding: const EdgeInsets.all(16), // Add some padding inside the box
        ),
      ),
    );
  }
}