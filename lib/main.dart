import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mascare_admin_backend/login.dart';
import 'chat/messages.dart';
import 'firebase_options.dart';
import 'SideBar/home_main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(InstantChatController());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mascare',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Login(),
    );
  }
}
