import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
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
                color: darkBlue,
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: orange)),

                      // About Service
                      Text("About: ${data['about_service'] ?? 'N/A'}",style: TextStyle(color: whiteColor),),

                      // Note to Parents
                      Text("Note: ${data['note_to_parents'] ?? 'N/A'}",style: TextStyle(color: whiteColor)),

                      // Price per Hour
                      Text("Price per Hour: \$${data['price_per_hour'] ?? 'N/A'}",style: TextStyle(color: whiteColor)),

                      // Service Provider
                      Text("Service Provider: ${data['service_provider'] ?? 'N/A'}",style: TextStyle(color: whiteColor)),

                      // Company Registration
                      Text("Company Registration: ${data['company_registration'] ?? 'N/A'}",style: TextStyle(color: whiteColor)),

                      // Dates and Times
                      Text("From: ${data['from_date'] ?? 'N/A'} ${data['from_time'] ?? ''}",style: TextStyle(color: whiteColor)),
                      Text("To: ${data['to_date'] ?? 'N/A'} ${data['to_time'] ?? ''}",style: TextStyle(color: whiteColor)),

                      const SizedBox(height: 8),

                      // Full-time care (array)
                      if (data['full_time_care'] != null && data['full_time_care'] is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Full-time Care:", style: TextStyle(fontWeight: FontWeight.bold,color: whiteColor)),
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
                            const Text("Mentioned Services:", style: TextStyle(fontWeight: FontWeight.bold,color: orange)),
                            ...List.generate(
                              data['mentioned_services'].length,
                                  (i) => Text("- ${data['mentioned_services'][i]}",style: TextStyle(color: whiteColor),),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),

                      // Customers (array)
                      if (data['customers'] != null && data['customers'] is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Customers:", style: TextStyle(fontWeight: FontWeight.bold,color: orange)),
                            ...List.generate(
                              data['customers'].length,
                                  (i) => Text("- ${data['customers'][i]}",style: TextStyle(color: whiteColor),),
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
