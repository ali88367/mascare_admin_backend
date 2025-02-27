import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BookingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> _allBookings = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  List<Map<String, dynamic>> get allBookings => _allBookings.value;

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

  Future<void> deleteBooking(String bookingId, String userId) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(userId)
          .collection('user_bookings')
          .doc(bookingId)
          .delete();

      _allBookings.removeWhere((booking) => booking['id'] == bookingId && booking['userId'] == userId);
      Get.snackbar('Success', 'Booking deleted successfully', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print("Error deleting booking: $e");
      Get.snackbar('Error', 'Failed to delete booking: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}