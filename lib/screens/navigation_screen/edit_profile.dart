import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/services/user_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // App Bar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: mainColor,
        title: const Text(
          'Profile Page',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),

      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Picture
            CircleAvatar(
              backgroundColor: mainColor,
              radius: 52,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: mainColor,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Username
            FutureBuilder(
              future: UserMethods().getUserNameAsync(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    'Username: ${snapshot.data ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 10),

            // Email
            FutureBuilder(
              future: UserMethods().getEmailAsync(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    'Email: ${snapshot.data ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            // Change Profile Picture Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
              ),
              onPressed: () {
                // TODO: firebase change profile picture operation
              },
              child: const Text(
                'Change Profile Picture (WIP)',
                style: TextStyle(
                  color: Colors.white,
                )
              ),
            ),

            const SizedBox(height: 10),

            // Change Username Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final newNameController = TextEditingController();

                    return AlertDialog(
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        )
                      ),
                      backgroundColor: Colors.white,
                      title: Row(
                        children: [
                          Icon(
                            Icons.account_box_rounded,
                            color: incomeColor,
                          ),
                          const SizedBox(width: 20,),
                          const Text(
                            'Change Username',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black
                            ),
                          ),
                          const SizedBox(width: 35,),
                          IconButton(
                            onPressed: () {
                              newNameController.clear();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      content: Form(
                        key: _formKey,
                        child: TextFormField(
                          cursorColor: mainColor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter New Username';
                            }
                            return null;
                          },
                          controller: newNameController,
                          decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: mainColor)
                            ),
                            hintText: 'New Username',
                            hintStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
                            prefixIcon: const Icon(
                              applyTextScaling: true,
                              Icons.published_with_changes,
                              color: Colors.black,
                            )
                          ),
                        ),
                      ),
                      actions: [
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                            ),
                            onPressed: () {
                              String newName = newNameController.text;
                              if (_formKey.currentState!.validate()) {
                                AuthMethods().changeDisplayName(newName);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Username changed successfully!',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
                                setState(() {});
                              }
                            },
                            child: const Text('Save', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ]
                    );
                  }
                );
              },
              child: const Text(
                'Change Username',
                style: TextStyle(
                  color: Colors.white,
                )
              ),
            ),

            const SizedBox(height: 10),

            // Change Password Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final newPasswordController = TextEditingController();
                    final confirmPasswordController = TextEditingController();
                    final emailController = TextEditingController();
                    final oldPasswordController = TextEditingController();

                    return AlertDialog(
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        )
                      ),
                      backgroundColor: Colors.white,
                      title: Row(
                        children: [
                          Icon(
                            Icons.account_box_rounded,
                            color: incomeColor,
                          ),
                          const SizedBox(width: 20,),
                          const Text(
                            'Change Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black
                            ),
                          ),
                          const SizedBox(width: 35,),
                          IconButton(
                            onPressed: () {
                              newPasswordController.clear();
                              confirmPasswordController.clear();
                              emailController.clear();
                              oldPasswordController.clear();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      content: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _customTextFormField('Email', emailController),
                            _customTextFormField('Current Password', oldPasswordController, 
                            isPasswordField: true
                            ),
                            _customTextFormField('New Password', newPasswordController, 
                            comparisonController: confirmPasswordController, 
                            isPasswordField: true
                            ),
                            _customTextFormField('Confirm Password', confirmPasswordController, 
                            comparisonController: newPasswordController, 
                            isPasswordField: true
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mainColor,
                            ),
                            onPressed: () {
                              String newPassword = newPasswordController.text;
                              String email = emailController.text;
                              String oldPassword = oldPasswordController.text;

                              if (_formKey.currentState!.validate()) {
                                AuthMethods().changePassword(email, oldPassword, newPassword);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password changed successfully!',
                                      style: TextStyle(
                                        color: Colors.white,
                                      )
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Save', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ],
                    );
                  }
                );
              },
              child: const Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.white,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customTextFormField(String name, TextEditingController controller, {TextEditingController? comparisonController, bool? isPasswordField}) {
    return TextFormField(
      obscureText: isPasswordField ?? false,
      cursorColor: mainColor,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Enter $name';
        } else if (comparisonController != null && value != comparisonController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: mainColor)
        ),
        hintText: name,
        hintStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
        prefixIcon: const Icon(
          applyTextScaling: true,
          Icons.lock_outline,
          color: Colors.black,
        )
      ),
    );
  }
}
