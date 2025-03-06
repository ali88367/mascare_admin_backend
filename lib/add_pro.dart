import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

import 'colors.dart';

class AddProPage extends StatelessWidget {
  const AddProPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text('Add New Pro', style: TextStyle(color: orange)),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AddUserForm(userType: 'pro'),
          ),
        ),
      ),
    );
  }
}

class AddUserForm extends StatefulWidget {
  final String userType;

  const AddUserForm({Key? key, required this.userType}) : super(key: key);

  @override
  _AddUserFormState createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController careCenterNameController = TextEditingController();
  String? category;
  String? yearsOfExperience;
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController aboutServiceController = TextEditingController();
  final TextEditingController pricePerHourController = TextEditingController();
  final TextEditingController noteToParentsController = TextEditingController();
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController fromTimeController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController toTimeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Uint8List? _profileImage;
  List<Uint8List> _additionalImages = [];

  final List<String> experienceOptions = [
    'Less than one year',
    'Less than two years',
    'Less than five years',
  ];

  final List<String> categoryOptions = [
    'Caregiver',
    'Nanny',
    'Baby Sitter',
  ];

  Future<void> _pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _profileImage = result.files.first.bytes;
      });
    }
  }

  Future<void> _pickAdditionalImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _additionalImages.addAll(result.files.map((file) => file.bytes!).toList());
      });
    }
  }

  void _deleteAdditionalImage(int index) {
    setState(() {
      _additionalImages.removeAt(index);
    });
  }

  Future<String?> _uploadImageToFirebase(String uid, Uint8List image, String imageName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child("user_profiles/$uid/$imageName.jpg");
      await storageRef.putData(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: orange,
              surface: darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime(TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: controller.text.isNotEmpty
          ? TimeOfDay.fromDateTime(DateFormat('hh:mm a').parse(controller.text))
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: orange,
              surface: darkBlue,
            ),
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

  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: orange)),
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: orange)),
          suffixIcon: const Icon(Icons.calendar_today, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(String label, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: orange)),
          suffixIcon: const Icon(Icons.access_time, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildExperienceDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: yearsOfExperience,
        decoration: InputDecoration(
          labelText: 'Years of Experience',
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: orange)),
        ),
        dropdownColor: darkBlue,
        style: const TextStyle(color: Colors.white),
        items: experienceOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.white)), // Ensure text color is white
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            yearsOfExperience = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select an option' : null,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: category,
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: orange)),
        ),
        dropdownColor: darkBlue,
        style: const TextStyle(color: Colors.white),
        items: categoryOptions.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.white)),  // Ensure text color is white
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            category = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select an option' : null,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                  child: _profileImage == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.white) : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: orange),
                onPressed: _pickAdditionalImages,
                child: const Text("Add Additional Images", style: TextStyle(color: darkBlue)),
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: List.generate(
                _additionalImages.length,
                    (index) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(_additionalImages[index]),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _deleteAdditionalImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("User Details", style: TextStyle(color: orange, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInputField('User Name', userNameController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInputField('Email', emailController)),
              ],
            ),
            _buildInputField('Password', passwordController),
            _buildInputField('Phone Number', numberController, isNumber: true),
            _buildInputField('Address', addressController),
            _buildInputField('Care Center Name', careCenterNameController),
            _buildCategoryDropdown(),
            _buildExperienceDropdown(),

            if (widget.userType == 'pro') ...[
              const SizedBox(height: 24),
              const Text("Service Details", style: TextStyle(color: orange, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              _buildInputField('Registration Number', registrationNumberController),
              _buildInputField('About Service', aboutServiceController, maxLines: 3),
              _buildInputField('Price Per Hour', pricePerHourController, isNumber: true),
              _buildInputField('Note to Parents', noteToParentsController),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePickerField('From Date', fromDateController, () => _pickDate(fromDateController)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePickerField('From Time', fromTimeController, () => _pickTime(fromTimeController)),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePickerField('To Date', toDateController, () => _pickDate(toDateController)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePickerField('To Time', toTimeController, () => _pickTime(toTimeController)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: orange),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        String uid = userCredential.user!.uid;

                        String? profilePicURL = _profileImage != null
                            ? await _uploadImageToFirebase(uid, _profileImage!, 'profile')
                            : null;

                        List<String> additionalImageUrls = [];
                        for (int i = 0; i < _additionalImages.length; i++) {
                          String? url = await _uploadImageToFirebase(uid, _additionalImages[i], 'additional_$i');
                          if (url != null) additionalImageUrls.add(url);
                        }

                        Map<String, dynamic> allUsersData = {
                          'user_name': userNameController.text.trim(),
                          'uid': uid,
                          'role': 'pro',
                          'profile_pic': profilePicURL ?? '',
                          'number': numberController.text.trim(),
                          'is_suspended': false,
                          'is_deleted': false,
                          'fcm_token': '',
                          'email': emailController.text.trim(),
                          'address': addressController.text.trim(),
                          'account_approved': true,
                          'details_complete': true,
                          'disapprove_reason': '',
                          'care_center_name': careCenterNameController.text.trim(),
                          'category': category,
                          'years_of_experience': yearsOfExperience,
                          'registration_number': registrationNumberController.text.trim(),
                          'service_added': true,
                          'createdAt': FieldValue.serverTimestamp(),
                        };

                        if (widget.userType == 'pro') {
                          Map<String, dynamic> servicesData = {
                            'about_service': aboutServiceController.text.trim(),
                            'availability': true,
                            'average_rating': '0',
                            'booked': false,
                            'care_center_name': careCenterNameController.text.trim(),
                            'category': category,
                            'company_registration': registrationNumberController.text.trim(),
                            'customers': [],
                            'fcm_token': '',
                            'from_date': fromDateController.text.trim(),
                            'from_time': fromTimeController.text.trim(),
                            'full_time_care': false,
                            'is_suspended': false,
                            'mentioned_services': [],
                            'note_to_parents': noteToParentsController.text.trim(),
                            'photo': profilePicURL ?? '',
                            'photos': additionalImageUrls,
                            'price_per_hour': double.tryParse(pricePerHourController.text.trim()) ?? 0.0,
                            'registration_number': registrationNumberController.text.trim(),
                            'service_provider': uid,
                            'service_ratings': '',
                            'single_photo': true,
                            'to_date': toDateController.text.trim(),
                            'to_time': toTimeController.text.trim(),
                            'work_hours': '',

                          };
                          await FirebaseFirestore.instance.collection('services').doc(uid).set(servicesData);
                        }

                        await FirebaseFirestore.instance.collection('all_users').doc(uid).set(allUsersData);
                        Navigator.of(context).pop();
                        Get.snackbar('Success', 'Pro added successfully', snackPosition: SnackPosition.BOTTOM);
                      } catch (e) {
                        Get.snackbar('Error', 'Failed to add pro: $e', snackPosition: SnackPosition.BOTTOM);
                      }
                    }
                  },
                  child: const Text('Add', style: TextStyle(color: darkBlue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}