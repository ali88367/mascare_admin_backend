import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:mascare_admin_backend/widgets/custom_button.dart';

import 'SideBar/sidebar_controller.dart';

class AddAdvertisement extends StatefulWidget {
  @override
  State<AddAdvertisement> createState() => _AddAdvertisementState();
}

class _AddAdvertisementState extends State<AddAdvertisement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SidebarController sidebarController = Get.find<SidebarController>();

  Uint8List? _image;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;
      });
    }
  }

  Future<void> addAdvertisement() async {
    if (_formKey.currentState!.validate()) {
      try {
        String imageUrl = "";
        String? docId;

        if (_image != null) {
          Reference ref = _storage
              .ref()
              .child('advertisements/${DateTime.now().millisecondsSinceEpoch}.jpg');

          UploadTask uploadTask = ref.putData(_image!);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Save to Firestore and get document ID
        DocumentReference docRef = await _firestore.collection('advertisements').add({
          'title': _titleController.text.trim(),
          'image_url': imageUrl,
          'created_at': FieldValue.serverTimestamp(),
        });

        docId = docRef.id;

        Get.snackbar(
          "Success",
          "Advertisement added successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        setState(() {
          _image = null;
          _titleController.clear();
        });
      } catch (e) {
        debugPrint("Error while adding advertisement: $e");
        Get.snackbar(
          "Error",
          "Failed to add advertisement: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> deleteAdvertisement(String docId, String imageUrl) async {
    try {
      await _firestore.collection('advertisements').doc(docId).delete();

      if (imageUrl.isNotEmpty) {
        await _storage.refFromURL(imageUrl).delete();
      }

      Get.snackbar(
        "Success",
        "Advertisement deleted successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Error deleting advertisement: $e");
      Get.snackbar(
        "Error",
        "Failed to delete advertisement",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

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
                child: Icon(Icons.menu, color: Colors.white),
              ),
            )
                : const SizedBox.shrink(),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Upload Advertisement",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: _image == null
                          ? Icon(Icons.image, size: 40, color: Colors.grey)
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _titleController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Advertisement Title",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: orange),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Title is required";
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'Add Advertisement',
                    onPressed: addAdvertisement,
                    color: orange,
                    height: 50,
                    width: 250,
                  ),
                  SizedBox(height: 40),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('advertisements').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No advertisements found",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        var ads = snapshot.data!.docs;

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : (MediaQuery.of(context).size.width > 600 ? 2 : 2),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: ads.length,
                          itemBuilder: (context, index) {
                            var ad = ads[index];
                            String docId = ad.id;
                            String title = ad['title'];
                            String imageUrl = ad['image_url'];

                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                      child: imageUrl.isNotEmpty
                                          ? Image.network(imageUrl, fit: BoxFit.cover)
                                          : Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image, color: Colors.grey[700], size: 50),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      title,
                                      style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                    child: ElevatedButton(
                                      onPressed: () => deleteAdvertisement(docId, imageUrl),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text("Delete", style: TextStyle(color: Colors.white)),
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
          ],
        ),
      ),
    );
  }
}