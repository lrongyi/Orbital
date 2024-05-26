import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/services/models/user_model.dart';

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

  CollectionReference<UserModel> getUserRef() {
    return _firestore.collection(USER_COLLECTION).withConverter(fromFirestore: (snapshots, _) => UserModel.fromjson(snapshots.data() as Map<String, Object?>), 
      toFirestore: (userModel, _) => userModel.toJson());
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
    final userRef = _firestore.collection(USER_COLLECTION).doc(getCurrentUserId());
    
    await getExpensesRef(getCurrentUserId()).add(expense);
    
    final userDoc = await userRef.get();
    if (userDoc.exists) {
      final currentNetSpend = userDoc.data()!['netSpend'] ?? 0;
      final newNetSpend = currentNetSpend + expense.amount;
      await userRef.update({'netSpend': newNetSpend});
    }
  }

  void updateExpense(String expenseId, Expense expense) async {
    final expenseDoc = await getExpensesRef(getCurrentUserId()).doc(expenseId).get();
    final userRef = _firestore.collection(USER_COLLECTION).doc(getCurrentUserId());

    if (expenseDoc.exists) {
      final currentExpense = Expense.fromjson(expenseDoc.data()! as Map<String, Object?>);

      await getExpensesRef(getCurrentUserId()).doc(expenseId).update(expense.toJson());

      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final currentNetSpend = userDoc.data()!['netSpend'] ?? 0;
        final newNetSpend = currentNetSpend - currentExpense.amount + expense.amount;
        await userRef.update({'netSpend': newNetSpend});
      }
    }
  }

  void deleteExpense(String expenseId) async {
    final userRef = _firestore.collection(USER_COLLECTION).doc(getCurrentUserId());
    final expenseDoc = await getExpensesRef(getCurrentUserId()).doc(expenseId).get();

    if (expenseDoc.exists) {
      final currentExpense = Expense.fromjson(expenseDoc.data()! as Map<String, Object?>);

      await getExpensesRef(getCurrentUserId()).doc(expenseId).delete();

      final userDoc = await userRef.get();
      if (userDoc.exists) {
        final currentNetSpend = userDoc.data()!['netSpend'] ?? 0;
        final newNetSpend = currentNetSpend - currentExpense.amount;
        await userRef.update({'netSpend': newNetSpend});
      }
    }
  }
}