import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/router/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          context.router.replace(const HomeRoute());
        } else {
          context.router.replace(const LoginRoute());
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Image.asset('assets/images/splash_image.gif')),
    );
  }
}
