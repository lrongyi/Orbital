import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ss/services/auth.dart';

class DatabaseMethods {

  final User? currentUser = AuthMethods().getCurrentUser();

  Future addUser(String userId, Map<String, dynamic> userInfoMap) {
    return FirebaseFirestore.instance.collection('User').doc(userId).set(userInfoMap);
  }

  // Updates user budget
  void updateBudget(String userId, int budget) {
    
  }

  // Updates user income
  void updateIncome(String userId, int income) {

  }

  // Updates user expenditure
  

}