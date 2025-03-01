import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/SideBar/sidebar_controller.dart'; // Make sure this import is correct

class Services extends StatelessWidget {
  const Services({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: darkBlue,
      body: Center(  // Center the content
        child: ConstrainedBox(  // Limit width to 700
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width < 768 ? 20 : 60,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,  // Stretch to fill width
              children: [
                SizedBox(height: 50),
                Get.width < 768
                    ? GestureDetector(
                    onTap: () {
                      Get.find<SidebarController>().showsidebar.value = true;
                    },
                    child: const Padding(
                        padding: EdgeInsets.only(left: 10, top: 10),
                        child: Icon(Icons.menu, color: Colors.white,)))
                    : const SizedBox.shrink(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('services').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}',style: TextStyle(color: Colors.white),));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No Services Available',style: TextStyle(color: Colors.white),));
                      } else {
                        return  ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            // Check if 'single_photo' exists and its value
                            final bool singlePhoto = data['single_photo'] ?? false;

                            // Determine which image to use
                            final String image = singlePhoto
                                ? (data['photo'] ?? 'assets/images/logo.png') // Use single image
                                : ((data['photos'] is List && data['photos'].isNotEmpty)
                                ? data['photos'][0] // Use the first image from photos array
                                : 'assets/images/logo.png'); // Default image if array is empty

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
                                  image: image, // Use the conditionally fetched image
                                  serviceName: serviceProviderName,
                                  category: data['category'] ?? 'Uncategorized',
                                  pricePerHour: double.tryParse(data['price_per_hour']?.toString() ?? '0') ?? 0.0,
                                  averageRating: double.tryParse(data['average_rating']?.toString() ?? '0') ?? 0.0,
                                  serviceRatings: int.tryParse(data['service_ratings']?.toString() ?? '0') ?? 0,
                                  caretakerId: doc.id,
                                  index: index,
                                  onDelete: () {
                                    // Add a delete callback
                                    _deleteService(context, doc.id);
                                  },
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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

  // Function to delete a service
  void _deleteService(BuildContext context, String serviceId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Service"),
          content: const Text("Are you sure you want to delete this service?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('services').doc(serviceId).delete();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error deleting service: $e');
                  // Show an error message if deletion fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete service.')),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
  final VoidCallback onDelete; // Delete callback

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
    required this.onDelete, // Receive delete callback
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
            Expanded( // Wrap the column with Expanded
              child: Column(
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
            ),
            IconButton( // Added delete button
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete, // Call the delete function
            ),
          ],
        ),
      ),
    );
  }
}