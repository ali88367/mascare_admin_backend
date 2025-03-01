import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mascare_admin_backend/colors.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  // Helper function to fetch username from user ID
  Future<String> _getUsernameFromUserId(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('all_users')
          .doc(userId)
          .get();

      if (userSnapshot.exists && userSnapshot.data() != null) {
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        return userData['user_name'] ?? 'Unknown User';
      } else {
        return 'User Not Found';
      }
    } catch (e) {
      print('Error fetching username: $e');
      return 'Error Loading User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reports').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No reports found.', style: TextStyle(color: Colors.white, fontSize: 16)),
              );
            }

            // Show loader until all reports have fetched necessary data
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: Future.wait(snapshot.data!.docs.map((reportDoc) async {
                final reportData = reportDoc.data() as Map<String, dynamic>;
                final reporterId = reportData['reporterId'];
                final serviceId = reportData['serviceId'];

                final reporterName = await _getUsernameFromUserId(reporterId);
                final serviceName = await _getUsernameFromUserId(serviceId);

                return {
                  'reportData': reportData,
                  'reporterName': reporterName,
                  'serviceName': serviceName,
                };
              }).toList()),
              builder: (context, reportsSnapshot) {
                if (reportsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }

                if (reportsSnapshot.hasError) {
                  return Center(
                    child: Text('Error loading reports: ${reportsSnapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                  );
                }

                final reports = reportsSnapshot.data ?? [];

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final reportData = reports[index]['reportData'];
                    final reporterName = reports[index]['reporterName'];
                    final serviceName = reports[index]['serviceName'];

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: darkBlue,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reporterName,
                                        style: TextStyle(
                                            color: darkBlue, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Reporter', style: TextStyle(color: Colors.grey[700])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: orange,
                                  child: const Icon(Icons.business, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        serviceName,
                                        style: TextStyle(
                                            color: orange, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Service Provider', style: TextStyle(color: Colors.grey[700])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1),
                            Text(
                              'Reason:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reportData['reason'] ?? 'No reason provided',
                              style: const TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.grey, size: 18),
                                const SizedBox(width: 5),
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format((reportData['timestamp'] as Timestamp).toDate()),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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
            );
          },
        ),
      ),
    );
  }
}
