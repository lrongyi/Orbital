import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/user_methods.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';

class BudgetMethods {

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Budget> getBudgetRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(BUDGET_COLLECTION)
      .withConverter<Budget>(fromFirestore: (snapshots, _) => Budget.fromjson(snapshots.data() as Map<String, dynamic>), 
        toFirestore: (budget, _) => budget.toJson());
  }

  Stream<QuerySnapshot> getBudgets() {
    return getBudgetRef(UserMethods().getCurrentUserId()).snapshots();
  }

  Stream<QuerySnapshot> getBudgetsByMonth(DateTime time) {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 
    print('Query range: $startOfMonth - $endOfMonth');
    return getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: startOfMonth).where('month', isLessThan: endOfMonth).snapshots();
  }

  Stream<List<String>> getCategoriesByMonth(DateTime time) async* {
    yield await getCategoriesList(time);
  }

  Future<List<String>> getCategoriesList(DateTime time) async {
    DateTime firstOfMonth = DateTime(time.year, time.month, 1);
    DateTime nextMonth = time.month != 12 ? DateTime(time.year, time.month + 1, 1) : DateTime(time.year + 1, 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

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

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

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

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      existingBudget.categories.update(category, (value) => value + amount, ifAbsent: () => amount,);
      existingBudget.monthlyBudget += amount;
      await budgetDoc.reference.set(existingBudget);
    } else {
      Budget newBudget = Budget(categories: {category: amount}, month: firstOfMonthTS, monthlyBudget: amount);
      await getBudgetRef(UserMethods().getCurrentUserId()).add(newBudget);
    }
  }

  void updateBudget(String category, double amount) async {
    DateTime now = DateTime.now();
    DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

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

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

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
}