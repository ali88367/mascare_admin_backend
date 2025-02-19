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

  @override
  Widget build(BuildContext context) {
    final width =MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            width <= 1440
                ? SizedBox(
                width: 80,
                height: 80,
                child: Image.asset('assets/images/logo.png'))
                : width > 1440 && width <= 2550
                ? SizedBox(
                width: 100,
                height: 100,
                child: Image.asset('assets/images/logo.png'))
                : SizedBox(
                width: 150,
                height: 150,
                child: Image.asset('assets/images/logo.png')),
            const SizedBox(
              height: 30,
            ),
            const Text('Login'),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: width < 425
                  ? 280 // You can specify the width for widths less than 425
                  : width < 768
                  ? 300 // You can specify the width for widths less than 768
                  : width <= 1440
                  ? 400
                  : width > 1440 && width <= 2550
                  ? 400
                  : 700,

              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.black),
                controller: emailController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(14.0),
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: Color(0xFF264653),
                  ),
                  hintText: 'Enter email',
                  border: InputBorder.none, // Remove the default underline border
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width:width < 425
                    ? 280 // You can specify the width for widths less than 425
                    : width < 768
                    ? 300 // You can specify the width for widths less than 768
                    : width <= 1440
                    ? 400
                    : width > 1440 && width <= 2550
                    ? 400
                    : 700,

                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(14.0),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF264653)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color(0xFF264653),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    hintText: 'Password',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(

            'Login',
                ),
                SizedBox(width: width < 425
                    ? 170 // You can specify the width for widths less than 425
                    : width < 768
                    ? 190 // You can specify the width for widths less than 768
                    : width <= 1440
                    ? 300
                    : width > 1440 && width <= 2550
                    ? 300
                    : 700,
                ),
                GestureDetector(
                  onTap: (){
                    Get.to(HomeMain());
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        // valueColor: AlwaysStoppedAnimation<Color>(primaryColorKom),
                      ),
                    )
                        : Icon(Icons.arrow_forward_ios)
                  ),
                ),

              ],
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ));
  }
}

class UserController extends GetxController {
  var uid = ''.obs;

  void setUid(String uid) {
    this.uid.value = uid;
  }
}
