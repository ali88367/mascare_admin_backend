import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'SideBar/sidebar_controller.dart';
import 'bookings_controller.dart';

class Bookings extends StatefulWidget {
  const Bookings({Key? key}) : super(key: key);

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  final SidebarController sidebarController = Get.find<SidebarController>();


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width; // Get screen width
    final BookingsController bookingsController = Get.put(BookingsController());

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
                    child: Icon(Icons.menu, color: Colors.white,))) // Ensure the icon is visible
                : const SizedBox.shrink(),

            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),

                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Bookings...',
                            prefixIcon: const Icon(Icons.search, color: orange),
                            fillColor: Colors.white,
                            filled: true,
                            border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                            hintStyle: const TextStyle(color: orange),
                          ),
                          onChanged: bookingsController.setSearchQuery,
                        ),
                        const SizedBox(height: 16),

                        // Filter Buttons
                        Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () => bookingsController.setSelectedStatus('all'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  bookingsController.selectedStatus.value == 'all' ? orange : Colors.grey,
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Add radius here
                                  ),
                                ),
                              ),
                              child: const Text('All', style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: () => bookingsController.setSelectedStatus('upcoming'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  bookingsController.selectedStatus.value == 'upcoming' ? orange : Colors.grey,
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Add radius here
                                  ),
                                ),
                              ),
                              child: const Text('Upcoming', style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: () => bookingsController.setSelectedStatus('completed'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  bookingsController.selectedStatus.value == 'completed' ? orange : Colors.grey,
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Add radius here
                                  ),
                                ),
                              ),
                              child: const Text('Completed', style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: () => bookingsController.setSelectedStatus('cancelled'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  bookingsController.selectedStatus.value == 'cancelled' ? orange : Colors.grey,
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8), // Add radius here
                                  ),
                                ),
                              ),
                              child: const Text('Cancelled', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        )),
                        const SizedBox(height: 16),

                        // Booking List
                        Expanded(
                          child: Obx(() {
                            if (bookingsController.isLoading.value) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (bookingsController.filteredBookings.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No Bookings Found!',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              );
                            } else {
                              return ListView.builder(
                                itemCount: bookingsController.filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = bookingsController.filteredBookings[index];
                                  return BookingCard(
                                    booking: booking,
                                    onDelete: () {
                                      print(booking);
                                      bookingsController.deleteBooking(
                                          booking['id']!,
                                          booking['userId']!,
                                          booking['service_provider']!);

                                    }   );
                                },
                              );
                            }
                          }),
                        ),
                      ],
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
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onDelete;
  const BookingCard({Key? key, required this.booking, required this.onDelete}) : super(key: key);

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

  Future<String> getCustomerName(String customerId) async {
    try {
      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('all_users')
          .doc(customerId)
          .get();

      if (customerDoc.exists) {
        return customerDoc['user_name'] ?? 'Unknown Customer';
      }
    } catch (e) {
      print('Error fetching customer name: $e');
    }
    return 'Unknown Customer';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Service Provider & Category
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<String>(
                    future: getServiceProviderName(booking['service_provider'] ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Fetching Provider...',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey),
                        );
                      }
                      return Text(
                        snapshot.data ?? 'Unknown Provider',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking['category']?.toString() ?? 'N/A',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),

              // Booking Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status']?.toString() ?? 'Unknown',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey, thickness: 0.3, height: 24),

          // Booking Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date & Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '${booking['from_date'] ?? 'N/A'} - ${booking['to_date'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text('Time', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '${booking['from_time'] ?? 'N/A'} - ${booking['to_time'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              // Amount & User Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Amount', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '\$${booking['amount']?.toString() ?? '0'}',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: darkBlue, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('Customer', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  FutureBuilder<String>(
                    future: getCustomerName(booking['userId'] ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text(
                          'Fetching...',
                          style: TextStyle(fontSize: 12),
                        );
                      }
                      return Text(
                        snapshot.data ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87, fontSize: 14),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Address / Note
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Note', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                booking['note']?.toString() ?? 'No Note provided',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}