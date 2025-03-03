import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';


class ChatController extends GetxController {
//  final NotificationController notificationVM = Get.put(NotificationController());

  RxBool loading = false.obs;

  Future<void> sendMessage( String msg, String receiverId) async {
    try {
      // Check if the current user is authenticated and receiver ID is not empty
      loading.value = true;
      if (FirebaseAuth.instance.currentUser == null || receiverId == "") {
        loading.value = false;
        throw Exception("User not authenticated or receiver ID is empty");
      }

      // Generate a unique message ID
      final messageId = UniqueKey().toString(); // Use UniqueKey to generate a unique ID

      // Generate timestamp for the message
      final time = FieldValue.serverTimestamp();

      // Get references to sender and receiver documents
      final senderDocRef = FirebaseFirestore.instance.collection("all_chats").doc(FirebaseAuth.instance.currentUser!.uid);
      final receiverDocRef = FirebaseFirestore.instance.collection("all_chats").doc(receiverId);

      await senderDocRef.set({
        "id": FirebaseAuth.instance.currentUser!.uid,
      });

      // Create references for new message documents
      final senderMessageDocRef = senderDocRef.collection("user_chats").doc(receiverId).collection("chats").doc(messageId);
      final receiverMessageDocRef = receiverDocRef.collection("user_chats").doc(FirebaseAuth.instance.currentUser!.uid).collection("chats").doc(messageId);

      // Create a MessageModel object for sender
      var senderMessage = {
        "message": msg,
        "message_id": messageId,
        "sent_at": time,
        "sent_to_id": receiverId,
        "from_id": FirebaseAuth.instance.currentUser!.uid,
        "read": false, // Assuming this is for marking messages as read; adjust as needed
        "deleted_by_sender": false,
      };
      loading.value = false;

      // Create a MessageModel object for receiver
      var receiverMessage = {
        "message": msg,
        "message_id": messageId,
        "sent_at": time,
        "sent_to_id": receiverId,
        "from_id": FirebaseAuth.instance.currentUser!.uid,
        "deleted_by_sender": false,
      };

      // Check if total_received field exists
      var receiverDoc = await FirebaseFirestore.instance.collection("all_chats").doc(receiverId).collection("user_chats").doc(FirebaseAuth.instance.currentUser!.uid).get();
      if (!receiverDoc.exists || !receiverDoc.data()!.containsKey("total_received")) {
        await receiverDocRef.set({
          "total_received": 0,
        }, SetOptions(merge: true));
      }

      var received = 0;
      var receivedDoc = await FirebaseFirestore.instance.collection("all_chats").doc(receiverId).collection("user_chats").doc(FirebaseAuth.instance.currentUser!.uid).get();
      if (receivedDoc.exists && receivedDoc.data()!.containsKey("total_received")) {
        received = receivedDoc["total_received"] ?? 0;
      }

      received = received + 1;

      print(received);

      await senderDocRef.collection("user_chats").doc(receiverId).set({
        'time_stamp': time,
        'seen' : false,
        'last_sender': FirebaseAuth.instance.currentUser!.uid,
        "last_message": msg,
        "total_received": received,
      }, SetOptions(merge: true));

      await senderMessageDocRef.set(senderMessage);

      await receiverDocRef.collection("user_chats").doc(FirebaseAuth.instance.currentUser!.uid).set({
        'time_stamp': time,
        'seen' : false,
        'last_sender': FirebaseAuth.instance.currentUser!.uid,
        "last_message": msg,
        "total_received": received,
      }, SetOptions(merge: true));

      await receiverMessageDocRef.set(receiverMessage);

   //   notificationVM.sendChatNotification(receiverId, "Chat Notification", msg, FirebaseAuth.instance.currentUser!.uid);

      loading.value = false;

    } catch (e) {
      loading.value = false;
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> messageSeen (String receiverId) async {
    try {

      final myDocRef = await FirebaseFirestore.instance.collection("all_chats").doc(FirebaseAuth.instance.currentUser!.uid).collection("user_chats").doc(receiverId);
      final theirDocRef = await FirebaseFirestore.instance.collection("all_chats").doc(receiverId).collection("user_chats").doc(FirebaseAuth.instance.currentUser!.uid);

      var myData = await myDocRef.get();
      var theirData = await theirDocRef.get();

      if(myData["last_sender"] == receiverId){
        await myDocRef.set({'seen' : true, "total_received": 0}, SetOptions(merge: true));
      }

      if(theirData["last_sender"] == receiverId){
        await theirDocRef.set({'seen' : true, "total_received": 0}, SetOptions(merge: true));
      }

    } catch (e) {
      debugPrint('Message was not seen. $e');
    }
  }

}