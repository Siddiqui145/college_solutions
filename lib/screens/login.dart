// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/router/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

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
        email: emailcontroller.text
            .trim(), // Trim to avoid leading/trailing spaces
        password: passwordcontroller.text.trim(),
      );

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Specific error handling based on FirebaseAuthException codes
      String error = '';
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "No user found for that email",
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Wrong password provided",
          style: TextStyle(fontSize: 18, color: Colors.black),
        )));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Invalid email format",
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Check the Credentials Properly",
          style: TextStyle(fontSize: 18, color: Colors.black),
        )));
      }

      setState(() {
        errorMessage = error;
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
        Image.asset('assets/images/user_icon.png', height: 135,),
        const SizedBox(height: 15,),
       const Text(
          "Diems Solution",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15,),
       const Text("Enter your credentials"),
       const SizedBox(height: 20,),
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
            fillColor: const Color.fromARGB(255, 23, 16, 239).withOpacity(0.1),
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
            fillColor: const Color.fromARGB(255, 23, 16, 239).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          //onPressed: signIn, // Call signIn function
          onPressed: () {
            if (_formkey.currentState!.validate()) {
              setState(() {
                email = emailcontroller.text;
                password = passwordcontroller.text;
                showDialog(context: context, builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Logged in"),
                    content: const Text("Logged into Diems Solution SUccessfully!"),
                    actions: [
                      TextButton(onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomeScreen()));
                      }, child: const Text("ok"))
                    ],
                  );
                });
              });
            }
            signIn();
          }, // Call signIn function
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.lightBlue,
          ),
          child: const Text(
            "Login",
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 30,),
      ],
    );
  }

  _forgotPassword(BuildContext context) {
    return TextButton(
      onPressed: () {
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) => const ResetPasswordPage()));
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
        const SizedBox(height: 20,),
        TextButton(
          onPressed: () {
            context.router.push(const SignupRoute());
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const SignupPage()),
            // );
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
