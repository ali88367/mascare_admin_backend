import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'bookings_controller.dart'; // Import the controller

class Bookings extends StatelessWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingsController bookingsController = Get.put(BookingsController());

    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: Obx(() {
            if (bookingsController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (bookingsController.allBookings.isEmpty) {
              return const Center(
                child: Text(
                  'No Bookings Yet!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: bookingsController.allBookings.length,
                itemBuilder: (context, index) {
                  final booking = bookingsController.allBookings[index];
                  return BookingCard(
                    booking: booking,
                    onDelete: () => bookingsController.deleteBooking(booking['id']!, booking['userId']!),
                  );
                },
              );
            }
          }),
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onDelete;
  const BookingCard({super.key, required this.booking, required this.onDelete});

  Future<String> getServiceProviderName(String providerId) async {
    try {
      DocumentSnapshot providerDoc = await FirebaseFirestore.instance
          .collection('all_users')
          .doc(providerId)
          .get();

      if (providerDoc.exists) {
        return providerDoc['user_name'] ?? 'Unknown Provider';
      }
    } catch (e) {
      print('Error fetching provider name: $e');
    }
    return 'Unknown Provider';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 75,
                width: 119,
                child: Image.asset('assets/images/logo.png'),
              ),
              const SizedBox(width: 19),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey, size: 18),
                      const SizedBox(width: 5),
                      FutureBuilder<String>(
                        future: getServiceProviderName(booking['service_provider'] ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text(
                              'Fetching...',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
                            );
                          }
                          return Text(
                            snapshot.data ?? 'Unknown Provider',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking['category']?.toString() ?? 'N/A',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    booking['amount']?.toString() ?? '0',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: darkBlue, fontSize: 15),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Status',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    booking['status']?.toString() ?? '0',
                    style: const TextStyle(fontWeight: FontWeight.w500, color: darkBlue, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          Divider(color: Colors.grey[300], thickness: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Booking for', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        booking['from_date']?.toString() ?? 'N/A',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '-',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        booking['to_date']?.toString() ?? 'N/A',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 10),
                      Container(height: 14, width: 1, color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        booking['from_time']?.toString() ?? 'N/A',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        '-',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        booking['to_time']?.toString() ?? 'N/A',
                        style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Address', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
              Expanded(
                child: Text(
                  booking['note']?.toString() ?? 'N/A',
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}