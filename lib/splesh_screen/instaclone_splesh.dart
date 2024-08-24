import 'package:flutter/material.dart';

import '../views/screen/registesion_and_login/login_screen.dart';

class InstaSplaceScreen extends StatefulWidget {
  const InstaSplaceScreen({super.key});

  @override
  State<InstaSplaceScreen> createState() => _InstaSplaceScreenState();
}

class _InstaSplaceScreenState extends State<InstaSplaceScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 4));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InstaCloneLogin()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("KrisCent", style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
      ),
    );
  }
}