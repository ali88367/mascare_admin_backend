import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mascare_admin_backend/SideBar/sidebar.dart';
import 'package:mascare_admin_backend/SideBar/sidebar_controller.dart';
import 'package:mascare_admin_backend/chat/messages.dart';
import 'package:mascare_admin_backend/pro_approve.dart';
import 'package:mascare_admin_backend/pro_reviews.dart';
import '../add_event.dart';
import '../advertisment.dart';
import '../advertisments_lists.dart';
import '../bookings.dart';
import '../chat/inbox.dart';
import '../events.dart';
import '../reports.dart';
import '../services.dart';
import '../user_details.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final SidebarController sidebarController = Get.put(SidebarController());
  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context)!.size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if(sidebarController.showsidebar.value ==true) {
            sidebarController.showsidebar.value =false;
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                width>=768?ExampleSidebarX():SizedBox.shrink(),
                Expanded(
                    child: Obx(() => sidebarController.selectedindex.value == 0
                        ? UserDetails()
                        : sidebarController.selectedindex.value == 1
                        ? ProApprove()
                        : sidebarController.selectedindex.value == 2
                        ? Events()
                        : sidebarController.selectedindex.value == 3
                        ? AddEvent()
                        : sidebarController.selectedindex.value == 4
                        ? AddAdvertisement()
                        : sidebarController.selectedindex.value == 5
                        ? Bookings()
                        : sidebarController.selectedindex.value == 6
                        ? AdvertisementList()
                        : sidebarController.selectedindex.value == 7
                        ? Reports()
                        : sidebarController.selectedindex.value == 8
                        ? UserInbox()
                        : sidebarController.selectedindex.value == 9
                        ? ProReviews()

                        : UserDetails()))
              ],
            ),
            Obx(()=>sidebarController.showsidebar.value == true? ExampleSidebarX():SizedBox.shrink(),)

          ],
        ),
      ),
    );
  }
}
