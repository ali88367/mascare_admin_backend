import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart'; // Make sure to keep this import if you use it.

import 'SideBar/sidebar_controller.dart';
import 'widgets/InputField.dart';
import 'colors.dart';
import 'widgets/custom_button.dart';

class UserDetails extends StatefulWidget {
  UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final SidebarController sidebarController = Get.put(SidebarController());
  String searchQuery = '';

  // Static data instead of Firebase
  List<Map<String, dynamic>> usersData = [
    {
      'uid': '1',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'role': 'Admin',
      'profileImageUrl': 'https://via.placeholder.com/150',
    },
    {
      'uid': '2',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'role': 'User',
      'profileImageUrl': null,
    },
    {
      'uid': '3',
      'name': 'Peter Jones',
      'email': 'peter.jones@example.com',
      'role': 'Guest',
      'profileImageUrl': null,
    },
    // Add more static user data as needed
  ];


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final TextEditingController _roleController = TextEditingController();


  Future<void> _deleteUser(String userId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            CustomButton(
              color: Colors.transparent,
              width: 100,
              height: 40,
              text: 'Cancel',
              textColor: Colors.red,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CustomButton(
              width: 100,
              height: 40,
              text: 'Delete',
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        usersData.removeWhere((user) => user['uid'] == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );

    }
  }

  Future<void> _editUser(String userId, String currentName, String currentEmail,
      String currentRole) async {
    String? updatedName = currentName;
    String? updatedEmail = currentEmail;
    String selectedRole = currentRole;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text('Edit User'),
          content: SizedBox(
            height: 200,
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InputField(
                  onChanged: (value) {
                    updatedName = value;
                  },
                  hint: 'Name',
                  keyboard: TextInputType.text,
                  controller: TextEditingController(text: currentName),
                ),
                const SizedBox(
                  height: 20,
                ),
                InputField(
                  onChanged: (value) {
                    updatedEmail = value;
                  },
                  hint: 'Email',
                  keyboard: TextInputType.text,
                  controller: TextEditingController(text: currentEmail),
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: backgroundColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 10.0,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColorKom),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColorKom),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColorKom),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  hint: Text( // Replaced AsulCustomText with Text
                    '[role]',
                    style: TextStyle(color: Colors.black), // Added a basic style
                  ),
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    selectedRole = newValue ?? currentRole;
                  },
                  items: <String>['Admin', 'User', 'Guest']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value), // Replaced AsulCustomText with Text
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            CustomButton(
              color: Colors.transparent,
              width: 100,
              height: 40,
              text: 'Cancel',
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CustomButton(
              width: 100,
              height: 40,
              text: 'Update',
              onPressed: () async {
                setState(() {
                  final index = usersData.indexWhere((user) => user['uid'] == userId);
                  if (index != -1) {
                    usersData[index]['name'] = updatedName;
                    usersData[index]['email'] = updatedEmail;
                    usersData[index]['role'] = selectedRole;
                  }
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width<380?5:width < 425
              ? 15 // You can specify the width for widths less than 425
              : width < 768
              ? 20 // You can specify the width for widths less than 768
              : width < 1024
              ? 70 // You can specify the width for widths less than 1024
              : width <= 1440
              ? 60
              : width > 1440 && width <= 2550
              ? 60
              : 80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Get.width < 768
                ? GestureDetector(
                onTap: () {
                  sidebarController.showsidebar.value = true;
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child:Icon(Icons.menu)
                ))
                : const SizedBox.shrink(),
            SizedBox(
              height: width < 425
                  ? 20 // You can specify the width for widths less than 425
                  : width < 768
                  ? 20 // You can specify the width for widths less than 768
                  : width < 1024
                  ? 80 // You can specify the width for widths less than 1024
                  : width <= 1440
                  ? 80
                  : width > 1440 && width <= 2550
                  ? 80
                  : 80,
            ),
            Center(
              child: SizedBox(
                width: width < 425
                    ? 250 // You can specify the width for widths less than 425
                    : width < 768
                    ? 350 // You can specify the width for widths less than 768
                    : width < 1024
                    ? 400 // You can specify the width for widths less than 1024
                    : width <= 1440
                    ? 500
                    : width > 1440 && width <= 2550
                    ? 500
                    : 800,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery =
                          value.toLowerCase(); // Ensure case-insensitive search
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: secondaryColor,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width < 425
                  ? 20 // You can specify the width for widths less than 425
                  : width < 768
                  ? 20 // You can specify the width for widths less than 768
                  : width < 1024
                  ? 40 // You can specify the width for widths less than 1024
                  : width <= 1440
                  ? 100
                  : width > 1440 && width <= 2550
                  ? 100
                  : 80,vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: width < 425
                        ? 40 :
                    width<500?40// You can specify the width for widths less than 425
                    // You can specify the width for widths less than 425
                        : width < 768
                        ? 40 // You can specify the width for widths less than 768
                        : width < 1024
                        ? 40 // You can specify the width for widths less than 1024
                        : width <= 1440
                        ? 50
                        : width > 1440 && width <= 2550
                        ? 50
                        : 80,
                  ),
                  Expanded(
                    child: Text( // Replaced AsulCustomText with Text
                      'Name',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text( // Replaced AsulCustomText with Text
                      'Email',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text( // Replaced AsulCustomText with Text
                      'Role',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: width < 425
                        ? 40:
                    width<500?40// You can specify the width for widths less than 425
                        : width < 768
                        ? 90 // You can specify the width for widths less than 768
                        : width < 1024
                        ? 90 // You can specify the width for widths less than 1024
                        : width <= 1440
                        ? 80
                        : width > 1440 && width <= 2550
                        ? 80
                        : 80,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: usersData.length,
                itemBuilder: (context, index) {
                  final user = usersData[index];
                  if (!user['name'].toString().toLowerCase().contains(searchQuery)) {
                    return const SizedBox.shrink(); // Skip users that don't match the search query
                  }
                  return Padding(
                    padding:  EdgeInsets.symmetric(horizontal:width<380?5: width < 425
                        ? 15 // You can specify the width for widths less than 425
                        : width < 768
                        ? 20 // You can specify the width for widths less than 768
                        : width < 1024
                        ? 20 // You can specify the width for widths less than 1024
                        : width <= 1440
                        ? 90
                        : width > 1440 && width <= 2550
                        ? 90
                        : 80,),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // const SizedBox(width: 30),
                            Container(
                              width: width < 425
                                  ? 40 // You can specify the width for widths less than 425
                                  : width < 768
                                  ? 40 // You can specify the width for widths less than 768
                                  : width < 1024
                                  ? 50 // You can specify the width for widths less than 1024
                                  : width <= 1440
                                  ? 50
                                  : width > 1440 && width <= 2550
                                  ? 50
                                  : 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: user['profileImageUrl'] != null
                                    ? Colors.transparent
                                    : Colors.red,
                              ),
                              child: user['profileImageUrl'] != null
                                  ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                    user['profileImageUrl']),
                              )
                                  : const Icon(Icons.person,
                                  color: Colors.white),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: width < 425
                                    ? 20 // You can specify the width for widths less than 425
                                    : width < 768
                                    ? 20 // You can specify the width for widths less than 768
                                    : width < 1024
                                    ? 50 // You can specify the width for widths less than 1024
                                    : width <= 1440
                                    ? 50
                                    : width > 1440 &&
                                    width <= 2550
                                    ? 50
                                    : 80,
                                child: Text(  // Replaced AsulCustomText with Text
                                  user['name']?.isNotEmpty == true
                                      ? user['name']
                                      : user['name'] ?? '',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: width < 425
                                      ? 14
                                      : width < 768
                                      ? 16
                                      : width < 1024
                                      ? 15
                                      : width <= 1440
                                      ? 18
                                      : width > 1440 && width <= 2550
                                      ? 18
                                      : 30),
                                ),
                              ),
                            ),
                            Expanded(
                                child: SizedBox(
                                  width: width < 425
                                      ? 20 // You can specify the width for widths less than 425
                                      : width < 768
                                      ? 20 // You can specify the width for widths less than 768
                                      : width < 1024
                                      ? 50 // You can specify the width for widths less than 1024
                                      : width <= 1440
                                      ? 80
                                      : width > 1440 && width <= 2550
                                      ? 80
                                      : 80,
                                  child: Text( // Replaced AsulCustomText with Text
                                    user['email'] ?? '',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: width < 425
                                        ? 14
                                        : width < 768
                                        ? 16
                                        : width < 1024
                                        ? 15
                                        : width <= 1440
                                        ? 18
                                        : width > 1440 && width <= 2550
                                        ? 18
                                        : 30),
                                  ),
                                )),
                            Expanded(
                                child: Text( // Replaced AsulCustomText with Text
                                  user['role'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: width < 425
                                      ? 14
                                      : width < 768
                                      ? 16
                                      : width < 1024
                                      ? 15
                                      : width <= 1440
                                      ? 18
                                      : width > 1440 && width <= 2550
                                      ? 18
                                      : 30),
                                )),
                            width < 500
                                ? Column(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _editUser(
                                      user['uid'],
                                      user['name'] ?? '',
                                      user['email'] ?? '',
                                      user['role'] ?? '',
                                    );
                                  },
                                  iconSize: 25,
                                  icon: const Icon(Icons.edit),
                                  color: primaryColorKom,
                                ),
                                IconButton(
                                  onPressed: () {
                                    _deleteUser(user['uid']);
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  iconSize: 25,

                                ),
                              ],
                            )
                                : Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _editUser(
                                      user['uid'],
                                      user['name'] ?? '',
                                      user['email'] ?? '',
                                      user['role'] ?? '',
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  iconSize: 25,
                                  color: primaryColorKom,
                                ),
                                IconButton(
                                  onPressed: () {
                                    _deleteUser(user['uid']);
                                  },
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  iconSize: 25,
                                ),
                              ],
                            ),

                            // const SizedBox(width: 80),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
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