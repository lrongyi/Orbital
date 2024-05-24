import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
// import 'package:ss/screens/authentication_screens/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAdvRXRDaZPAL1mNeu7sj3nwfODP9z9WfM ',
      appId: '1:471080678953:android:7d5d7db99d6b3f90cf4e38', 
      messagingSenderId: '471080678953', 
      projectId: 'savings-squad-72b1a')
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
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



