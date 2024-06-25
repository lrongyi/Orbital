import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
import 'package:ss/screens/authentication_screens/sign_up.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/shared/authentication_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

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
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.only(
          top: 100,
          left: 20,
          right: 20,
          ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: Text(
                'Reset Password',
                style: TextStyle(
                  color: mainColor,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Enter your email address and we'll send you a link to get back into your account",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  // color: Colors.grey
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Text(
            //   'Enter Email',
            //   style: TextStyle(
            //     color: mainColor,
            //     fontSize: 20.0,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
            Expanded(
              child: Form(
                key: _formkey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ListView(
                    children: [
                      Container(
                        padding: spaceBetweenForms,
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
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: mainColor,
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
                          padding: const EdgeInsets.all(10),
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
                        height: 75
                      ),

                      orDivider,

                      const SizedBox(
                        height: 40
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: ((context) => SignUp())), (route) => false);
                        },
                      
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
                          decoration: switchAuthButtonDeco,
                          child: Center(
                            child: Text(
                              'Create new account',
                              style: TextStyle(
                                color: mainColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 215,),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: ((context) => LogIn())),
                                (route) => false);
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
                            decoration: switchAuthButtonDeco,
                            child: Center(
                              child: Text(
                                'Back to log in',
                                style: TextStyle(
                                  color: mainColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ),
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