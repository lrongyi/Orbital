import 'package:flutter/material.dart';
import 'package:ss/shared/main_screens_deco.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Dummy
  final String _username = 'Dummy';
  final String _email = 'dummy@email.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text(
              'Username: $_username',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Email
            Text(
              'Email: $_email',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
              },
              child: const Text('Change Username (WIP)'),
            ),
            const SizedBox(height: 10),
            // Change Password Button
            ElevatedButton(
              onPressed: () {
                // TODO: firebase change password operation
              },
              child: const Text('Change Password (WIP)'),
            ),
          ],
        ),
      ),
    );
  }
}
