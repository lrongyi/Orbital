import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/authentication_screens/forgot_password.dart';
import 'package:ss/screens/main_screens/home.dart';
import 'package:ss/screens/authentication_screens/sign_up.dart';
import 'package:ss/screens/main_screens/navigation.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/shared/authentication_deco.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {

  String email = '';
  String password = '';
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 250.0,
                width: MediaQuery.of(context).size.width,
                //insert an image
                child: Image.asset(
                  "assets/ss_red.png",
                  fit: BoxFit.scaleDown,
                )
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: _formkey,
                  child: Column(
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
                            decoration: inputDeco.copyWith(hintText: 'Email'),
                            )
                          ),
                          sizedBoxSpacer,
                          Container(
                            padding: spaceBetweenForms,
                            decoration: textFieldDeco,
                            child: TextFormField(
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter Password';
                                } 
                                return null;
                              },
                              controller: passwordController,
                              decoration: inputDeco.copyWith(hintText: 'Password'),
                            ),
                          ),
                          sizedBoxSpacer,
                          GestureDetector(
                            onTap:() {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailController.text;
                                  password = passwordController.text;
                                });
                              }
                              AuthMethods().login(context, email, password);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                vertical: 13.0, horizontal: 30.0
                              ),
                              decoration: buttonDeco,
                              child: const Center(
                                child: Text(
                                  'Log In', 
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w500),
                                  ),)
                              )
                            )
                      ],
                    )
                  )
                ),
                sizedBoxSpacer,
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ForgotPassword()), (route) => false);
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    )
                  )
                ),
                sizedBoxSpacer,
                const Text(
                  'or Login with',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                sizedBoxSpacer,
                // Insert google Sign in 
                GestureDetector(
                  onTap:() {
                    AuthMethods().signInWithGoogle(context);
                  },
                  child: Image.asset(
                    'assets/google.png',
                    height: 45.0,
                    width: 45.0,
                    fit: BoxFit.cover,
                    )
                ),
                sizedBoxSpacer,
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
                      onTap:() {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: ((context) => SignUp())), (route) => false);
                      },
                      child: const Text('Sign Up', style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),),
                    )
                  ],
                )  
            ]
          ),
        )
      )
    );
  }
}