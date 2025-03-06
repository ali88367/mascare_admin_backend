import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddUserPage extends StatelessWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        title: const Text('Add New User', style: TextStyle(color: orange)),
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      body: Center(
        child: AddUserForm(userType: 'user'), // Directly use AddUserForm with userType 'pro'
      ),
    );
  }
}


// Separate Stateful Widget for Add User Form
class AddUserForm extends StatefulWidget {
  final String userType;

  const AddUserForm({Key? key, required this.userType}) : super(key: key);

  @override
  _AddUserFormState createState() => _AddUserFormState();
}

class _AddUserFormState extends State<AddUserForm> {
  // Controllers for ALL_USERS fields
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController careCenterNameController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController yearsOfExperienceController = TextEditingController();
  // Controllers for SERVICES fields
  final TextEditingController aboutServiceController = TextEditingController();
  final TextEditingController pricePerHourController = TextEditingController();
  final TextEditingController noteToParentsController = TextEditingController();

  //Other state variables
  final _formKey = GlobalKey<FormState>();
  Uint8List? _profileImage; // To store the selected image (Uint8List for web)


  // Function to pick single image from gallery for profile picture
  Future<void> _pickProfileImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false, // Only allow one file for profile image
    );

    if (result != null && result.files.isNotEmpty) {
      final bytes = result.files.first.bytes;
      setState(() {
        _profileImage = bytes;
      });
    } else {
      print('No image selected.');
    }
  }


  // Function to upload image to Firebase Storage (Web Compatible)
  Future<String?> _uploadImageToFirebase(String uid, Uint8List image, String imageName) async {
    if (image == null) return null;

    try {
      final storageRef = FirebaseStorage.instance.ref().child("user_profiles/$uid/$imageName.jpg");
      final uploadTask = storageRef.putData(image);

      await uploadTask.whenComplete(() => null);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      Get.snackbar('Error', 'Failed to upload image: $e', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
  }

  // **Widget to build the input fields**
  Widget _buildInputField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Flexible( // Wrap with Flexible
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Added horizontal padding
        child: TextFormField(  // Changed to TextFormField to keep Validator
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: orange)),
            border: OutlineInputBorder(), // Added a default border
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)), // Added error border
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)), // Added focused error border
          ),
          validator: (value) { // Re-added validators from original TextFormField
            if (label == 'User Name' && (value == null || value.isEmpty)) {
              return 'Please enter a user name';
            }
            if (label == 'Email') {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
            }
            if (label == 'Password') {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
            }
            if (label == 'Phone Number') {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }
              if (value.length < 10) {
                return 'Please enter a valid phone number';
              }
            }
            if (label == 'Address' && (value == null || value.isEmpty)) {
              return 'Please enter an address';
            }
            return null;
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center( // Added Center Widget
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700), // Apply max width
        padding: const EdgeInsets.all(16.0), // Add some padding around the form
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Selection
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    backgroundImage: _profileImage != null ? MemoryImage(_profileImage!) : null,
                    child: _profileImage == null ? Icon(Icons.camera_alt, size: 40, color: Colors.white) : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Common Fields (for both User and Pro)
              Row(
                children: [
                  _buildInputField('User Name', userNameController),
                  _buildInputField('Email', emailController),
                ],
              ),
              _buildInputField('Password', passwordController),
              _buildInputField('Phone Number', numberController, isNumber: true),
              _buildInputField('Address', addressController),

              const SizedBox(height: 24), // Add some spacing before the buttons

              // Wrap the actions in a Row and use MainAxisAlignment.end
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton( // Use ElevatedButton for the "Add" button
                    style: ElevatedButton.styleFrom(backgroundColor: orange),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // 1. Create User in Firebase Authentication
                          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );

                          // 2.  Get the UID
                          String uid = userCredential.user!.uid;

                          // 3. Upload Profile Image and Get URL
                          String? profilePicURL = await _uploadImageToFirebase(uid, _profileImage!, 'profile');


                          // 5.  Data for all_users Collection
                          Map<String, dynamic> allUsersData = {
                            'user_name': userNameController.text.trim(),
                            'uid': uid,
                            'role': 'user', // Fixed role for user
                            'profile_pic': profilePicURL ?? '',
                            'number': numberController.text.trim(),
                            'is_suspended': false,
                            'is_deleted': false,
                            'fcm_token': '',
                            'email': emailController.text.trim(),
                            'address': addressController.text.trim(),
                            'account_approved': false, // Default value
                            'details_complete': true, // Since all fields are added
                            'disapprove_reason': '',
                            'registration_number': "",
                            'years_of_experience': 0, // Convert to integer
                            'service_added': false,
                            'createdAt': FieldValue.serverTimestamp(), // Use server timestamp
                            'category': "",
                            'care_center_name':"",
                            'savedServices': [], // Initialize as empty array
                          };

                          // 6. Create all_users document
                          await FirebaseFirestore.instance.collection('all_users').doc(uid).set(allUsersData);

                          Navigator.of(context).pop(); // Close the dialog
                          Get.snackbar('Success', 'User added successfully', snackPosition: SnackPosition.BOTTOM);

                        } on FirebaseAuthException catch (e) {
                          print("Firebase Auth Error: ${e.code} - ${e.message}");
                          Get.snackbar('Error', 'Firebase Authentication Error: ${e.message}', snackPosition: SnackPosition.BOTTOM);
                        } catch (e) {
                          print("Firestore Error: $e");
                          Get.snackbar('Error', 'Failed to add pro: $e', snackPosition: SnackPosition.BOTTOM);
                        }
                      }
                    },
                    child: const Text('Add', style: TextStyle(color: darkBlue)), // Set the text color to darkBlue
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}