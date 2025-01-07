import 'package:chatbotapp/screens/login.dart';
import 'package:chatbotapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) =>  FirebaseAuth.instance.currentUser != null ? const HomeScreen() : const LoginPage(),
           
        ),
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Image.asset('assets/images/splash_image.gif')),
    );
  }
}
