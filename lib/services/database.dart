import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/services/models/user_model.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';

class DatabaseMethods {

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

  CollectionReference<Expense> getExpensesRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(EXPENSE_COLLECTION)
      .withConverter<Expense>(fromFirestore: (snapshots, _) => Expense.fromjson(snapshots.data() as Map<String, Object?>), 
        toFirestore: (expense, _) => expense.toJson());
  }

  CollectionReference<Budget> getBudgetRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(BUDGET_COLLECTION)
      .withConverter<Budget>(fromFirestore: (snapshots, _) => Budget.fromjson(snapshots.data() as Map<String, dynamic>), 
        toFirestore: (budget, _) => budget.toJson());
  }

  Stream<QuerySnapshot> getBudgets() {
    return getBudgetRef(getCurrentUserId()).snapshots();
  }

  Stream<QuerySnapshot> getBudgetsByMonth(DateTime time) {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 
    print('Query range: $startOfMonth - $endOfMonth');
    return getBudgetRef(getCurrentUserId()).where('month', isGreaterThanOrEqualTo: startOfMonth).where('month', isLessThan: endOfMonth).snapshots();
  }

  Stream<List<String>> getCategoriesByMonth(DateTime time) async* {
    yield await getCategoriesList(time);
  }

  Future<List<String>> getCategoriesList(DateTime time) async {
    DateTime firstOfMonth = DateTime(time.year, time.month, 1);
    DateTime nextMonth = time.month != 12 ? DateTime(time.year, time.month + 1, 1) : DateTime(time.year + 1, 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      return existingBudget.categories.keys.toList();
    } else {
      return List.empty();
    }
  }

  Future<double> getMonthlyBudgetAsync(DateTime time) async {
    DateTime firstOfMonth = DateTime(time.year, time.month, 1);
    DateTime nextMonth = time.month != 12 ? DateTime(time.year, time.month + 1, 1) : DateTime(time.year + 1, 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      return existingBudget.monthlyBudget.toDouble();
    } else {
      return 0.0;
    }
  }

  Stream<double> getMonthlyBudgetStream(DateTime time) async* {
    yield await getMonthlyBudgetAsync(time);
  }

  void addBudget(String category, double amount) async {
    DateTime now = DateTime.now();
    DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      existingBudget.categories.update(category, (value) => value + amount, ifAbsent: () => amount,);
      existingBudget.monthlyBudget += amount;
      await budgetDoc.reference.set(existingBudget);
    } else {
      Budget newBudget = Budget(categories: {category: amount}, month: firstOfMonthTS, monthlyBudget: amount);
      await getBudgetRef(getCurrentUserId()).add(newBudget);
    }
  }

  void updateBudget(String category, double amount) async {
    DateTime now = DateTime.now();
    DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      existingBudget.categories[category] = amount;
      existingBudget.monthlyBudget = existingBudget.categories.values.fold(0, (sum, value) => sum + value);
      await budgetDoc.reference.set(existingBudget);
    } else {
      throw Exception('No budget document exists for the current month');
    }
  }

  void deleteBudget(String category) async {
    DateTime now = DateTime.now();
    DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      existingBudget.monthlyBudget = existingBudget.monthlyBudget - existingBudget.categories[category]!;
      existingBudget.categories.remove(category);
      await budgetDoc.reference.set(existingBudget);
    } else {
      throw Exception('No budget document exists for the current month');
    }
  }

  Stream<QuerySnapshot> getExpenses() {
    return getExpensesRef(getCurrentUserId()).snapshots();
  }

  Stream<QuerySnapshot> getExpensesByMonth(DateTime time) {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 
    return getExpensesRef(getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).orderBy('date', descending: true).snapshots();
  }

  Future<double> getMonthlySpendingCategorized(DateTime time, String category) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 

    try {
      QuerySnapshot query = await getExpensesRef(getCurrentUserId())
        .where('date', isGreaterThanOrEqualTo: startOfMonth)
        .where('date', isLessThan: endOfMonth)
        .where('category', isEqualTo: category)
        .get();

      double totalSpending = 0.0;

      if (query.docs.isNotEmpty) {
        for (var doc in query.docs) {
          Expense data = doc.data() as Expense;
          // totalSpending += -1 * data.amount;
          data.amount < 0 ? totalSpending += -1 * data.amount : totalSpending = totalSpending;
        }
      }

      return totalSpending;
    } catch (e) {
      print('Error fetching expenses: $e');
      throw e; // Rethrow the exception after logging it
    }

  }

  Future<double> getMonthlySpending(DateTime time) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 

    QuerySnapshot<Expense> query = await getExpensesRef(getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).get();

    double totalSpending = 0.0;

    if (query.docs.isNotEmpty) {
      for (var expenses in query.docs) {
        Expense data = expenses.data();
        // totalSpending += -1 * data.amount;
        data.amount < 0 ? totalSpending += -1 * data.amount : totalSpending = totalSpending;
      }
    }

    return totalSpending;
  }

  Future<double> getMonthlyNetChange(DateTime time) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 

    QuerySnapshot<Expense> query = await getExpensesRef(getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).get();

    double totalSpending = 0.0;

    if (query.docs.isNotEmpty) {
      for (var expenses in query.docs) {
        Expense data = expenses.data();
        totalSpending += -1 * data.amount;
      }
    }

    return totalSpending;    
  }

  Stream<double> getMonthlySpendingStream(DateTime time) async* {
    yield await getMonthlySpending(time);
  }

  Future<double> getRemainingMonthly(DateTime time) async {
    double monthlyBudget = await getMonthlyBudgetAsync(time);
    double monthlyExpense = await getMonthlySpending(time);
    return monthlyBudget - monthlyExpense;
  }

  void addExpense(Expense expense) async {
    final userRef = _firestore.collection(USER_COLLECTION).doc(getCurrentUserId());
    
    await getExpensesRef(getCurrentUserId()).add(expense);
    
    final userDoc = await userRef.get();
    if (userDoc.exists && expense.amount < 0) {
      final currentNetSpend = userDoc.data()!['netSpend'] ?? 0;
      final newNetSpend = currentNetSpend + expense.amount;
      await userRef.update({'netSpend': newNetSpend});
    }
  }

  void updateExpense(String expenseId, Expense expense) async {
    final expenseDoc = await getExpensesRef(getCurrentUserId()).doc(expenseId).get();
    final userRef = _firestore.collection(USER_COLLECTION).doc(getCurrentUserId());

    if (expenseDoc.exists) {
      final data = expenseDoc.data();
      final currentExpense = data!.toJson();
      final spend = currentExpense?['amount'];

      if (spend is num) {
        final spendAmount = spend.toDouble();

        await getExpensesRef(getCurrentUserId()).doc(expenseId).update(expense.toJson());

        final userDoc = await userRef.get();
        if (userDoc.exists && spendAmount < 0) {
          final currentNetSpend = userDoc.data()!['netSpend'] ?? 0;
          final newNetSpend = currentNetSpend - currentExpense['amount'] + expense.amount;
          await userRef.update({'netSpend': newNetSpend});
        }
      }
    }
  }

  void deleteExpense(String expenseId) async {
    final userRef = _firestore.collection(USER_COLLECTION).doc(getCurrentUserId());
    final expenseDoc = await getExpensesRef(getCurrentUserId()).doc(expenseId).get();

    if (expenseDoc.exists) {
      final data = expenseDoc.data();
      final currentExpense = data!.toJson();
      final spend = currentExpense?['amount'];

      if (spend is num) {
        final spendAmount = spend.toDouble();
      

        await getExpensesRef(getCurrentUserId()).doc(expenseId).delete();

        final userDoc = await userRef.get();
        if (userDoc.exists && (spendAmount < 0)) {
          final currentNetSpend = userDoc.data()!['netSpend'] ?? 0;
          final newNetSpend = currentNetSpend - currentExpense['amount'];
          await userRef.update({'netSpend': newNetSpend});
        }
      }
    }
  }
}