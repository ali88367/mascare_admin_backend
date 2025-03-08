import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:mascare_admin_backend/SideBar/sidebar_controller.dart'; // Import SidebarController

class AdvertisementList extends StatefulWidget {
  @override
  _AdvertisementListState createState() => _AdvertisementListState();
}

class _AdvertisementListState extends State<AdvertisementList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SidebarController sidebarController = Get.find<SidebarController>(); // Initialize SidebarController

  Future<void> _deleteAdvertisement(String documentId) async {
    try {
      await _firestore.collection('advertisements').doc(documentId).delete();
      Get.snackbar(
        "Success",
        "Advertisement deleted successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error deleting advertisement: $e");
      Get.snackbar(
        "Error",
        "Failed to delete advertisement: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,

      body: Padding(  // Wrap the whole body in Padding
        padding: const EdgeInsets.all(8.0),
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
                    child: Icon(Icons.menu,
                        color: Colors.white))) // Ensure the icon is visible
                : const SizedBox.shrink(),
            Expanded(  // Wrap the stream builder in expanded
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('advertisements').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(orange)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No advertisements found.', style: TextStyle(color: Colors.white)));
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2, // Responsive cross-axis count
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8, // Adjust as needed
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var advertisement = snapshot.data!.docs[index];
                      String documentId = advertisement.id;  // Get the document ID
                      return Container(
                        decoration: BoxDecoration(
                          color: darkBlue, // Use colors.dart
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                child: advertisement.get('image_url') != null && advertisement.get('image_url').isNotEmpty
                                    ? Image.network(
                                  advertisement.get('image_url'),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(child: Text('Failed to load image', style: TextStyle(color: Colors.white)));
                                  },
                                )
                                    : const Center(child: Icon(Icons.image, size: 50, color: Colors.white)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                advertisement.get('title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _deleteAdvertisement(documentId), // Pass the document ID
                                child: const Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}