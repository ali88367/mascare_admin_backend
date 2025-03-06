import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/colors.dart';
import 'package:mascare_admin_backend/SideBar/sidebar_controller.dart';
import 'package:mascare_admin_backend/chat/messages.dart';
import 'package:mascare_admin_backend/user_details_controller.dart';
import 'add_pro.dart';
import 'add_user.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final UserController userController = Get.put(UserController());
    final SidebarController sidebarController = Get.find<SidebarController>();

    return Scaffold(
      backgroundColor: darkBlue,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width < 768 ? 20 : 60,
        ),
        child:  RawScrollbar(
          thumbVisibility: true, // Always visible
          trackVisibility: true, // Track always visible
          thickness: 8, // Adjust thickness
          radius: Radius.circular(10), // Rounded edges
          scrollbarOrientation: ScrollbarOrientation.right, // Position scrollbar on the right
          interactive: true,
          thumbColor: orange,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Get.width < 768
                        ? GestureDetector(
                        onTap: () {
                          sidebarController.showsidebar.value = true;
                        },
                        child: const Padding(
                            padding: EdgeInsets.only(left: 10, top: 10,right: 20),
                            child: Icon(Icons.menu, color: Colors.white,)))
                        : const SizedBox.shrink(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: orange),
                        onPressed: () {
                          _showAddUserDialog(context);
                        },
                        child: const Text("Add User", style: TextStyle(color: darkBlue)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: width < 768 ? 350 : 500,
                    child: TextField(
                      onChanged: (value) {
                        userController.searchQuery.value = value.toLowerCase();
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
                      const SizedBox(width: 120),
                    ],
                  ),
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: userController.usersStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: orange,));
                    }

                    if (snapshot.hasError) {
                      print("Error: ${snapshot.error}");
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red),));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found.', style: TextStyle(color: Colors.white),));
                    }

                    final users = snapshot.data!;
                    final filteredUsers = userController.filterUsers(users);

                    return ListView.builder(
                      itemCount: filteredUsers.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final bool isSuspended = user['is_suspended'] ?? false;
                        final String userId = user['uid'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey,
                                        ),
                                        child: user['profile_pic'] != null && user['profile_pic']!.isNotEmpty
                                            ? ClipOval(
                                          child: Image.network(
                                            user['profile_pic'],
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.person, color: Colors.white);
                                            },
                                          ),
                                        )
                                            : const Icon(Icons.person, color: Colors.white),
                                      ),
                                      if (isSuspended)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Icon(
                                            Icons.report,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Text(
                                      user['name'] ?? '',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      user['email'] ?? '',
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          user['role'] ?? '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _showEditDialog(context, user),
                                        icon: const Icon(Icons.edit),
                                        color: Colors.blue,
                                      ),
                                      IconButton(
                                        onPressed: () => userController.deleteUser(
                                          user['uid'],
                                          user['email'],
                                          user['name'],
                                          user['number'],
                                        ),
                                        icon: const Icon(Icons.delete),
                                        color: Colors.red,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Get.to(Messages(user_id: userId));
                                        },
                                        icon: const Icon(Icons.messenger),
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              const Divider(),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> user) {
    final UserController userController = Get.find<UserController>();
    final nameController = TextEditingController(text: user['name']);
    final emailController = TextEditingController(text: user['email']);
    final bool isSuspended = user['is_suspended'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkBlue,
          title: const Text('Edit User', style: TextStyle(color: orange)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: orange), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: orange))),
                ),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: orange), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: orange))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(isSuspended ? 'Unsuspend' : 'Suspend', style: TextStyle(color: isSuspended ? Colors.green : Colors.orange)),
              onPressed: () {
                userController.toggleUserSuspension(user['uid'], isSuspended);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update', style: TextStyle(color: orange)),
              onPressed: () {
                userController.updateUser(user['uid'], nameController.text, emailController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkBlue,
          title: const Text('Add User', style: TextStyle(color: orange)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: orange),
                  onPressed: (){
                    Navigator.of(context).pop();
                    Get.to(() => AddUserPage());
                  },
                  child: Text("Add User", style: TextStyle(color: darkBlue),)),
              SizedBox(height: 10,),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: orange),
                  onPressed: (){
                    Navigator.of(context).pop();
                    Get.to(() => AddProPage());
                  },
                  child: Text("Add Pro", style: TextStyle(color: darkBlue),))
            ],
          ),
        );
      },
    );
  }

}