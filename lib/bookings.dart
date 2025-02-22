import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class Bookings extends StatelessWidget {
  const Bookings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text('Bookings'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings') // Change collection name if needed
            .doc('lrlQAWh0IeSRTEwoO5KXQD4ehBD3') // Replace with actual document ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No booking found."));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Service: ${data['about_service'] ?? 'N/A'}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Amount: ${data['amount'] ?? 'N/A'}"),
                  Text("Company Registration: ${data['company_registration'] ?? 'N/A'}"),
                  Text("From Date: ${data['from_date'] ?? 'N/A'}"),
                  Text("From Time: ${data['from_time'] ?? 'N/A'}"),
                  Text("To Date: ${data['to_date'] ?? 'N/A'}"),
                  Text("To Time: ${data['to_time'] ?? 'N/A'}"),
                  Text("Full Time Care: ${data['full_time_care'] == true ? 'Yes' : 'No'}"),
                  Text("Status: ${data['status'] ?? 'N/A'}"),
                  Text("Status Time: ${data['statusTime'].toDate()}"),
                  Text("Note: ${data['note'] ?? 'N/A'}"),
                  Text("Note to Parents: ${data['note_to_parents'] ?? 'N/A'}"),
                  const SizedBox(height: 20),
                  Text("Services:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...List.generate(data['mentioned_services']?.length ?? 0, (index) {
                    var service = data['mentioned_services'][index];
                    return ListTile(
                      leading: Image.asset(service['thumbnail'], width: 50, height: 50),
                      title: Text(service['name']),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
