import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../colors.dart';
import 'chat_controller.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key, required this.user_id}) : super(key: key);

  final String user_id;

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final InstantChatController instant_chatVM = Get.find<InstantChatController>(); // find here
  final ChatController chatVM = Get.put(ChatController());
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the InstantChatController here using Get.find<>()
    // The important part here is that you MUST initialize
    // this controller before it is used
      instant_chatVM.getUserData(widget.user_id);
      chatVM.messageSeen(widget.user_id);
  }

  @override
  void dispose() {
    super.dispose();
    chatVM.messageSeen(widget.user_id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard
        },
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (instant_chatVM.isLoading.value) {
                  // Show a loading indicator while user data is loading
                  return Center(child: CircularProgressIndicator(color: darkBlue));
                } else {
                  // Only build the StreamBuilder when the user data is loaded
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("all_chats")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("user_chats")
                        .doc(widget.user_id)
                        .collection("chats")
                        .orderBy("sent_at", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: darkBlue));
                      } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "Say Hi to ${instant_chatVM.user_name.value}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkBlue,
                            ),
                          ),
                        );
                      } else if (snapshot.hasData){
                        final messages = snapshot.data!.docs.where((message) {
                          return !message["deleted_by_sender"] ||
                              message["from_id"] !=
                                  FirebaseAuth.instance.currentUser!.uid;
                        }).toList();

                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final messageData = messages[index]; // Store the message data

                            return GestureDetector(
                              child: messageData["from_id"] ==
                                  FirebaseAuth.instance.currentUser!.uid
                                  ? buildUserMessage(messageData["message"] ?? "") // Provide a default value
                                  : buildSupportMessage(messageData["message"] ?? ""), // Provide a default value
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            "Say Hi to ${instant_chatVM.user_name.value}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkBlue,
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              }),
            ),
            Obx(() {
              return instant_chatVM.is_deleted.value == true
                  ? Container(
                margin: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                    "The Accout has been deleted.\nYou no longer can send messages."),
              )
                  : _buildMessageInput();
            }),
          ],
        ),
      ),
    );
  }

  Widget buildSupportMessage(String message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 10),
          Obx(
                () =>
                CircleAvatar(
                  radius: 25,
                  backgroundImage: instant_chatVM.profile_pic.value != ""
                      ? NetworkImage(instant_chatVM.profile_pic.value)
                      : null,
                  backgroundColor: darkBlue.withOpacity(.2),
                  child: instant_chatVM.profile_pic.value == ""
                      ? Icon(Icons.person, size: 30, color: darkBlue)
                      : SizedBox(),
                ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: darkBlue, // Support bubble color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserMessage(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 220, // Limit the message bubble width to 220
          ),
          child: Container(
            padding: EdgeInsets.all(14),
            margin: EdgeInsets.only(bottom: 10, right: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black, width: 0.5)),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      height: 79.8,
      width: double.infinity,
      color: darkBlue,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.4),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 56.63, // Height for the container
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type message...',
                    hintStyle: TextStyle(color: Color.fromRGBO(100, 100, 100, 1)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    isDense: true, // Set isDense to true
                  ),
                  style: TextStyle(color: darkBlue),
                ),
              ),
            ),
            SizedBox(width: 11.52),
            InkWell(
              onTap: () async {
                debugPrint("message tapped");
                String message = messageController.text.trim();
                messageController.clear();
                await chatVM.sendMessage(message, widget.user_id);
              },
              child: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.white, // Send button color
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Icon(Icons.send)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstantChatController extends GetxController {
  var user_name = "".obs;
  var profile_pic = "".obs;
  var is_deleted = false.obs;
  var isLoading = true.obs; // Add isLoading

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> getUserData(String uid) async {
    isLoading.value = true;  // Set loading to true at the start
    try {
      if (uid == null) {
        debugPrint("User not logged in");
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('all_users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        user_name.value = userDoc['user_name'] ?? '';
        profile_pic.value = userDoc['profile_pic'] ?? '';
        is_deleted.value = userDoc['is_deleted'] ?? false;
      } else {
        debugPrint("User document not found.");
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      isLoading.value = false; // Set loading to false when done
    }
  }
}