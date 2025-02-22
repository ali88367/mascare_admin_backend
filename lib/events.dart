import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:mascare_admin_backend/widgets/custom_button.dart';

class AddEvents extends StatefulWidget {
  AddEvents({super.key});

  @override
  State<AddEvents> createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Uint8List? _image;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.clear();
    _descriptionController.clear();
  }

  Future<void> addEvent() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Title and description are required!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    String downloadUrl = ""; // Default value for no image

    try {
      if (_image != null) {
        String fileName = 'event_pictures/${_titleController.text}.jpg';
        UploadTask uploadTask = _storage.ref(fileName).putData(
          _image!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        TaskSnapshot snapshot = await uploadTask;
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      await _firestore.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'image_url': downloadUrl, // Store image URL (empty if no image)
        'created_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        "Success",
        "Event added successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      debugPrint("Error while posting: $e");
      Get.snackbar(
        "Error",
        "Failed to add event: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:darkBlue,

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                SizedBox(width: 10,),
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
                ],
              ),
              SizedBox(height: 20),
              Text('Enter Title',style: TextStyle(color: orange,fontWeight: FontWeight.w500,fontSize: 20),),
              SizedBox(height: 10),

              _buildInputField("Event Title", context, _titleController, maxLines: 1),
              SizedBox(height: 20),
              Text('Enter Description',style: TextStyle(color: orange,fontWeight: FontWeight.w500,fontSize: 20),),
              SizedBox(height: 10),

              _buildInputField("Event Description", context, _descriptionController, maxLines: 5),
              SizedBox(height: 50),
            CustomButton(text: 'Add Event', onPressed: addEvent,color: orange,height: 50,width: 200,)
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInputField(
    String labelText,
    BuildContext context,
    TextEditingController controller, {
      bool isNumber = false,
      int maxLines = 1,
    }) {
  final screenWidth = MediaQuery.of(context).size.width;

  return ConstrainedBox(  // Use ConstrainedBox to limit width
    constraints: BoxConstraints(
      maxWidth: 700,  // Set maximum width
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: null, // Removes the label text
        hintText: null,
        hintStyle:  TextStyle(color: Colors.black),
        isDense: true,// Ensures there's no hint text inside the field
        // contentPadding: EdgeInsets.symmetric(vertical: verticalPadding(width), horizontal: horizontalPadding(width)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey[300]!), // Lighter border color
        ),
        filled: true,
        fillColor: Color.fromRGBO(240, 240, 240, 1), // Lighter background color
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: orange), // Focused border color
        ),
      ),
    ),
  );
}