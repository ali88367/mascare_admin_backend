import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'SideBar/home_main.dart';

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

  final Color darkBlue = const Color(0xFF00008B); // Dark Blue
  final Color white = Colors.white; // White
  final Color orange = const Color(0xFFFF8C00); // Orange

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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(
                width: width < 425
                    ? 170
                    : width < 768
                    ? 190
                    : width <= 1440
                    ? 300
                    : width > 1440 && width <= 2550
                    ? 300
                    : 700,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isLoading = true;
                  });
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      isLoading = false;
                    });
                    Get.to(HomeMain());
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: orange, // Orange button color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator(color: white))
                      : const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              ),
            ],
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
        color: white,
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
