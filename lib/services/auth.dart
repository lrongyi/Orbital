import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ss/screens/main_screens/expenses_screens/stats.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/onboarding_screens/get_started.dart';
import 'package:ss/screens/onboarding_screens/select_bills.dart';
import 'package:ss/screens/onboarding_screens/select_categories.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/user_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return auth.currentUser;
  }

  // Needs fixing
  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth?.idToken, accessToken: googleAuth?.accessToken);

    UserCredential result = await firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    if (result != null) {

      final userDoc = await FirebaseFirestore.instance.collection('User').doc(userDetails?.uid).get();

      if (!userDoc.exists) {
        Map<String, dynamic> userInfoMap = {
          'email': userDetails!.email,
          'name': userDetails.displayName,
          'id': userDetails.uid,
          // 'monthlyBudget': 0,
          'salary': 0.0
        };

        //Database methods
        await UserMethods()
            .addUser(userDetails.uid, userInfoMap);
        
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: ((context) => const GetStarted())),
            (route) => false
          );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
          (route) => false);
      }
    }
  }

  login(BuildContext context, String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      await BudgetMethods().checkAndCreateRecurringBudgets();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Navigation()),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          content: const Text(
            'Wrong Email or Password',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: mainColor,
        ));
      } else if (e.code == 'channel-error'){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          content: const Text(
            'Enter Fields',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: mainColor,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          content: Text(
            e.code,
            style: const TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: mainColor,
        ));
      }
    }
  }

  registration(
      BuildContext context, String name, String email, String password) async {
    if (password != '' && name != '' && email != '') {
      try {
        UserCredential result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          content: const Text(
            'Registered Successfully',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: mainColor,
        ));
        User? userDetails = result.user;

        Map<String, dynamic> userInfoMap = {
          'email': userDetails!.email,
          'name': name,
          'id': userDetails.uid,
          // 'monthlyBudget': 0,
          'salary': 0.0
        };

        //Database methods
        await UserMethods()
            .addUser(userDetails.uid, userInfoMap)
            .then((value) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: ((context) => const GetStarted())),
            (route) => false
          );
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            showCloseIcon: true,
            content: const Text(
              'User Already Exists',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            backgroundColor: mainColor,
          ));
        } else if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            showCloseIcon: true,
            content: const Text(
              'Weak Password',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            backgroundColor: mainColor,
          ));
        } else if (e.code == 'channel-error'){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            showCloseIcon: true,
            content: const Text(
              'Enter Fields',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            backgroundColor: mainColor,
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            showCloseIcon: true,
            content: Text(
              e.code,
              style: const TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            backgroundColor: mainColor,
          ));
        }
      }
    }
  }

  resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        showCloseIcon: true,
        content: Text(
          'Password Reset Email has been Sent',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        backgroundColor: mainColor,
      ));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          content: const Text(
            'Invalid Email',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: mainColor,
        ));
    }
  }

  signOut(BuildContext context) async {
    await auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Signed Out',
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
      backgroundColor: mainColor,
      ));
  }

  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    User? user = auth.currentUser;

    if (user != null) {
      AuthCredential cred = EmailAuthProvider.credential(email: email, password: oldPassword);

      try {
        await user.reauthenticateWithCredential(cred);

        await user.updatePassword(newPassword);
      } catch (e) {
        print('Error: $e');
        throw Exception('Failed to re-authenticate user');
      }

    } else {
      throw Exception('No User Signed In');
    }
  }

  Future<void> changeDisplayName(String newName) async {
    User? user = auth.currentUser;

    if (user != null) {
      await user.updateDisplayName(newName);
      await UserMethods().updateUserDisplayName(user.uid, newName);
    } else {
      throw Exception('No User Signed In');
    }
  }  

  Future<void> changeEmail(String newEmail) async {
    User? user = auth.currentUser;

    if (user != null) {
      await user.verifyBeforeUpdateEmail(newEmail);
      await UserMethods().updateUserEmail(user.uid, newEmail);
    } else {
      throw Exception('No User Signed In');
    }
  }  

}