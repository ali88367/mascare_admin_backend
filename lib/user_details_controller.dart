import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mascare_admin_backend/colors.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxString searchQuery = ''.obs;

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
          'is_suspended': doc['is_suspended'] as bool? ?? false,
        };
      }).toList();
    });
  }

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
      update();
    });
  }

  Future<void> deleteUser(String userId, String? email, String? username, String? phoneNumber) async {
    bool? shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: darkBlue,
        title: const Text('Confirm Delete', style: TextStyle(color: orange)),
        content: const Text(
            'Are you sure you want to permanently delete this user? This action is irreversible.',
            style: TextStyle(color: whiteColor)),
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
        // 1: Delete from Firebase Authentication
        try {
          List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email!);
          if (signInMethods.isNotEmpty) {
            try {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null && user.uid == userId) {
                await user.delete();
                print("User deleted from Firebase Authentication");
              } else {
                print(
                    "User not signed in or wrong user to delete from Firebase Auth");
                Get.snackbar(
                    "Error",
                    "The user needs to be signed in to delete from Authentication.",
                    snackPosition: SnackPosition.BOTTOM);
              }
            } catch (authError) {
              print("Error deleting user from Firebase Auth: $authError");
              Get.snackbar('Error', 'Failed to delete user from Authentication: $authError',
                  snackPosition: SnackPosition.BOTTOM);
            }
          }
        } catch (e) {
          print("Error checking sign-in methods: $e");
          Get.snackbar('Error', 'Failed to check sign-in methods: $e',
              snackPosition: SnackPosition.BOTTOM);
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
          'fcm_token': '',
        });

        // 4: Update services document
        try {
          await _firestore.collection('services').doc(userId).update({
            'fcm_token': '',
            'availability': false,
          });
        } catch (e) {
          print("Service document not found for user: $userId");
        }

        Get.snackbar(
          'Success',
          'User deleted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.blue[900],
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

  Future<void> updateUser(String userId, String newName, String newEmail) async {
    try {
      await _firestore.collection('all_users').doc(userId).update({
        'user_name': newName,
        'email': newEmail,
      });
      Get.snackbar(
        'Success',
        'User details updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print("Error updating user: $e");
      Get.snackbar(
        'Error',
        'Failed to update user: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> toggleUserSuspension(String userId, bool isCurrentlySuspended) async {
    try {
      // 1. Update is_suspended in all_users collection
      await _firestore.collection('all_users').doc(userId).update({
        'is_suspended': !isCurrentlySuspended,
      });

      // 2. Update is_suspended in services collection (if it exists)
      try {
        await _firestore.collection('services').doc(userId).update({
          'is_suspended': !isCurrentlySuspended,
        });
      } catch (e) {
        print("Service document not found or update failed for user: $userId.  This is not necessarily an error.");
        // It's okay if the document doesn't exist, but we should log the attempt.
      }


      Get.snackbar(
        'Success',
        'User ${!isCurrentlySuspended ? 'suspended' : 'unsuspended'} successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print("Error suspending/unsuspending user: $e");
      Get.snackbar(
        'Error',
        'Failed to suspend/unsuspend user: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}