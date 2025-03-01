import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mascare_admin_backend/colors.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Remove RxList _usersData
  //final RxList<Map<String, dynamic>> _usersData = <Map<String, dynamic>>[].obs;
  RxString searchQuery = ''.obs;

  //Remove getter usersData
  //List<Map<String, dynamic>> get usersData => _usersData.value;

  // Create a stream of users
  Stream<List<Map<String, dynamic>>> get usersStream {
    return _firestore
        .collection('all_users')
        .where('is_deleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          'email': doc['email'] as String? ?? '',
          'role': doc['role'] as String? ?? '',
          'name': doc['user_name'] as String? ?? '',
          'number': doc['number'] as String? ?? '',
          'profile_pic': doc['profile_pic'] as String? ?? '',
        };
      }).toList();
    });
  }

  // Filtered users based on search query
  List<Map<String, dynamic>> filterUsers(List<Map<String, dynamic>> users) {
    if (searchQuery.isEmpty) {
      return users;
    } else {
      return users.where((user) =>
          user['name'].toString().toLowerCase().contains(searchQuery.value)).toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) {
      update(); // Trigger UI update when searchQuery changes
    });
  }

  Future<void> deleteUser(String userId, String? email, String? username, String? phoneNumber) async {
    bool? shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: darkBlue,
        title: const Text('Confirm Delete',style: TextStyle(color: orange),),
        content: const Text('Are you sure you want to permanently delete this user? This action is irreversible.',style: TextStyle(color: whiteColor),),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            onPressed: () => Get.back(result: false),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Get.back(result: true),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        // 1: Delete from Firebase Authentication (MODIFIED: Now always attempts deletion)
        try {
          List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email!);
          if (signInMethods.isNotEmpty) {
            try {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null && user.uid == userId) { //Check current signed in user id
                await user.delete();
                print("User deleted from Firebase Authentication");
              }else {
                print("User not signed in or wrong user to delete from Firebase Auth");
                // Provide a message to the user that they need to be signed in.
                Get.snackbar(
                    "Error",
                    "The user needs to be signed in to delete from Authentication.",
                    snackPosition: SnackPosition.BOTTOM
                );
              }
            } catch (authError) {
              print("Error deleting user from Firebase Auth: $authError");
              Get.snackbar('Error', 'Failed to delete user from Authentication: $authError', snackPosition: SnackPosition.BOTTOM);
              //Handle the authError based on the code to give specific message
            }
          }
        } catch (e) {
          print("Error checking sign-in methods: $e");
          Get.snackbar('Error', 'Failed to check sign-in methods: $e', snackPosition: SnackPosition.BOTTOM);
        }


        // 2: Delete from 'records' collection
        DocumentReference signupRecordsRef = _firestore.collection('records').doc('signup_records');
        DocumentSnapshot snapshot = await signupRecordsRef.get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

          List<dynamic> emails = List.from(data['emails'] ?? []);
          List<dynamic> userNames = List.from(data['user_names'] ?? []);
          List<dynamic> numbers = List.from(data['numbers'] ?? []);

          int index = emails.indexOf(email);
          if (index != -1) {
            emails.removeAt(index);
            userNames.removeAt(index);
            numbers.removeAt(index);

            await signupRecordsRef.update({
              'emails': emails,
              'user_names': userNames,
              'numbers': numbers,
            });
          }
        }

        // 3: Update all_users document
        await _firestore.collection('all_users').doc(userId).update({
          'is_deleted': true,
          'user_name': 'Deleted User',
          'email': 'Deleted User',
          'number': '*********',
          'fcm_token': '', // Set fcm_token to empty string
        });

        // 4: Update services document
        try {
          await _firestore.collection('services').doc(userId).update({
            'fcm_token': '', // Set fcm_token to empty string
            'availability': false,
          });
        } catch (e) {
          print("Service document not found for user: $userId"); //It's okay if no services document.
        }

        // Update local state (no longer needed)
        //_usersData.removeWhere((user) => user['uid'] == userId);

        Get.snackbar(
          'Success',
          'User deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue[900], // Dark Blue
          titleText: const Text(
            'Success',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          messageText: const Text(
            'User deleted successfully',
            style: TextStyle(color: Colors.white),
          ),
        );

      } catch (e) {
        print("Error deleting user: $e");
        Get.snackbar(
          'Error',
          'Failed to delete user: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}