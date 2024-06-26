import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
import 'package:ss/screens/main_screens/bill_screens/billing.dart';
import 'package:ss/screens/main_screens/home_screens/home.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/onboarding_screens/get_started.dart';
import 'package:ss/screens/onboarding_screens/select_bills.dart';
import 'package:ss/screens/onboarding_screens/select_categories.dart';
import 'package:ss/services/budget_methods.dart';
// import 'package:ss/screens/authentication_screens/sign_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['API_KEY']!,
      appId: dotenv.env['APP_ID']!, 
      messagingSenderId: dotenv.env['MESSAGING_SENDER_ID']!, 
      projectId: dotenv.env['PROJECT_ID']!,
    )
  );
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: LogIn(),
      // home: GetStarted(),
      home: Navigation(),
      // home: Billing()
    );
  }
}



