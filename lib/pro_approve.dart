import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';

class ProApprove extends StatelessWidget {
  const ProApprove({super.key});

  @override
  Widget build(BuildContext context) {
    // List of pros (Static data for design preview)
    List<Map<String, String>> prosList = [
      {
        "name": "John Doe",
        "email": "johndoe@example.com",
        "phone": "+1234567890",
        "experience": "5 years"
      },
      {
        "name": "Jane Smith",
        "email": "janesmith@example.com",
        "phone": "+9876543210",
        "experience": "3 years"
      },
      {
        "name": "Alice Johnson",
        "email": "alice@example.com",
        "phone": "+1122334455",
        "experience": "7 years"
      },
    ];

    return Scaffold(
      backgroundColor: darkBlue,

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700), // Max width 700px
            child: ListView.builder(
              itemCount: prosList.length,
              itemBuilder: (context, index) {
                return _buildProCard(prosList[index]);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProCard(Map<String, String> proDetails) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 15),
                Text(
                  proDetails['name']!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.email, "Email", proDetails['email']!),
            _buildDetailRow(Icons.phone, "Phone", proDetails['phone']!),
            _buildDetailRow(Icons.work, "Experience", proDetails['experience']!),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Approve"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text("Reject"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
