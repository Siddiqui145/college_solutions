// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/router/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  String email = "", password = "";
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  String errorMessage = '';
  final _formkey = GlobalKey<FormState>();

  Future<void> signIn() async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Login Successful!",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ));
        context.router.replace(const HomeRoute());
      }
    } on FirebaseAuthException catch (e) {
      // Specific error handling based on FirebaseAuthException codes
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong password provided.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      } else {
        errorMessage = "Error: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          errorMessage,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));

      setState(() {
        errorMessage = errorMessage; // Update error message for any additional display.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _header(context),
                  _inputField(context),
                  _forgotPassword(context),
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  _signup(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _header(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          width: 200,
          child: Image.asset(
            'assets/images/user_icon.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 25),
        Text(
          "Login",
          style:
              Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Text(
          "Enter your credentials",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 25),
      ],
    );
  }

  _inputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: emailcontroller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please Enter E-Mail';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color.fromARGB(255, 96, 100, 163).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: passwordcontroller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please Enter Password';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: const Color.fromARGB(255, 96, 100, 163).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            if (_formkey.currentState!.validate()) {
              signIn(); // Call signIn to handle login logic
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.lightBlue,
          ),
          child: Text(
            "Login",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.router.push(const ResetPasswordRoute());
      },
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.blue, fontSize: 18),
      ),
    );
  }

  _signup(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            context.router.push(const SignupRoute());
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.blue, fontSize: 18),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }
}
