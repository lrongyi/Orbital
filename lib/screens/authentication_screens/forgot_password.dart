import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
import 'package:ss/screens/authentication_screens/sign_up.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/shared/authentication_deco.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  String email = '';
  TextEditingController emailController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 70.0,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: const Text(
                'Reset your Password',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              'Enter Email',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Form(
                key: _formkey,
                child: Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: ListView(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        decoration: textFieldDeco,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Email';
                            } 
                            return null;
                          },
                          controller: emailController,
                          decoration: inputDeco.copyWith(
                            hintText: 'Email',
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 40.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          if(_formkey.currentState!.validate()) {
                            setState(() {
                              email = emailController.text;
                            });
                            AuthMethods().resetPassword(context, email);
                          }
                        },
                        child: Container(
                          width: 140, 
                          padding: EdgeInsets.all(10),
                          decoration: buttonDeco,
                          child: const Center(
                            child: Text(
                              'Send Recovery Email',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold
                              )
                            )
                          )
                        ),
                      ),
                      const SizedBox(
                        height: 50.0
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            )
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignUp()), (route) => false);
                            },
                            child: const Text('Sign Up', style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10.0
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            )
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LogIn()), (route) => false);
                            },
                            child: const Text('Log In', style: TextStyle(
                              color: Colors.blue,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),),
                          )
                        ],
                      )
                    ],
                  )
                ), 
              ),
            )
          ]
        )
      )
    );
  }
}