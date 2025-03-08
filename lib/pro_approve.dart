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

class _ProApproveState extends State<ProApprove> with TickerProviderStateMixin {
  final SidebarController sidebarController = Get.find<SidebarController>();
  String _selectedStatus = 'pending';
  late TabController _tabController;
  TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedStatus = 'pending';
            break;
          case 1:
            _selectedStatus = 'approved';
            break;
          case 2:
            _selectedStatus = 'rejected';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _approveProfessional(
      String uid, String docId, BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseFirestore.instance.collection('all_users').doc(uid).update({
        "account_approved": true,
      });

      var user_data = await FirebaseFirestore.instance
          .collection("all_users")
          .doc(uid)
          .get();
      var records = await FirebaseFirestore.instance
          .collection("records")
          .doc("signup_records")
          .get();

      var care_centers = records.data()?["care_centers"] ?? [];

      if (!care_centers.contains(user_data["care_center_name"])) {
        care_centers.add(user_data["care_center_name"]);

        await FirebaseFirestore.instance
            .collection("records")
            .doc("signup_records")
            .set({
          "care_centers": care_centers,
        }, SetOptions(merge: true));
      }

      await FirebaseFirestore.instance
          .collection('pro_requests')
          .doc(docId)
          .delete();

      messenger.showSnackBar(
        const SnackBar(content: Text("Professional approved successfully.")),
      );
    } catch (e) {
      debugPrint("Error approving professional: $e");
      messenger.showSnackBar(
        const SnackBar(
            content: Text("Error approving professional. Please try again.")),
      );
    }
  }



  Future<void> _rejectProfessional(Map<String, dynamic> proDetails,
      String docId, BuildContext context) async {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Reject Professional",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter reason for rejection:",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: "Type your reason here...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                String reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please provide a rejection reason.")),
                  );
                  return;
                }

                Navigator.pop(context); // Close the dialog

                try {
                  // 1. Add the pro's data to the rejected_pros collection including disapprove_reason
                  await FirebaseFirestore.instance
                      .collection('rejected_pros')
                      .doc(proDetails['uid'])
                      .set({
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
                    "rejected_at": FieldValue.serverTimestamp(),
                    "disapprove_reason": reason, //Include the reason
                  });

                  // 2. Delete the pro's request from the pro_requests collection
                  await FirebaseFirestore.instance
                      .collection('pro_requests')
                      .doc(docId)
                      .delete();

                  // 3. Update the all_users collection to reflect the rejection
                  await FirebaseFirestore.instance
                      .collection('all_users')
                      .doc(proDetails['uid'])
                      .update({
                    "account_approved": false,
                    "disapprove_reason": reason,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Professional rejected successfully.")),
                  );
                } catch (e) {
                  debugPrint("Error rejecting professional: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Error rejecting professional. Please try again.")),
                  );
                }
              },
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                          )))
                  : const SizedBox.shrink(),

              SizedBox(height: 50,),
              TabBar(
                controller: _tabController,
                indicatorColor: orange,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Approved'),
                  Tab(text: 'Rejected'),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Builder(
                        // Use a Builder to provide a context for the StreamBuilder
                        builder: (BuildContext context) {
                          if (_selectedStatus == 'pending') {
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('pro_requests')
                                  //       .where('status', isEqualTo: 'pending')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text("Error fetching data",
                                          style:
                                              TextStyle(color: Colors.white)));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                      child: Text(
                                          "No pending professionals found",
                                          style:
                                              TextStyle(color: Colors.white)));
                                }

                                List<Map<String, dynamic>> prosList =
                                    snapshot.data!.docs.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;

                                  return {
                                    "name": data['user_name'] ?? 'Unknown',
                                    "email": data['email'] ?? 'N/A',
                                    "phone": data['number'] ?? 'N/A',
                                    "experience":
                                        "${data['years_of_experience'] ?? '0'} years",
                                    "profile_pic": data['profile_pic'] ?? '',
                                    "address": data['address'] ?? 'N/A',
                                    "care_center_name":
                                        data['care_center_name'] ?? 'N/A',
                                    "category": data['category'] ?? 'N/A',
                                    "registration_number":
                                        data['registration_number'] ?? 'N/A',
                                    "role": data['role'] ?? 'N/A',
                                    "uid": data['uid'] ?? 'N/A',
                                    "docId": doc.id,
                                    "status": data['status'] ?? 'pending',
                                  };
                                }).toList();

                                return ListView.builder(
                                  itemCount: prosList.length,
                                  itemBuilder: (context, index) {
                                    final proDetails = prosList[index];
                                    return _buildProCard(proDetails, context,
                                        isPending:
                                            true); // Pass isPending = true
                                  },
                                );
                              },
                            );
                          } else if (_selectedStatus == 'approved') {
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('all_users')
                                  .where('account_approved', isEqualTo: true)
                                  .where('role', isEqualTo: 'pro')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text("Error fetching data",
                                          style:
                                              TextStyle(color: Colors.white)));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                      child: Text(
                                          "No approved professionals found",
                                          style:
                                              TextStyle(color: Colors.white)));
                                }

                                List<Map<String, dynamic>> prosList =
                                    snapshot.data!.docs.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;

                                  // Make sure to include the document ID for the all_users collection
                                  return {
                                    "name": data['user_name'] ?? 'Unknown',
                                    "email": data['email'] ?? 'N/A',
                                    "phone": data['number'] ?? 'N/A',
                                    "experience":
                                        "${data['years_of_experience'] ?? '0'} years",
                                    "profile_pic": data['profile_pic'] ?? '',
                                    "address": data['address'] ?? 'N/A',
                                    "care_center_name":
                                        data['care_center_name'] ?? 'N/A',
                                    "category": data['category'] ?? 'N/A',
                                    "registration_number":
                                        data['registration_number'] ?? 'N/A',
                                    "role": data['role'] ?? 'N/A',
                                    "uid": doc
                                        .id, // Use the document ID from all_users
                                    "docId": doc
                                        .id, // Also include docId, which is the same as UID in this case
                                    "status":
                                        'approved', // Manually set the status
                                  };
                                }).toList();

                                return ListView.builder(
                                  itemCount: prosList.length,
                                  itemBuilder: (context, index) {
                                    final proDetails = prosList[index];
                                    return _buildProCard(proDetails, context,
                                        isApproved:
                                            true); // Pass isApproved = true
                                  },
                                );
                              },
                            );
                          } else if (_selectedStatus == 'rejected') {
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('rejected_pros')
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return const Center(
                                      child: Text("Error fetching data",
                                          style:
                                              TextStyle(color: Colors.white)));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                      child: Text(
                                          "No rejected professionals found",
                                          style:
                                              TextStyle(color: Colors.white)));
                                }

                                List<Map<String, dynamic>> prosList =
                                    snapshot.data!.docs.map((doc) {
                                  var data = doc.data() as Map<String, dynamic>;

                                  return {
                                    "name": data['name'] ?? 'Unknown',
                                    "email": data['email'] ?? 'N/A',
                                    "phone": data['phone'] ?? 'N/A',
                                    "experience": data['experience'] ?? 'N/A',
                                    "profile_pic": data['profile_pic'] ?? '',
                                    "address": data['address'] ?? 'N/A',
                                    "care_center_name":
                                        data['care_center_name'] ?? 'N/A',
                                    "category": data['category'] ?? 'N/A',
                                    "registration_number":
                                        data['registration_number'] ?? 'N/A',
                                    "role": data['role'] ?? 'N/A',
                                    "uid": data['uid'] ?? 'N/A',
                                    "docId": doc.id,
                                    "status": 'rejected',
                                  };
                                }).toList();

                                return ListView.builder(
                                  itemCount: prosList.length,
                                  itemBuilder: (context, index) {
                                    final proDetails = prosList[index];
                                    return _buildProCard(proDetails, context,
                                        isRejected:
                                            true); // Pass isRejected = true
                                  },
                                );
                              },
                            );
                          } else {
                            return const Center(
                                child: Text("Invalid status selected.",
                                    style: TextStyle(color: Colors.white)));
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProCard(Map<String, dynamic> proDetails, BuildContext context,
      {bool isPending = false,
      bool isApproved = false,
      bool isRejected = false}) {
    // New Color Scheme
    const Color cardBackgroundColor = Colors.white;
    const Color detailIconColor = orange;
    const Color detailTextColor = darkBlue;

    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: cardBackgroundColor,
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
                    backgroundColor: detailIconColor,
                    child: proDetails['profile_pic'].isEmpty
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      proDetails['name'],
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: detailTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildDetailRow(Icons.email, "Email", proDetails['email'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(Icons.phone, "Phone", proDetails['phone'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(
                  Icons.work, "Experience", proDetails['experience'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(
                  Icons.location_on, "Address", proDetails['address'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(
                  Icons.business, "Care Center", proDetails['care_center_name'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(
                  Icons.category, "Category", proDetails['category'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(Icons.confirmation_number, "Registration No.",
                  proDetails['registration_number'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(Icons.person, "Role", proDetails['role'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(Icons.perm_identity, "UID", proDetails['uid'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              if (proDetails['disapprove_reason'] != null)
                _buildDetailRow(Icons.info_outline, "Rejection Reason",
                    proDetails['disapprove_reason'] ?? '',
                    iconColor: detailIconColor, textColor: detailTextColor),
              _buildDetailRow(Icons.info, "Status", proDetails['status'],
                  iconColor: detailIconColor, textColor: detailTextColor),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isPending) // Only show Approve and Reject buttons for pending requests
                    ElevatedButton.icon(
                      onPressed: () => _approveProfessional(
                          proDetails['uid'], proDetails['docId'], context),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text("Approve",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),

                  if (isPending)
                    ElevatedButton.icon(
                      onPressed: () => _rejectProfessional(
                          proDetails, proDetails['docId'], context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text("Reject",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  if (isApproved || isRejected)
                    Text("This professional is ${_selectedStatus}.",
                        style: TextStyle(color: detailTextColor)),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      {required Color iconColor, required Color textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Text("$label: ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          Expanded(
              child: Text(value,
                  style: TextStyle(fontSize: 16, color: textColor))),
        ],
      ),
    );
  }
}
