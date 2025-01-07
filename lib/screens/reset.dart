// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:chatbotapp/router/router.dart';
//import 'package:chatbotapp/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordScreen> {
  String email = "";

  TextEditingController mailcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Password Reset Link Sent Successfully!!",
          style: TextStyle(fontSize: 18),
        ),
      ));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Email Doesn't Exist!",
            style: TextStyle(fontSize: 18),
          ),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Form(
              key: _formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                      height: 110, width: 200,
                      child: Image.asset('assets/images/user_icon.png',
                      fit: BoxFit.cover,)),
                      const SizedBox(height: 25,),
                      Text(
                        "Reset Password",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Enter your Email & \n Reset your password",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      TextFormField(
                        controller: mailcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Email",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                            fillColor: const Color.fromARGB(255, 96, 100, 163)
                                .withOpacity(0.1),
                            filled: true,
                            prefixIcon: const Icon(Icons.email)),
                      ),
                    ],
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 3, left: 3),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            setState(() {
                              email = mailcontroller.text;
                            });
                            resetPassword();
                            showDialog(context: context, builder: (BuildContext context) {
                              return AlertDialog(
                                title:  Center(
                                  child: Text("Email Sent !!", 
                                  style: Theme.of(context).textTheme.titleMedium, ),
                                ),
                                content: Text("Check your email and reset your password",
                                style: Theme.of(context).textTheme.bodyMedium,),
                                actions: [TextButton(onPressed: () {
                                  context.router.push(const LoginRoute());
                                }, child: const Text("OK"))],
                              );
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue),
                        child: const Text(
                          "Reset Password",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Remember your password?",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            context.router.push(const LoginRoute());
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ))
                    ],

                    
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
