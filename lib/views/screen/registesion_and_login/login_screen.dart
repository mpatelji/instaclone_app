import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaclone_app/views/screen/registesion_and_login/registesion_screen.dart';
import '../../../controller/login_and_registesion_service/registesion_and_login_controller.dart';
import '../../../costumazation_widgets/widgets_customazation/custumazation_widgets.dart';
import '../home_screen.dart';

class InstaCloneLogin extends StatefulWidget {
  const InstaCloneLogin({super.key});

  @override
  State<InstaCloneLogin> createState() => _InstaCloneLoginState();
}

class _InstaCloneLoginState extends State<InstaCloneLogin> with WidgetCustomization {
  final authController = Get.put(AuthService());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  RxBool isPasswordVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Form(
          key: _formKey, // Form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                child: Center(
                  child: Text(
                    "Login Here",
                    style: GoogleFonts.aclonica(
                      textStyle: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              viewTextField(
                'Email',
                emailController,
                prefixIcon: const Icon(Icons.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              Obx(() {
                return viewTextField(
                  'Password',
                  passwordController,
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: !isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      isPasswordVisible.value = !isPasswordVisible.value;
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                );
              }),
              const SizedBox(height: 30),
              Obx(() {
                return authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : viewButton(
                  'Login',
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      bool loginSuccess = await authController.loginWithEmailPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      if (loginSuccess) {
                        Get.to(() =>  HomeScreen());
                      } else {
                        Get.to(() => const RegisterScreen());
                      }
                    }
                  },
                );
              }),
              const SizedBox(height: 80),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Don't have an account? ",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    TextSpan(
                      text: 'Sign up here',
                      style: const TextStyle(
                          color: Colors.brown,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to(() => const RegisterScreen());
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
