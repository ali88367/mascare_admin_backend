import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProReviews extends StatelessWidget {
  const ProReviews({super.key});

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('services').get();
      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pro Reviews')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          List<Map<String, dynamic>> users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return ListTile(
                title: Text(user['name'] ?? 'No Name'),
                subtitle: Text(user['email'] ?? 'No Email'),
              );
            },
          );
        },
      ),
    );
  }
}
