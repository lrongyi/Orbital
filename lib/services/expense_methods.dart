import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/services/bill_methods.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/category_methods.dart';
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
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1, 1); 
    return getExpensesRef(UserMethods().getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).orderBy('date', descending: true).snapshots();
  }

  Future<double> getMonthlySpendingCategorized(DateTime time, String category) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1, 1); 

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
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1, 1); 

    QuerySnapshot<Expense> query = await getExpensesRef(UserMethods().getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).get();

    double totalSpending = 0.0;

    if (query.docs.isNotEmpty) {
      for (var expenses in query.docs) {
        Expense data = expenses.data();
        data.amount < 0 ? totalSpending += -1 * data.amount : totalSpending = totalSpending;
      }
    }

    double bills = await BillMethods().getPaidAmount();

    return totalSpending + bills;
  }

  Future<double> getMonthlyIncome(DateTime time) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1, 1); 

    QuerySnapshot<Expense> query = await getExpensesRef(UserMethods().getCurrentUserId()).where('date', isGreaterThanOrEqualTo: startOfMonth).where('date', isLessThan: endOfMonth).get();

    double totalIncome = 0.0;

    if (query.docs.isNotEmpty) {
      for (var expenses in query.docs) {
        Expense data = expenses.data();
        data.amount > 0 ? totalIncome += data.amount : totalIncome = totalIncome;
      }
    }

    double salary = await UserMethods().getSalaryAsync();

    return totalIncome + salary;
  }

  Future<double> getMonthlyNetChange(DateTime time) async {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1, 1); 

    double income = await getMonthlyIncome(time);
    double expense = await getMonthlySpending(time);
    return income - expense;
  }

  Stream<double> getMonthlySpendingStream(DateTime time) {
    Stream<double> singleSubStream() async* {
      yield await getMonthlySpending(time);
    }

    return singleSubStream().asBroadcastStream();
  }

  Future<double> getRemainingMonthly(DateTime time) async {
    double monthlyBudget = await BudgetMethods().getMonthlyBudgetAsync(time);
    List<String> categories = await CategoryMethods().getCategoryNames();
    double monthlyExpense = 0.0;
    for (String cat in categories) {
      monthlyExpense += await getMonthlySpendingCategorized(time, cat);
    }
    return monthlyBudget - monthlyExpense;
  }

  Future<int> getBudgetsOvershotCountMonthly(DateTime time) async {
    List<String> categories = await BudgetMethods().getCategoriesList(time);
    int overshotCount = 0;

    for (String category in categories) {
      double categoryBudget = await BudgetMethods().getCategoryBudgetAsync(time, category);
      double categorySpending = await getMonthlySpendingCategorized(time, category);

      if (categorySpending > categoryBudget) {
        overshotCount += 1;
      }
    }

    return overshotCount;
  }

  Future<int> getBudgetsWithinZone(DateTime time) async {
    List<String> categories = await BudgetMethods().getCategoriesList(time);
    int withinZoneCount = 0;

    for (String category in categories) {
      double categoryBudget = await BudgetMethods().getCategoryBudgetAsync(time, category);
      double categorySpending = await getMonthlySpendingCategorized(time, category);

      if (categorySpending <= categoryBudget) {
        withinZoneCount += 1;
      }
    }

    return withinZoneCount;
  }

  void addExpense(Expense expense) async { 
    await getExpensesRef(UserMethods().getCurrentUserId()).add(expense);
  }

  void updateExpense(String expenseId, Expense expense) async {
        await getExpensesRef(UserMethods().getCurrentUserId()).doc(expenseId).update(expense.toJson());
  }

  void deleteExpense(String expenseId) async {
        await getExpensesRef(UserMethods().getCurrentUserId()).doc(expenseId).delete();
    }

}