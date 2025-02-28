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
                                onDelete: () => bookingsController.deleteBooking(booking['id']!, booking['userId']!),
                              );
                            },
                          );
                        }
                      }),
                    ),
                  ],
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      booking['status']?.toString() ?? '0',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'User Name',
                    style: TextStyle(fontWeight: FontWeight.w500, color: darkBlue, fontSize: 12),
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