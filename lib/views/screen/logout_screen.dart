import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instaclone_app/views/screen/registesion_and_login/login_screen.dart';
import '../../controller/login_and_registesion_service/registesion_and_login_controller.dart';

class LogoutScreen extends StatelessWidget {
  final AuthService _authService = Get.find();

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await _authService.logout();
      Get.offAll(InstaCloneLogin());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("cancel",style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.logout,
                size: 100,
                color: Colors.black,
              ),
              SizedBox(height: 20),
              const Text(
                'You are about to log out.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showLogoutConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 74, vertical: 12),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                ),
                child: Text('Logout',style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}