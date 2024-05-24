import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/services/models/expense.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';

class DatabaseMethods {

  final _firestore = FirebaseFirestore.instance;

  String getCurrentUserId(){
    return FirebaseAuth.instance.currentUser!.uid;
  }

  Future addUser(String userId, Map<String, dynamic> userInfoMap) {
    return _firestore.collection(USER_COLLECTION).doc(userId).set(userInfoMap);
  }  

  CollectionReference<Expense> getExpensesRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(EXPENSE_COLLECTION)
      .withConverter<Expense>(fromFirestore: (snapshots, _) => Expense.fromjson(snapshots.data() as Map<String, Object?>), 
        toFirestore: (expense, _) => expense.toJson());
  }

  Stream<QuerySnapshot> getExpenses() {
    return getExpensesRef(getCurrentUserId()).snapshots();
  }

  void addExpense(Expense expense) async {
    getExpensesRef(getCurrentUserId()).add(expense);
  }

  void updateExpense(String expenseId, Expense expense) {
    getExpensesRef(getCurrentUserId()).doc(expenseId).update(expense.toJson());
  }

  void deleteExpense(String expenseId) {
    getExpensesRef(getCurrentUserId()).doc(expenseId).delete();
  }
}