// import 'dart:io';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:instaclone_app/views/screen/home_screen.dart';
// import '../../../controller/login_and_registesion_service/registesion_and_login_controller.dart';
// import '../../../controller/videeo_service/videos_service.dart';
// import '../../../costumazation_widgets/widgets_customazation/custumazation_widgets.dart';
// import 'login_screen.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> with WidgetCustomization {
//   final AuthService authController = Get.find<AuthService>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();
//   File? _profileImage;
//   RxBool isPasswordVisible = false.obs;
//   final _formKey = GlobalKey<FormState>();
//     final VideoUploadController _videoController = Get.find<VideoUploadController>();
//
//   Future<void> _pickImage() async {
//     final pickedImage = await authController.pickProfileImage();
//     if (pickedImage != null) {
//       _profileImage = pickedImage;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: GestureDetector(
//                   onTap: _pickImage,
//                   child: _profileImage == null
//                       ? CircleAvatar(
//                     foregroundColor: Colors.grey,
//                     radius: 50,
//                     backgroundColor: Colors.grey[300],
//                     child: Icon(Icons.camera_alt, color: Colors.grey[600]),
//                   )
//                       : CircleAvatar(
//                     backgroundColor: Colors.grey,
//                     radius: 50,
//                     backgroundImage: FileImage(_profileImage!),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20),
//               viewTextField(
//                 'Name',
//                 nameController,
//                 prefixIcon: Icon(Icons.edit),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 10),
//               viewTextField(
//                 'Email',
//                 emailController,
//                 prefixIcon: Icon(Icons.email),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                     return 'Please enter a valid email address';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 10),
//               // Password TextField with visibility toggle
//               Obx(() {
//                 return viewTextField(
//                   'Password',
//                   passwordController,
//                   prefixIcon: Icon(Icons.lock),
//                   obscureText: !isPasswordVisible.value,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
//                     ),
//                     onPressed: () {
//                       isPasswordVisible.value = !isPasswordVisible.value;
//                     },
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                 );
//               }),
//               SizedBox(height: 10),
//               // Phone TextField with validator
//               viewTextField(
//                 'Phone',
//                 phoneNumberController,
//                 prefixIcon: Icon(Icons.phone),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               Obx(() {
//                 return authController.isLoading.value
//                     ? Center(child: CircularProgressIndicator())
//                     : viewButton(
//                   'Register',
//                   onPressed: () {
//                     if (_formKey.currentState?.validate() ?? false) {
//                       authController
//                           .registerWithEmailPassword(
//                         name: nameController.text,
//                         email: emailController.text,
//                         password: passwordController.text,
//                         phoneNumber: phoneNumberController.text,
//                         profileImage: _profileImage,
//                       )
//                           .then((_) {
//                             Get.to(HomeScreen());
//                       })
//                           .catchError((error) {
//                         Get.snackbar('Registration Failed', error.toString());
//                       });
//                     }
//                   },
//                 );
//               }),
//               SizedBox(height: 20),
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     Get.toNamed('/login');
//                   },
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: 'Already have an account? ',
//                           style: TextStyle(color: Colors.black, fontSize: 20),
//                         ),
//                         TextSpan(
//                           text: 'Login here',
//                           style: TextStyle(
//                               color: Colors.brown,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold),
//                           recognizer: TapGestureRecognizer()
//                             ..onTap = () {
//                               Get.to(InstaCloneLogin());
//                             },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       )
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instaclone_app/views/screen/home_screen.dart';
import '../../../controller/login_and_registesion_service/registesion_and_login_controller.dart';
import '../../../costumazation_widgets/widgets_customazation/custumazation_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with WidgetCustomization {
  final AuthService authController = Get.find<AuthService>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  File? _profileImage;
  RxBool isPasswordVisible = false.obs;
  final _formKey = GlobalKey<FormState>();
  Future<void> _pickImage() async {
    final pickedImage = await authController.pickProfileImage();
    if (pickedImage != null) {
      setState(() {
        _profileImage = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: _profileImage == null
                        ? CircleAvatar(
                      foregroundColor: Colors.grey,
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.camera_alt, color: Colors.grey[600]),
                    )
                        : CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 50,
                      backgroundImage: FileImage(_profileImage!),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                viewTextField(
                  'Name',
                  nameController,
                  prefixIcon: Icon(Icons.edit),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                viewTextField(
                  'Email',
                  emailController,
                  prefixIcon: Icon(Icons.email),
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
                SizedBox(height: 10),
                Obx(() {
                  return viewTextField(
                    'Password',
                    passwordController,
                    prefixIcon: Icon(Icons.lock),
                    obscureText: !isPasswordVisible.value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
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
                SizedBox(height: 10),
                viewTextField(
                  'Phone',
                  phoneNumberController,
                  prefixIcon: Icon(Icons.phone),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Obx(() {
                  return authController.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : viewButton(
                    'Register',
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        authController
                            .registerWithEmailPassword(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          phoneNumber: phoneNumberController.text,
                          profileImage: _profileImage,
                        )
                            .then((_) {
                          Get.to(HomeScreen());
                        }).catchError((error) {
                          Get.snackbar('Registration Failed', error.toString());
                        });
                      }
                    },
                  );
                }),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.toNamed('/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                          TextSpan(
                            text: 'Login here',
                            style: TextStyle(
                                color: Colors.brown,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(InstaCloneLogin());
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
