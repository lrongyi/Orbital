import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/services/user_methods.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';
const String BILL_COLLECTION = 'Bills';
const String GOAL_COLLECTION = 'Goals';

class ExpenseMethods {

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Expense> getExpensesRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(EXPENSE_COLLECTION)
      .withConverter<Expense>(fromFirestore: (snapshots, _) => Expense.fromjson(snapshots.data() as Map<String, Object?>), 
        toFirestore: (expense, _) => expense.toJson());
  }

   Stream<QuerySnapshot> getExpenses() {
    return getExpensesRef(UserMethods().getCurrentUserId()).snapshots();
  }

  Stream<QuerySnapshot> getExpensesByMonth(DateTime time) {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 
    return getExpensesRef(UserMethods().getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).orderBy('date', descending: true).snapshots();
  }

  Future<double> getMonthlySpendingCategorized(DateTime time, String category) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 

    try {
      QuerySnapshot query = await getExpensesRef(UserMethods().getCurrentUserId())
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

    QuerySnapshot<Expense> query = await getExpensesRef(UserMethods().getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).get();

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

  Future<double> getMonthlyIncome(DateTime time) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 

    QuerySnapshot<Expense> query = await getExpensesRef(UserMethods().getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).get();

    double totalIncome = 0.0;

    if (query.docs.isNotEmpty) {
      for (var expenses in query.docs) {
        Expense data = expenses.data();
        // totalSpending += -1 * data.amount;
        data.amount > 0 ? totalIncome += data.amount : totalIncome = totalIncome;
      }
    }

    return totalIncome;
  }

  Future<double> getMonthlyNetChange(DateTime time) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 

    QuerySnapshot<Expense> query = await getExpensesRef(UserMethods().getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).get();

    double totalSpending = 0.0;

    if (query.docs.isNotEmpty) {
      for (var expenses in query.docs) {
        Expense data = expenses.data();
        totalSpending += data.amount;
      }
    }

    return totalSpending;    
  }

  Stream<double> getMonthlySpendingStream(DateTime time) {
    Stream<double> singleSubStream() async* {
      yield await getMonthlySpending(time);
    }

    return singleSubStream().asBroadcastStream();
  }

  Future<double> getRemainingMonthly(DateTime time) async {
    double monthlyBudget = await BudgetMethods().getMonthlyBudgetAsync(time);
    List<String> categories = await BudgetMethods().getCategoriesList(time);
    double monthlyExpense = 0.0;
    for (String cat in categories) {
      monthlyExpense += await getMonthlySpendingCategorized(time, cat);
    }
    return monthlyBudget - monthlyExpense;
  }

  void addExpense(Expense expense) async {
    final userRef = _firestore.collection(USER_COLLECTION).doc(UserMethods().getCurrentUserId());
    
    await getExpensesRef(UserMethods().getCurrentUserId()).add(expense);
    
    final userDoc = await userRef.get();
    if (userDoc.exists && expense.amount < 0) {
      final currentNetSpend = userDoc.data()!['netSpend'] ?? 0;
      final newNetSpend = currentNetSpend + expense.amount;
      await userRef.update({'netSpend': newNetSpend});
    }
  }

  void updateExpense(String expenseId, Expense expense) async {
    final expenseDoc = await getExpensesRef(UserMethods().getCurrentUserId()).doc(expenseId).get();
    final userRef = _firestore.collection(USER_COLLECTION).doc(UserMethods().getCurrentUserId());

    if (expenseDoc.exists) {
      final data = expenseDoc.data();
      final currentExpense = data!.toJson();
      final spend = currentExpense?['amount'];

      if (spend is num) {
        final spendAmount = spend.toDouble();

        await getExpensesRef(UserMethods().getCurrentUserId()).doc(expenseId).update(expense.toJson());

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
    final userRef = _firestore.collection(USER_COLLECTION).doc(UserMethods().getCurrentUserId());
    final expenseDoc = await getExpensesRef(UserMethods().getCurrentUserId()).doc(expenseId).get();

    if (expenseDoc.exists) {
      final data = expenseDoc.data();
      final currentExpense = data!.toJson();
      final spend = currentExpense?['amount'];

      if (spend is num) {
        final spendAmount = spend.toDouble();
      

        await getExpensesRef(UserMethods().getCurrentUserId()).doc(expenseId).delete();

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