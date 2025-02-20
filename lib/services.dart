import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text("Services")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No services available"));
          }

          var services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              var data = services[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Thumbnail
                      if (data['thumbnail'] != null)
                        Center(
                          child: Image.network(
                            data['thumbnail'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 10),

                      // Service Name
                      Text("Service: ${data['name'] ?? 'No Name'}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                      // About Service
                      Text("About: ${data['about_service'] ?? 'N/A'}"),

                      // Note to Parents
                      Text("Note: ${data['note_to_parents'] ?? 'N/A'}"),

                      // Price per Hour
                      Text("Price per Hour: \$${data['price_per_hour'] ?? 'N/A'}"),

                      // Service Provider
                      Text("Service Provider: ${data['service_provider'] ?? 'N/A'}"),

                      // Company Registration
                      Text("Company Registration: ${data['company_registration'] ?? 'N/A'}"),

                      // Dates and Times
                      Text("From: ${data['from_date'] ?? 'N/A'} ${data['from_time'] ?? ''}"),
                      Text("To: ${data['to_date'] ?? 'N/A'} ${data['to_time'] ?? ''}"),

                      const SizedBox(height: 8),

                      // Full-time care (array)
                      if (data['full_time_care'] != null && data['full_time_care'] is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Full-time Care:", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(
                              data['full_time_care'].length,
                                  (i) => Text("- ${data['full_time_care'][i]}"),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Mentioned Services (array)
                      if (data['mentioned_services'] != null && data['mentioned_services'] is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Mentioned Services:", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(
                              data['mentioned_services'].length,
                                  (i) => Text("- ${data['mentioned_services'][i]}"),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Customers (array)
                      if (data['customers'] != null && data['customers'] is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Customers:", style: TextStyle(fontWeight: FontWeight.bold)),
                            ...List.generate(
                              data['customers'].length,
                                  (i) => Text("- ${data['customers'][i]}"),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
