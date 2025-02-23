import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import this for DateFormat
import 'package:mascare_admin_backend/colors.dart';
import 'package:mascare_admin_backend/widgets/custom_button.dart';

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _contactNumberController =
  TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      ));

      setState(() {
        controller.text = formattedTime;
      });
    }
  }

  Future<void> addEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _organizerController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _fromTimeController.text.isEmpty ||
        _toTimeController.text.isEmpty ||
        _ticketPriceController.text.isEmpty ||
        _contactNumberController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _image == null) { // Ensure image is selected
      Get.snackbar(
        "Error",
        "All fields are required, including an image!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Upload image to Firebase Storage
      String? imageUrl = await _uploadImageToStorage();

      // Store event data in Firestore
      await _firestore.collection('events').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'organizer': _organizerController.text.trim(),
        'date': _dateController.text.trim(),
        'from_time': _fromTimeController.text.trim(),
        'to_time': _toTimeController.text.trim(),
        'ticket_price': _ticketPriceController.text.trim(),
        'contact_number': _contactNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'image_url': imageUrl, // Save the image URL in Firestore
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
      _organizerController.clear();
      _dateController.clear();
      _fromTimeController.clear();
      _toTimeController.clear();
      _ticketPriceController.clear();
      _contactNumberController.clear();
      _addressController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add event: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }



  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _image = result.files.first.bytes; // Store as Uint8List
      });
      print("Image selected successfully.");
    } else {
      print("No image selected.");
    }
  }

  Future<String?> _uploadImageToStorage() async {
    if (_image == null) {
      print("No image selected for upload.");
      return null;
    }

    try {
      // ✅ Set unique file name
      String fileName = "events/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      // ✅ Upload image with metadata
      UploadTask uploadTask = ref.putData(
        _image!,
        SettableMetadata(contentType: "image/jpeg"),
      );

      // ✅ Track upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print("Upload Progress: ${progress.toStringAsFixed(2)}%");
      });

      // ✅ Wait for completion
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // ✅ Get correct URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Uploaded Image URL: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      print("🔥 Image upload failed: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      width: double.infinity,
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField("Enter Title", _titleController),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildInputField(
                            "Ticket Price", _ticketPriceController,
                            isNumber: true),
                      )
                    ],
                  ),
                  _buildInputField("Enter Description", _descriptionController,
                      maxLines: 5),
                  _buildInputField("Organizer Name", _organizerController),
                  _buildDatePickerField("Event Date", _dateController, _pickDate),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimePickerField(
                            "From Time", _fromTimeController, () => _pickTime(_fromTimeController)),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildTimePickerField(
                            "To Time", _toTimeController, () => _pickTime(_toTimeController)),
                      ),
                    ],
                  ),
                  _buildInputField("Contact Number", _contactNumberController,
                      isNumber: true),
                  _buildInputField("Address", _addressController, maxLines: 3),
                  SizedBox(height: 30),
                  CustomButton(
                      text: 'Add Event',
                      onPressed: addEvent,
                      color: orange,
                      height: 50,
                      width: 700),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildInputField(String label, TextEditingController controller,
    {bool isNumber = false, int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: orange),
        ),
      ),
    ),
  );
}

Widget _buildDatePickerField(String label, TextEditingController controller, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextField(
      controller: controller,
      readOnly: true, // Prevent manual input
      onTap: onTap, // Open date picker when tapped
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: orange),
        ),
        suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
      ),
    ),
  );
}

Widget _buildTimePickerField(String label, TextEditingController controller, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextField(
      controller: controller,
      readOnly: true, // Prevent manual input
      onTap: onTap, // Open time picker when tapped
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: orange),
        ),
        suffixIcon: Icon(Icons.access_time, color: Colors.white),
      ),
    ),
  );
}
