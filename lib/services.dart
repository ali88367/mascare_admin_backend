import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';

class Services extends StatelessWidget {
  const Services({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No Services Available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;

                // Check if service_provider exists
                final String? serviceProviderUid = data['service_provider'];

                return FutureBuilder<String>(
                  // Fetch the user name from all_users based on the service_provider UID
                  future: _getUserName(serviceProviderUid),
                  builder: (context, snapshot) {
                    String serviceProviderName = 'Unknown Service Provider';
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      serviceProviderName = snapshot.data!;
                    }

                    return Servicewidget(
                      image: data['photo'] ?? 'assets/images/logo.png',
                      serviceName: serviceProviderName, // Display user name here
                      category: data['category'] ?? 'Uncategorized',
                      pricePerHour: (data['price_per_hour'] ?? 0).toDouble(),
                      averageRating: (data['average_rating'] ?? 0).toDouble(),
                      serviceRatings: data['service_ratings'] ?? 0,
                      caretakerId: doc.id,
                      index: index,
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  // Function to fetch the user name from all_users
  Future<String> _getUserName(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return 'Unknown Service Provider';
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('all_users').doc(userId).get();

      if (userDoc.exists) {
        return userDoc['user_name'] ?? 'Unknown Service Provider';
      } else {
        return 'Unknown Service Provider';
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown Service Provider';
    }
  }
}

class Servicewidget extends StatefulWidget {
  final String image;
  final String serviceName;
  final String category;
  final double pricePerHour;
  final double averageRating;
  final int serviceRatings;
  final String caretakerId;
  int index;

  Servicewidget({
    super.key,
    required this.image,
    required this.serviceName,
    required this.category,
    required this.pricePerHour,
    required this.averageRating,
    required this.serviceRatings,
    required this.caretakerId,
    required this.index,
  });

  @override
  State<Servicewidget> createState() => _ServicewidgetState();
}

class _ServicewidgetState extends State<Servicewidget> {
  bool isBookmarked = false; // Local state for bookmark status

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 15,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 112,
              width: 119,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(widget.image), // Use NetworkImage for Firebase images
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: 19,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person,
                      color: Colors.grey,
                      size: 18,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      widget.serviceName, // Use serviceName from widget
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  widget.category, // Use category from widget
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.pricePerHour.toStringAsFixed(0)}\$ ', // Use pricePerHour from widget
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: darkBlue,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          ' Per hr',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child:Icon(Icons.star,size: 15,color: Colors.orange,),
                        ),
                        Text(
                          widget.averageRating.toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          height: 12,
                          width: 0.5,
                          color: Colors.grey,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Text(
                          '${widget.serviceRatings} reviews',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}