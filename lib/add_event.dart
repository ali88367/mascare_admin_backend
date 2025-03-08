import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:mascare_admin_backend/widgets/custom_button.dart';
import 'SideBar/sidebar_controller.dart';

class AddEvent extends StatefulWidget {
  final Map<String, dynamic>? eventData; // Optional event data for editing
  final String? eventId; // Optional event ID for editing

  const AddEvent({Key? key, this.eventData, this.eventId}) : super(key: key);

  // Added: Flag to indicate if navigated from edit
  bool get isEditMode => eventData != null && eventId != null;

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final SidebarController sidebarController = Get.find<SidebarController>();
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Uint8List? _image;
  String? _imageUrl; // To store the existing image URL
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _organizerController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _ticketPriceController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if available
    if (widget.eventData != null) {
      _titleController.text = widget.eventData!['title'] ?? '';
      _descriptionController.text = widget.eventData!['description'] ?? '';
      _organizerController.text = widget.eventData!['organizer'] ?? '';
      _dateController.text = widget.eventData!['date'] ?? '';
      _fromTimeController.text = widget.eventData!['from_time'] ?? '';
      _toTimeController.text = widget.eventData!['to_time'] ?? '';
      _ticketPriceController.text = widget.eventData!['ticket_price'] ?? '';
      _contactNumberController.text = widget.eventData!['contact_number'] ?? '';
      _addressController.text = widget.eventData!['address'] ?? '';
      _imageUrl = widget.eventData!['image_url'] ?? ''; // Store existing URL
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith( // Use ThemeData.dark for a dark theme
            colorScheme: ColorScheme.dark(
              primary: orange, // Header background color
              onPrimary: Colors.white, // Header text color
              surface: darkBlue, // Body background color
              onSurface: Colors.white, // Body text color
            ),
            dialogBackgroundColor: darkBlue, // Background color of the dialog
          ),
          child: child!,
        );
      },
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
      initialTime: controller.text.isNotEmpty
          ? TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(controller.text))
          : TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: darkBlue,
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white,
              dialTextColor: Colors.white,
              hourMinuteColor: darkBlue.withOpacity(0.8),
              dayPeriodColor: darkBlue.withOpacity(0.8),
              dialBackgroundColor: Colors.grey.shade800,
              entryModeIconColor: Colors.white,
              hourMinuteTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              dayPeriodTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              helpTextStyle: const TextStyle(color: Colors.white70),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                labelStyle: TextStyle(color: Colors.white),
              ),
              dialHandColor: orange, // Set the dial hand color
            ),
            colorScheme: ColorScheme.dark(
              primary: orange,
              onPrimary: Colors.white,
              surface: darkBlue,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: darkBlue,
          ),
          child: child!,
        );
      },
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

  // Function to clear the text fields
  void _clearTextFields() {
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
      _image = null; // Also clear the selected image
      _imageUrl = null; // And the image URL
    });
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
        _addressController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loader
    });

    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToStorage();
      } else {
        imageUrl = _imageUrl;
      }

      if (imageUrl == null) {
        Get.snackbar(
          "Error",
          "Failed to get image URL.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Map<String, dynamic> eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'organizer': _organizerController.text.trim(),
        'date': _dateController.text.trim(),
        'from_time': _fromTimeController.text.trim(),
        'to_time': _toTimeController.text.trim(),
        'ticket_price': _ticketPriceController.text.trim(),
        'contact_number': _contactNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'image_url': imageUrl,
      };

      if (widget.eventId == null) {
        eventData['created_at'] = FieldValue.serverTimestamp();
        await _firestore.collection('events').add(eventData);
        Get.snackbar(
          "Success",
          "Event added successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _clearTextFields(); // Clear the fields after successful add
      } else {
        await _firestore.collection('events').doc(widget.eventId).update(eventData);
        Get.snackbar(
          "Success",
          "Event updated successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      Get.back(); // Navigate back after successful operation

    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add/update event: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loader
      });
    }
  }
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _image = result.files.first.bytes;
        _imageUrl = null; // Reset the image URL since a new image is selected
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
      String fileName = "events/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = ref.putData(
        _image!,
        SettableMetadata(contentType: "image/jpeg"),
      );

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print("Upload Progress: ${progress.toStringAsFixed(2)}%");
      });

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

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
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: darkBlue,
      appBar: widget.isEditMode // Conditionally show the AppBar
          ? AppBar(
        backgroundColor: darkBlue,
        title: Text(widget.eventId == null ? 'Add Event' : 'Edit Event',
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(), // Navigate back when back button is pressed
        ),
      )
          : null, // Don't show AppBar if not in edit mode
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width < 768 ? 20 : 60,
        ),
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbVisibility: WidgetStatePropertyAll(true),
            thumbColor: WidgetStateProperty.all(orange),
            thickness: WidgetStateProperty.all(4), // Set thickness to 4
            trackColor: WidgetStateProperty.all(Colors.white30), // Track color
            trackBorderColor: WidgetStateProperty.all(Colors.transparent),
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
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                      )))
                  : const SizedBox.shrink(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
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
                                child: _image != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _image!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(child: Text("Error loading image"));
                                    },
                                  ),
                                )
                                    : const Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInputField("Enter Title", _titleController),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildInputField("Ticket Price", _ticketPriceController, isNumber: true),
                                )
                              ],
                            ),
                            _buildInputField("Enter Description", _descriptionController, maxLines: 5),
                            _buildInputField("Organizer Name", _organizerController),
                            _buildDatePickerField("Event Date", _dateController, _pickDate),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePickerField("From Time", _fromTimeController, () => _pickTime(_fromTimeController)),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: _buildTimePickerField("To Time", _toTimeController, () => _pickTime(_toTimeController)),
                                ),
                              ],
                            ),
                            _buildInputField("Contact Number", _contactNumberController, isNumber: true),
                            _buildInputField("Address", _addressController, maxLines: 3),
                            const SizedBox(height: 30),
                            Container(
                              width: 700, // Set the width
                              height: 50, // Set the height
                              decoration: BoxDecoration(
                                color: _isLoading ? orange.withOpacity(0.7) : orange, // Change opacity when loading
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                              child: InkWell(
                                onTap: _isLoading ? null : addEvent, // Disable onTap when loading
                                borderRadius: BorderRadius.circular(10), // Match the container's border radius
                                child: Center(
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // White loader
                                  )
                                      : Text(
                                    widget.eventId == null ? 'Add Event' : 'Update Event',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
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
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: orange),
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: orange),
          ),
          suffixIcon: const Icon(Icons.access_time, color: Colors.white),
        ),
      ),
    );
  }
}