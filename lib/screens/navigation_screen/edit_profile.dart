import 'package:flutter/material.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/services/database.dart';
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
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.black,
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
            const SizedBox(height: 20),

            // Username
            FutureBuilder(
              
              future: DatabaseMethods().getUserNameAsync(), 
              
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
              
              future: DatabaseMethods().getEmailAsync(), 
              
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
              onPressed: () {
                // TODO: firebase change profile picture operation
              },
              child: const Text('Change Profile Picture (WIP)'),
            ),

            const SizedBox(height: 10),

            // Change Username Button
            ElevatedButton(
              onPressed: () {
                // TODO: firebase change username operation
                // Add a pop up to ask user for new username pass the string in as newName
                // AuthMethods().changeDisplayName(newName);
              },
              child: const Text('Change Username (WIP)'),
            ),

            const SizedBox(height: 10),

            // Change Password Button
            ElevatedButton(
              onPressed: () {
                // TODO: firebase change password operation
                // Add a pop up to ask user for new password pass the string in as newPassword
                // AuthMethods().changePassword(newPassword);
              },
              child: const Text('Change Password (WIP)'),
            ),
          ],
        ),
      ),
    );
  }
}
