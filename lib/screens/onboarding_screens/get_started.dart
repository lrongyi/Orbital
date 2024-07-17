import 'package:flutter/material.dart';
import 'package:ss/screens/onboarding_screens/salary.dart';
import 'package:ss/shared/authentication_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),

              Text(
                'Welcome to Savings Squad',
                style: TextStyle(
                  color: mainColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Image.asset(
                  "assets/ss_red.png",
                ),
              ),

              const SizedBox(
                height: 50,
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  'Savings Squad is a comprehensive application designed to monitor your transactions, bills, and budgets, offering financial insights to assist you in reaching your financial goals.',
                  style: TextStyle(
                    color: mainColor,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),

              const SizedBox(
                height: 150
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    elevation: 10.0,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Salary()));
                  }, 
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}