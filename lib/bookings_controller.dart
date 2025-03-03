import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Import for Get.snackbar


class BookingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> _allBookings = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'all'.obs;

  List<Map<String, dynamic>> get allBookings => _allBookings.value;

  List<Map<String, dynamic>> get filteredBookings {
    List<Map<String, dynamic>> filteredList = List.from(allBookings); // Create a copy

    // Apply Status Filter
    if (selectedStatus.value != 'all') {
      filteredList = filteredList.where((booking) => booking['status']?.toLowerCase() == selectedStatus.value).toList();
    }

    // Apply Search Filter
    if (searchQuery.isNotEmpty) {
      filteredList = filteredList.where((booking) {
        final category = booking['category']?.toString().toLowerCase() ?? '';
        final note = booking['note']?.toString().toLowerCase() ?? '';
        final serviceProvider = booking['service_provider']?.toString().toLowerCase() ?? '';
        return category.contains(searchQuery.value) || note.contains(searchQuery.value) || serviceProvider.contains(searchQuery.value);
      }).toList();
    }

    return filteredList;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    isLoading.value = true;
    try {
      QuerySnapshot usersSnapshot = await _firestore.collection('bookings').get();
      List<Map<String, dynamic>> bookings = [];

      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;
        QuerySnapshot userBookingsSnapshot = await _firestore
            .collection('bookings')
            .doc(userId)
            .collection('user_bookings')
            .get();

        for (var doc in userBookingsSnapshot.docs) {
          var booking = {
            'id': doc.id,
            'userId': userId,
            'service_provider': doc['service_provider']?.toString() ?? 'N/A',
            'category': doc['category']?.toString() ?? 'N/A',
            'amount': doc['amount'] != null ? doc['amount'].toString() : 'N/A',
            'from_date': doc['from_date']?.toString() ?? 'N/A',
            'to_date': doc['to_date']?.toString() ?? 'N/A',
            'from_time': doc['from_time']?.toString() ?? 'N/A',
            'to_time': doc['to_time']?.toString() ?? 'N/A',
            'note': doc['note']?.toString() ?? 'N/A',
            'status': doc['status']?.toString() ?? 'N/A',
          };
          bookings.add(booking);
        }
      }
      _allBookings.value = bookings;
    } catch (e) {
      print("Error fetching bookings: $e");
      Get.snackbar('Error', 'Failed to fetch bookings: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBooking(String bookingId, String userId,String serviceId) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(userId)
          .collection('user_bookings')
          .doc(bookingId)
          .update({
        'status':'Cancelled',
        'statusTime':FieldValue.serverTimestamp()

      });

      var data = await FirebaseFirestore.instance.collection("services").doc(serviceId).get();

      var customers = data["customers"] ?? [];

      customers.removeWhere((map)=> map["booking_id"] == bookingId);

      await FirebaseFirestore.instance.collection("services").doc(serviceId).update({
        "customers": customers,
      });
      Get.snackbar('Success', 'Booking deleted successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print("Error deleting booking: $e");
      Get.snackbar('Error', 'Failed to delete booking: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.toLowerCase();
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
  }

  Future<void> updateBookingStatus(String bookingId,String userId, String newStatus) async {
    isLoading.value = true; //Show loading indicator

    try {
      // Update the booking status in Firestore
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(userId)
          .collection('user_bookings')
          .doc(bookingId)
          .update({'status': newStatus});

      // Optionally refresh the booking list after updating.
      fetchAllBookings(); // Assuming getBookings() reloads the data
      Get.snackbar('Success', 'Booking cancelled successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } catch (error) {
      print('Error cancelling booking: $error');
      Get.snackbar('Error', 'Failed to cancel booking. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false; //Hide loading indicator
    }
  }


}