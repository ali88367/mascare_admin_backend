import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'messages.dart';

// Define your color palette here (or import from a separate file if you prefer)
const Color blueColor = Color(0xFF007BFF); // Example Blue color
const Color textColor = Colors.grey; // Example Grey color

class UserInbox extends StatefulWidget {
  const UserInbox({super.key});

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> {
  final ChatWidgetController widgetVM = Get.put(ChatWidgetController());
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = "".obs; // Stores the search query dynamically

  // Define your height and width extensions or methods here.
  // Since we're removing screen_utils, we need alternatives.
  double h(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.height * (percentage / 100);

  double w(BuildContext context, double percentage) =>
      MediaQuery.of(context).size.width * (percentage / 100);

  double sp(BuildContext context, double fontSize) => fontSize; // Basic fontSize

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(h(context, 18)),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w(context, 4)),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: h(context, 1)),
                    Center(
                      child: Text(
                        "Inbox",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sp(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: h(context, 3)),
                    // Search Bar with dynamic filtering
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        searchQuery.value = value.toLowerCase(); // Update search query
                      },
                      style: const TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: sp(context, 15.36),
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(13.0),
                          child: SizedBox(
                            height: h(context, 3),
                            width: w(context, 6),
                            child: Icon(Icons.search),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: h(context, 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: w(context, 4)),
          child: Column(
            children: [
              SizedBox(height: h(context, 3)),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("all_chats")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection("user_chats")
                      .orderBy("time_stamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(color: blueColor),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "An Error occurred",
                          style: TextStyle(fontSize: sp(context, 16), color: blueColor, fontWeight: FontWeight.w500),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No Chats",
                          style: TextStyle(fontSize: sp(context, 16), color: blueColor, fontWeight: FontWeight.w500),
                        ),
                      );
                    }

                    var chats = snapshot.data!.docs;

                    return Obx(() {
                      var filteredChats = chats.where((chat) {
                        final chatId = chat.id;
                        final controller = Get.put(ChatWidgetController(), tag: chatId);
                        return controller.user_name.value.toLowerCase().contains(searchQuery.value);
                      }).toList();

                      if (filteredChats.isEmpty) {
                        return Center(
                          child: Text(
                            "No Matching Chats",
                            style: TextStyle(fontSize: sp(context, 16), color: blueColor, fontWeight: FontWeight.w500),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredChats.length,
                        itemBuilder: (context, index) {
                          final chatItem = filteredChats[index];
                          final chatId = chatItem.id;

                          Get.put(ChatWidgetController(), tag: chatId);
                          return chatWidget(chatId, chatItem.id, context);
                        },
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatWidget(String tag, String userId, BuildContext context) {
    final controller = Get.find<ChatWidgetController>(tag: tag);
    controller.getChatDetail(userId);

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.to(Messages(user_id: userId));
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: h(context, 1.5)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Obx(
                            () => CircleAvatar(
                          radius: 23,
                          backgroundImage: controller.profile_pic.value.isNotEmpty
                              ? NetworkImage(controller.profile_pic.value)
                              : null,
                          backgroundColor: blueColor.withOpacity(.1),
                          child: controller.profile_pic.value.isEmpty
                              ? Icon(Icons.person, size: w(context, 7), color: blueColor)
                              : const SizedBox(),
                        ),
                      ),
                      SizedBox(width: w(context, 2.5)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                                  () => Text(
                                controller.user_name.value,
                                style: TextStyle(fontSize: sp(context, 14), fontWeight: FontWeight.w600, color: Colors.black),
                              ),
                            ),
                            SizedBox(height: h(context, 0.4)),
                            Obx(
                                  () => SizedBox(
                                width: double.infinity,
                                child: Text(
                                  controller.last_message.value,
                                  style: TextStyle(fontSize: sp(context, 12), color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  if (controller.last_sender.value != FirebaseAuth.instance.currentUser!.uid && !controller.seen.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: w(context, 3.5),
                          height: h(context, 1.7),
                          decoration: const BoxDecoration(
                            color: blueColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              controller.total_received.value,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: sp(context, 9)),
                            ),
                          ),
                        ),
                        SizedBox(height: h(context, 1.2)),
                        Text(
                          controller.time_stamp.value,
                          style: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: sp(context, 9)),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: Text(
                        controller.time_stamp.value,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w400, fontSize: sp(context, 9)),
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
        Divider(color: Colors.grey.withOpacity(0.4), thickness: 1),
      ],
    );
  }
}


class ChatWidgetController extends GetxController {
  /// Chat Details Variables
  var last_message = "".obs;
  var total_received = "".obs;
  var time_stamp = "".obs;
  var last_sender = "".obs;
  var seen = false.obs;

  /// Chat User Detail
  var profile_pic = "".obs;
  var user_name = "".obs;

  Future<void> getChatDetail (String widget_id) async {
    try {

      var chat_detail = await FirebaseFirestore.instance.collection("all_chats").doc(widget_id).collection("user_chats").doc(FirebaseAuth.instance.currentUser!.uid).get();

      var chat_user_detail = await FirebaseFirestore.instance.collection("all_users").doc(widget_id).get();

      profile_pic.value = chat_user_detail["profile_pic"] ?? "";
      user_name.value = chat_user_detail["user_name"] ?? "";

      last_message.value = chat_detail["last_message"] ?? "";
      total_received.value = chat_detail["total_received"].toString() ?? "";
      time_stamp.value = formatServerTimestamp(chat_detail["time_stamp"] ?? "");
      last_sender.value = chat_detail["last_sender"] ?? "";
      seen.value = chat_detail["seen"] ?? false;

      // var chat_user_detail = await FirebaseFirestore.instance.collection("all_users").doc(widget_id).get();

      profile_pic.value = chat_user_detail["profile_pic"] ?? "";
      user_name.value = chat_user_detail["user_name"] ?? "";

    } catch (e) {
      debugPrint("Error fetching chats  ${widget_id}: $e");
    }
  }

  String formatServerTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "...";

    DateTime date = timestamp.toDate();
    return DateFormat('MMM d, y').format(date);
  }
}