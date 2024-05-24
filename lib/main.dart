import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
// import 'package:ss/screens/authentication_screens/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDZyWW3eRhtqVxcfoNUhAScNUi-DcgVLZU',
      appId: '1:252318737722:android:4196a42d03abdffc78dc03', 
      messagingSenderId: '252318737722', 
      projectId: 'savings_squad')
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LogIn(),
    );
  }
}



