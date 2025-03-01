import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'colors.dart';
import 'SideBar/sidebar_controller.dart';
import 'user_details_controller.dart'; // Import the controller
import 'widgets/custom_button.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final UserController userController = Get.put(UserController()); // Initialize controller
    final SidebarController sidebarController = Get.find<SidebarController>();

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
                    child: Icon(Icons.menu,color: Colors.white,)))
                : const SizedBox.shrink(),
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
                  const SizedBox(width: 35),
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: userController.filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = userController.filteredUsers[index];
              //    print("User Data: $user"); // ADDED: Print the user data here

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
                            Expanded(
                              child: Text(
                                user['name'] ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                user['email'] ?? '',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                user['role'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
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
              )),
            ),
          ],
        ),
      ),
    );
  }
}