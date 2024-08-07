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
                )
                // backgroundImage: AssetImage('assets/profile_picture.png'), 
                // child: Text(
                //   'U',
                //   style: TextStyle(
                //     fontSize: 40,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   )
                // )
              ),
            ),
            const SizedBox(height: 20),

            // Username
            FutureBuilder(
              
              future: UserMethods().getUserNameAsync(), 
              
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Display error message if any
                } else {
                  return Text(
                    'Username: ${snapshot.data ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ); // Display the user name
                }
              },
            ),

            const SizedBox(height: 10),

            // Email
            FutureBuilder(
              
              future: UserMethods().getEmailAsync(), 
              
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Display error message if any
                } else {
                  return Text(
                    'Email: ${snapshot.data ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ); // Display the user name
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), 
                      ),
                      backgroundColor: Colors.white,
                      title: const Text(
                        'Change Username',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,                       
                        ),
                      ),
                      content: TextFormField(
                        controller: newNameController,
                        decoration: const InputDecoration(
                          labelText: 'New Username',
                        ),
                      ),
                      actions: [
                        // cancel button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // save button
                        TextButton(
                          onPressed: () {
                            String newName = newNameController.text;
                            if (newName.isNotEmpty) {
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
                              

                            } else {
                              // shows error message to prevent empty text form field input
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'Username cannot be empty',
                                    style: TextStyle(
                                      color: Colors.white,
                                    )
                                    ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.black,
                            ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), 
                      ),
                      backgroundColor: Colors.white,
                      title: const Text(
                        'Change Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        )                       
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          TextFormField(
                            controller: oldPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Current Password',
                            ),
                            obscureText: true,
                          ),
                          TextFormField(
                            controller: newPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'New Password',
                            ),
                            obscureText: true,
                          ),
                          TextFormField(
                            controller: confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                            ),
                            obscureText: true,
                          ),
                        ],
                      ),
                      actions: [
                        // cancel button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // save button
                        TextButton(
                          onPressed: () {
                            String newPassword = newPasswordController.text;
                            String confirmPassword = confirmPasswordController.text;
                            String email = emailController.text;
                            String oldPassword = oldPasswordController.text;

                            if (newPassword.isEmpty || confirmPassword.isEmpty) {
                              // show an error message if any input is empty
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'Password fields cannot be empty'
                                  ),
                                ),
                              );
                            } else if (newPassword != confirmPassword) {
                              // show an error message if passwords do not match
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    'Passwords do not match',
                                  ),
                                ),
                              );
                            } else {
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
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.black,
                            ),
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
}
