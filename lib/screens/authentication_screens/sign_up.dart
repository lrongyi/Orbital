import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/main_screens/expenses_screens/stats.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/services/database.dart';
import 'package:ss/shared/authentication_deco.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = '';
  String password = '';
  String name = '';
  String errorMessage = '';
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
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
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(
                    height: 250.0,
                    width: MediaQuery.of(context).size.width,
                    //insert an image
                    child: Image.asset(
                      "assets/ss_red.png",
                      fit: BoxFit.scaleDown,
                    )),
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
                                      return 'Enter Name';
                                    }
                                    return null;
                                  },
                                  controller: nameController,
                                  decoration:
                                      inputDeco.copyWith(hintText: 'Name'),
                                )),
                            sizedBoxSpacer,
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
                                  decoration:
                                      inputDeco.copyWith(hintText: 'Email'),
                                )),
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
                                decoration:
                                    inputDeco.copyWith(hintText: 'Password'),
                              ),
                            ),
                            sizedBoxSpacer,
                            GestureDetector(
                                onTap: () {
                                  if (_formkey.currentState!.validate()) {
                                    setState(() {
                                      name = nameController.text;
                                      email = emailController.text;
                                      password = passwordController.text;
                                    });
                                  }
                                  AuthMethods().registration(
                                      context, name, email, password);
                                },
                                child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13.0, horizontal: 30.0),
                                    decoration: buttonDeco,
                                    child: const Center(
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )))
                          ],
                        ))),
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
                    onTap: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    child: Image.asset(
                      'assets/google.png',
                      height: 45.0,
                      width: 45.0,
                      fit: BoxFit.cover,
                    )),
                sizedBoxSpacer,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(
                      width: 5.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: ((context) => LogIn())),
                            (route) => false);
                      },
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                )
              ]),
            )));
  }
}
