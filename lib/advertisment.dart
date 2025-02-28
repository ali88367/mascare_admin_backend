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

        if (_image != null) {
          // Upload image to Firebase Storage
          Reference ref = _storage
              .ref()
              .child('advertisements/${DateTime.now().millisecondsSinceEpoch}.jpg');

          UploadTask uploadTask = ref.putData(_image!);
          TaskSnapshot snapshot = await uploadTask;
          imageUrl = await snapshot.ref.getDownloadURL();
        }

        // Save to Firestore with image URL
        await _firestore.collection('advertisements').add({
          'title': _titleController.text.trim(),
          'image_url': imageUrl,
          'created_at': FieldValue.serverTimestamp(),
        });

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;

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
                    child: Icon(Icons.menu,
                      color: Colors.white,))) // Ensure the icon is visible
                : const SizedBox.shrink(),
            Expanded( // Added Expanded to allow the Center to fill the remaining space
              child: Center( // Your original Center widget
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                ? Icon(
                                Icons.image, size: 40, color: Colors.grey)
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
                              if (value == null || value
                                  .trim()
                                  .isEmpty) {
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
  }}
