import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';

class Bookings extends StatefulWidget {
  const Bookings({super.key});

  @override
  State<Bookings> createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  final String userId = "34k9QUc5y6fPcgGvo6l9E9i8iDO2"; // Replace with dynamic userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 700),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .doc(userId)
                .collection('user_bookings')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No Bookings Yet!',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }

              var bookingsData = snapshot.data!.docs.map((doc) {
                var booking = {
                  'id': doc.id, // Add the document ID to the booking data
                  'service_provider': doc['service_provider']?.toString() ?? 'N/A',
                  'category': doc['category']?.toString() ?? 'N/A',
                  'amount': doc['amount'] != null ? doc['amount'].toString() : 'N/A', // Convert int/null to String
                  'from_date': doc['from_date']?.toString() ?? 'N/A',
                  'to_date': doc['to_date']?.toString() ?? 'N/A',
                  'from_time': doc['from_time']?.toString() ?? 'N/A',
                  'to_time': doc['to_time']?.toString() ?? 'N/A',
                  'note': doc['note']?.toString() ?? 'N/A',
                  'status': doc['status']?.toString() ?? 'N/A',
                };

                print("Booking Data: $booking");
                return booking;
              }).toList();

              print("All Bookings: $bookingsData");

              return ListView.builder(
                itemCount: bookingsData.length,
                itemBuilder: (context, index) {
                  return BookingCard(
                    booking: bookingsData[index],
                    onDelete: () => _deleteBooking(bookingsData[index]['id']!),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Method to delete a booking
  Future<void> _deleteBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(userId)
          .collection('user_bookings')
          .doc(bookingId)
          .delete();
      print("Booking deleted successfully!");
    } catch (e) {
      print("Error deleting booking: $e");
    }
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
      padding: EdgeInsets.all(11),
      margin: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 0),
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
              SizedBox(width: 19),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.grey, size: 18),
                      SizedBox(width: 5),
                      FutureBuilder<String>(
                        future: getServiceProviderName(booking['service_provider'] ?? ''),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Fetching...',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
                            );
                          }
                          return Text(
                            snapshot.data ?? 'Unknown Provider',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  Text(
                    booking['category']?.toString() ?? 'N/A',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  Text(
                    booking['amount']?.toString() ?? '0',
                    style: TextStyle(fontWeight: FontWeight.w700, color: darkBlue, fontSize: 15),
                  ),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: darkBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Status',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  SizedBox(height: 28),
                  Text(
                    booking['status']?.toString() ?? '0',
                    style: TextStyle(fontWeight: FontWeight.w500, color: darkBlue, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
          Divider(color: Colors.grey[300], thickness: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Booking for', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        booking['from_date']?.toString() ?? 'N/A',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '-',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 5),
                      Text(
                        booking['to_date']?.toString() ?? 'N/A',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(width: 10),
                      Container(height: 14, width: 1, color: Colors.black),
                      SizedBox(width: 10),
                      Text(
                        booking['from_time']?.toString() ?? 'N/A',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '-',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        booking['to_time']?.toString() ?? 'N/A',
                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Address', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500)),
              Expanded(
                child: Text(
                  booking['note']?.toString() ?? 'N/A',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}