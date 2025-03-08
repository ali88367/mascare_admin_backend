import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'SideBar/home_main.dart';
import 'colors.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email != "admin@mascare.co.za") {
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        "Login Failed",
        "Only admin access is allowed.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Attempt Firebase authentication
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        isLoading = false;
      });

      Get.offAll(HomeMain()); // Navigate to home after successful login
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String errorMessage = "An error occurred. Please try again.";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }

      Get.snackbar(
        "Login Failed",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: darkBlue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          width <= 1440
              ? SizedBox(width: 80, height: 80, child: Image.asset('assets/images/logo.png'))
              : width > 1440 && width <= 2550
              ? SizedBox(width: 100, height: 100, child: Image.asset('assets/images/logo.png'))
              : SizedBox(width: 150, height: 150, child: Image.asset('assets/images/logo.png')),
          const SizedBox(height: 30),
          const Text(
            'Login',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTextField(emailController, Icons.mail_outline, 'Enter email'),
          const SizedBox(height: 15),
          _buildTextField(passwordController, Icons.lock, 'Password', isPassword: true),
          const SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width < 425
                ? (MediaQuery.of(context).size.width - 280) / 2
                : MediaQuery.of(context).size.width < 768
                ? (MediaQuery.of(context).size.width - 300) / 2
                : MediaQuery.of(context).size.width <= 1440
                ? (MediaQuery.of(context).size.width - 400) / 2
                : (MediaQuery.of(context).size.width - 700) / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                GestureDetector(
                  onTap: () {
                    _login(); // Call the login function
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: orange,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator(color: whiteColor))
                        : const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hintText, {bool isPassword = false}) {
    return Container(
      width: MediaQuery.of(context).size.width < 425
          ? 280
          : MediaQuery.of(context).size.width < 768
          ? 300
          : MediaQuery.of(context).size.width <= 1440
          ? 400
          : 700,
      height: 50,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: darkBlue, width: 1.5),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: controller,
        obscureText: isPassword ? !isPasswordVisible : false,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(14.0),
          prefixIcon: Icon(icon, color: darkBlue),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: darkBlue),
            onPressed: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          )
              : null,
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class UserController extends GetxController {
  var uid = ''.obs;

  void setUid(String uid) {
    this.uid.value = uid;
  }
}