import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ss/screens/main_screens/home.dart';
import 'package:ss/screens/main_screens/navigation.dart';
import 'package:ss/services/database.dart';

class AuthMethods{
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return auth.currentUser;
  }

  // Needs fixing
  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken
    );

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        'email': userDetails!.email,
        'name': userDetails.displayName,
        'id': userDetails.uid,
        'income': 0,
        'monthly_budget': 0,
        'expenditure': 0
      };
      
      //Database methods
      await DatabaseMethods().addUser(userDetails.uid, userInfoMap).then((value) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Navigation()), (route) => false);
      });
    }
  }
  
  login(BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Navigation()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
              'User Not Found',
              style: TextStyle(fontSize: 18.0),
            ),
            backgroundColor: Colors.amberAccent,
            )
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
              'Wrong Password',
              style: TextStyle(fontSize: 18.0),
            ),
            backgroundColor: Colors.amberAccent,
            )
        );
      }
    }
  }

  registration(BuildContext context, String name, String email, String password) async {
    if (password != '' && name != '' && email != '') {
      try {
        UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registered Successfully', style: TextStyle(fontSize: 20.0),),
            )
        );
        User? userDetails = result.user;

        Map<String, dynamic> userInfoMap = {
          'email': userDetails!.email,
          'name': name,
          'id': userDetails.uid,
          'income': 0,
          'month_budget': 0,
          'expenditure': 0
        };
        
        //Database methods
        await DatabaseMethods().addUser(userDetails.uid, userInfoMap).then((value) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Navigation()), (route) => false);
        });

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
              'Weak Password',
              style: TextStyle(fontSize: 18.0),
            ),
            backgroundColor: Colors.amberAccent,
            )
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
              'Account Already Exists',
              style: TextStyle(fontSize: 18.0),
            ),
            backgroundColor: Colors.amberAccent,
            )
          );
        }
      }
    }
  }

  resetPassword(BuildContext context, String email) async {
    try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password Reset Email has been Sent',
              style: TextStyle(fontSize: 18.0),
            )
          )
        );
    } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
              'Email Invalid',
              style: TextStyle(fontSize: 18.0),
            ),
            backgroundColor: Colors.amberAccent,
            )
        );
        }
    }
  }

  signOut() async {
    auth.signOut();
  }
}