import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/SideBar/sidebar_controller.dart';
import 'package:sidebarx/sidebarx.dart';

import '../colors.dart';
import '../widgets/custom_button.dart';

class ExampleSidebarX extends StatefulWidget {

  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: darkBlue,
          title: Text('Logout', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            CustomButton(
              color: Colors.transparent,
              width: 100,
              height: 40,
              text: 'No',
              textColor: orange,
              onPressed: () {
                sidebarController.selectedindex.value = 0;
                Navigator.of(context).pop();
              },
            ),
            CustomButton(
              width: 100,
              height: 40,
              text: 'Yes',
              onPressed: () async {
                // Handle logout logic here
              },
            ),
          ],
        );
      },
    );
  }

  final SidebarController sidebarController = Get.put(SidebarController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SidebarController>(
      builder: (sidebarController) {
        return SidebarX(
          controller: sidebarController.controller,
          theme: SidebarXTheme(
            hoverTextStyle: TextStyle(color: orange),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            hoverColor: Colors.white.withOpacity(0.1),  // Subtle white hover
            textStyle: TextStyle(color: Colors.white70, fontSize: 18),
            selectedTextStyle: TextStyle(color: orange, fontSize: 18, fontWeight: FontWeight.bold),
            itemTextPadding: const EdgeInsets.only(left: 10),
            selectedItemTextPadding: const EdgeInsets.only(left: 10),
            itemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white30),
            ),
            selectedItemDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: orange),
              color: darkBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                )
              ],
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
              size: 20,
            ),
            selectedIconTheme: IconThemeData(
              color: orange,
              size: 20,
            ),
          ),
          extendedTheme: SidebarXTheme(
            width: 200,
            decoration: BoxDecoration(
              color: darkBlue,
            ),
          ),
          footerDivider: Divider(color: Colors.white30),
          headerBuilder: (context, extended) {
            return Column(
              children: [
                SizedBox(height: 20),
                Obx(() => sidebarController.showsidebar.value
                    ? Align(
                  alignment: Alignment.topRight,
                  child: Icon(Icons.clear_sharp, color: orange),
                )
                    : SizedBox.shrink()),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ],
            );
          },
          items: [
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 0,
              icon: Icons.person,
              label: 'User Data',
            ),
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 1,
              icon: Icons.person,
              label: 'Approve Pro',
            ),
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 2,
              icon: Icons.book,
              label: 'Events',
            ),
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 3,
              icon: Icons.event,
              label: 'Add Events',
            ),
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 4,
              icon: Icons.campaign,              label: 'Advertisement',
            ),
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 5,
              icon: Icons.build,
              label: 'Bookings',
            ),
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 6,
              icon: Icons.design_services_rounded,
              label: 'Services',
            ),
            SidebarXItem(
              onTap: () => sidebarController.selectedindex.value = 7,
              icon: Icons.design_services_rounded,
              label: 'Reports',
            ),
            SidebarXItem(
              onTap: () {
                sidebarController.selectedindex.value = 0;
                sidebarController.controller = SidebarXController(selectedIndex: 0, extended: true);
                sidebarController.update();
                _showLogoutDialog();
              },
              icon: Icons.logout,
              label: 'Log out',
            ),
          ],
        );
      },
    );
  }
}