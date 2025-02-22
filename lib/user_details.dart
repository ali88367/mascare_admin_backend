import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'SideBar/sidebar_controller.dart';
import 'colors.dart';
import 'widgets/custom_button.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({Key? key}) : super(key: key);

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final SidebarController sidebarController = Get.put(SidebarController());
  String searchQuery = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> usersData = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('all_users').get();
      setState(() {
        usersData = querySnapshot.docs.map((doc) {
          return {
            'uid': doc.id,
            'email': doc['email'] as String? ?? '',
            'role': doc['role'] as String? ?? '',
            'name': doc['user_name'] as String? ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching users: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch users: $e')),
      );
    }
  }

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
      try {
        await _firestore.collection('users').doc(userId).delete();
        setState(() {
          usersData.removeWhere((user) => user['uid'] == userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      } catch (e) {
        print("Error deleting user: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $e')),
        );
      }
    }
  }

  Future<void> _editUser(
      String userId, String currentName, String currentEmail, String currentRole) async {
    String? updatedName = currentName;
    String? updatedEmail = currentEmail;
    String selectedRole;

    // Ensure selectedRole is a valid value, defaulting to 'User' if not.
    if (['Admin', 'User', 'Guest'].contains(currentRole)) {
      selectedRole = currentRole;
    } else {
      selectedRole = 'User'; // Default value
      print("Warning: Invalid role '$currentRole' found in Firebase. Using default 'User'.");
    }

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
                TextFormField(
                  initialValue: currentName,
                  decoration: const InputDecoration(hintText: 'Name'),
                  onChanged: (value) => updatedName = value,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: currentEmail,
                  decoration: const InputDecoration(hintText: 'Email'),
                  onChanged: (value) => updatedEmail = value,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  dropdownColor: backgroundColor,
                  decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder()),
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    selectedRole = newValue ?? 'User'; // Fallback within onChanged too.
                  },
                  items: <String>['Admin', 'User', 'Guest']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
              onPressed: () => Navigator.of(context).pop(),
            ),
            CustomButton(
              width: 100,
              height: 40,
              text: 'Update',
              onPressed: () async {
                try {
                  await _firestore.collection('users').doc(userId).update({
                    'user_name': updatedName,
                    'email': updatedEmail,
                    'role': selectedRole,
                  });

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
                } catch (e) {
                  print("Error updating user: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update user: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
                    child: Icon(Icons.menu)))
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: width < 768 ? 350 : 500,
                child: TextField(
                  onChanged: (value) {
                    setState(() => searchQuery = value.toLowerCase());
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: orange),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(10))),
                    prefixIcon: Icon(Icons.search, color: orange),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Name',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: orange),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Email',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: orange),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Role',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: orange),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 80),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: usersData.length,
                itemBuilder: (context, index) {
                  final user = usersData[index];
                  if (!user['name'].toString().toLowerCase().contains(searchQuery)) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            Expanded(
                              child: Text(
                                user['name'] ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16,color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                user['email'] ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16,color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                user['role'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16,color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => _editUser(
                                    user['uid'],
                                    user['name'] ?? '',
                                    user['email'] ?? '',
                                    user['role'] ?? '',
                                  ),
                                  icon: const Icon(Icons.edit),
                                  color: blackColor,
                                ),
                                IconButton(
                                  onPressed: () => _deleteUser(user['uid']),
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        const Divider(),
                        SizedBox(height: 10,),

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