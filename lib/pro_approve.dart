import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:mascare_admin_backend/SideBar/sidebar_controller.dart';

class ProApprove extends StatefulWidget {
  const ProApprove({Key? key}) : super(key: key);

  @override
  State<ProApprove> createState() => _ProApproveState();
}

class _ProApproveState extends State<ProApprove> {
  final SidebarController sidebarController = Get.find<SidebarController>();

  /// **Approve Professional: Show SnackBar and remove user from UI**
  Future<void> _approveProfessional(String uid, String docId, BuildContext context) async {
    try {
      // Update the account_approved field in the all_users collection
      await FirebaseFirestore.instance.collection('all_users').doc(uid).update({
        "account_approved": true,
      });

      // Remove the professional from the pro_requests collection
      await FirebaseFirestore.instance.collection('pro_requests').doc(docId).delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Professional approved successfully.")),
      );
    } catch (e) {
      debugPrint("Error approving professional: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error approving professional. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
                    child: Icon(Icons.menu, color: Colors.white,)))
                : const SizedBox.shrink(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('pro_requests').snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text("Error fetching data", style: TextStyle(color: Colors.white)));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No professionals found", style: TextStyle(color: Colors.white)));
                        }

                        List<Map<String, dynamic>> prosList = snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;

                          return {
                            "name": data['user_name'] ?? 'Unknown',
                            "email": data['email'] ?? 'N/A',
                            "phone": data['number'] ?? 'N/A',
                            "experience": "${data['years_of_experience'] ?? '0'} years",
                            "profile_pic": data['profile_pic'] ?? '',
                            "address": data['address'] ?? 'N/A',
                            "care_center_name": data['care_center_name'] ?? 'N/A',
                            "category": data['category'] ?? 'N/A',
                            "registration_number": data['registration_number'] ?? 'N/A',
                            "role": data['role'] ?? 'N/A',
                            "uid": data['uid'] ?? 'N/A',
                            "docId": doc.id,
                          };
                        }).toList();

                        return ListView.builder(
                          itemCount: prosList.length,
                          itemBuilder: (context, index) {
                            return _buildProCard(prosList[index], context);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProCard(Map<String, dynamic> proDetails, BuildContext context) {
    // New Color Scheme
    const Color cardBackgroundColor = Colors.white; // White
    const Color detailIconColor = orange;           // Orange
    const Color detailTextColor = darkBlue;          // Dark Blue

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: cardBackgroundColor, // White Card Background
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
                  backgroundImage: proDetails['profile_pic'].isNotEmpty
                      ? NetworkImage(proDetails['profile_pic'])
                      : null,
                  backgroundColor: detailIconColor, // Orange Circle Avatar
                  child: proDetails['profile_pic'].isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    proDetails['name'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: detailTextColor), // Dark Blue Text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildDetailRow(Icons.email, "Email", proDetails['email'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.phone, "Phone", proDetails['phone'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.work, "Experience", proDetails['experience'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.location_on, "Address", proDetails['address'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.business, "Care Center", proDetails['care_center_name'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.category, "Category", proDetails['category'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.confirmation_number, "Registration No.", proDetails['registration_number'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.person, "Role", proDetails['role'], iconColor: detailIconColor, textColor: detailTextColor),
            _buildDetailRow(Icons.perm_identity, "UID", proDetails['uid'], iconColor: detailIconColor, textColor: detailTextColor),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _approveProfessional(proDetails['uid'], proDetails['docId'], context),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Approve", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _rejectProfessional(proDetails, proDetails['docId'], context),
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text("Reject", style: TextStyle(color: Colors.white)),
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

  Widget _buildDetailRow(IconData icon, String label, String value, {required Color iconColor, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24), // Use specified icon color
          const SizedBox(width: 10),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)), // Use specified text color
          Expanded(child: Text(value, style: TextStyle(fontSize: 16, color: textColor))), // Use specified text color
        ],
      ),
    );
  }

  /// **Reject Professional: Move to rejected_pros collection and delete from pro_requests**
  Future<void> _rejectProfessional(Map<String, dynamic> proDetails, String docId, BuildContext context) async {
    TextEditingController reasonController = TextEditingController();

    // Show a dialog to enter the rejection reason
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reject Professional"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: "Enter reason for rejection"),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please provide a rejection reason.")),
                  );
                  return;
                }

                Navigator.pop(context); // Close the dialog

                try {
                  // Save rejected professional details
                  await FirebaseFirestore.instance.collection('rejected_pros').doc(proDetails['uid']).set({
                    "name": proDetails['name'],
                    "email": proDetails['email'],
                    "phone": proDetails['phone'],
                    "experience": proDetails['experience'],
                    "profile_pic": proDetails['profile_pic'],
                    "address": proDetails['address'],
                    "care_center_name": proDetails['care_center_name'],
                    "category": proDetails['category'],
                    "registration_number": proDetails['registration_number'],
                    "role": proDetails['role'],
                    "uid": proDetails['uid'],
                    "rejected_at": FieldValue.serverTimestamp(), // Timestamp for record keeping
                    "disapprove_reason": reason, // Store the rejection reason
                  });

                  // Update the all_users collection with the rejection reason
                  await FirebaseFirestore.instance.collection('all_users').doc(proDetails['uid']).update({
                    "account_approved": false,
                    "disapprove_reason": reason,
                  });

                  // Delete from pro_requests collection
                  await FirebaseFirestore.instance.collection('pro_requests').doc(docId).delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Professional rejected successfully.")),
                  );
                } catch (e) {
                  debugPrint("Error rejecting professional: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error rejecting professional. Please try again.")),
                  );
                }
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }
}