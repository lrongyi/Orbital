import 'package:flutter/material.dart';
import 'package:ss/screens/authentication_screens/forgot_password.dart';
import 'package:ss/screens/authentication_screens/sign_up.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/shared/authentication_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

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
        padding: const EdgeInsets.only(
          top: 100,
          left: 5,
          right: 5,
          ),
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
                            decoration: inputDeco.copyWith(
                              hintText: 'Email',
                              icon: Icon(
                                Icons.mail_outline_rounded,
                                color: mainColor,
                              )
                            ),
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
                              decoration: inputDeco.copyWith(
                                hintText: 'Password',
                                icon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: mainColor,
                                )
                              ),
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
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                    )
                  )
                ),

                const SizedBox(height: 35,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: orDivider,
                ), 

                const SizedBox(height: 60,),
                
                // Insert google Sign in 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    child: CustomPaint(
                      painter: GoogleBorderPainter(),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13.0, horizontal: 20.0
                        ),
                        
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/google.png',
                              height: 30.0,
                              width: 30.0,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 50.0),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                
                const SizedBox(height: 20,),

                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: GestureDetector(
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
                ),

                
            ]
          ),
        )
      )
    );
  }
}