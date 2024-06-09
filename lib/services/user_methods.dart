import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ss/services/models/user_model.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';
const String BILL_COLLECTION = 'Bills';
const String GOAL_COLLECTION = 'Goals';

class UserMethods {
   final _firestore = FirebaseFirestore.instance;

  String getCurrentUserId(){
    return FirebaseAuth.instance.currentUser!.uid;
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser!;
  }

  Future<String> getUserNameAsync() async {
    DocumentSnapshot userDoc = await _firestore.collection(USER_COLLECTION).doc(getCurrentUserId()).get();

    if (userDoc.exists) {
      return userDoc['name'];
    } else {
      return '';
    }
  }

  Future<String> getEmailAsync() async {
    DocumentSnapshot userDoc = await _firestore.collection(USER_COLLECTION).doc(getCurrentUserId()).get();

    if (userDoc.exists) {
      return userDoc['email'];
    } else {
      return '';
    }
  }

  Future<double> getNetSpendAsync() async {
    DocumentSnapshot userDoc = await _firestore.collection(USER_COLLECTION).doc(getCurrentUserId()).get();

    if (userDoc.exists) {
      return userDoc['netSpend'];
    } else {
      return 0.00;
    }
  }

  Future addUser(String userId, Map<String, dynamic> userInfoMap) {
    return _firestore.collection(USER_COLLECTION).doc(userId).set(userInfoMap);
  }  

  Future updateUserDisplayName(String userId, String newDisplayName) {
    return _firestore.collection(USER_COLLECTION).doc(userId).update({'name': newDisplayName});
  }

  Future updateUserEmail(String userId, String newEmail) {
    return _firestore.collection(USER_COLLECTION).doc(userId).update({'email': newEmail});
  }

  CollectionReference<UserModel> getUserRef() {
    return _firestore.collection(USER_COLLECTION).withConverter(fromFirestore: (snapshots, _) => UserModel.fromjson(snapshots.data() as Map<String, Object?>), 
      toFirestore: (userModel, _) => userModel.toJson());
  }
}