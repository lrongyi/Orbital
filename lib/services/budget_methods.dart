import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/screens/onboarding_screens/old%20set%20budget';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/models/category.dart';
import 'package:ss/services/user_methods.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';
const String BILL_COLLECTION = 'Bills';
const String GOAL_COLLECTION = 'Goals';

class BudgetMethods {

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Budget> getBudgetRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(BUDGET_COLLECTION)
      .withConverter<Budget>(fromFirestore: (snapshots, _) => Budget.fromJson(snapshots.data() as Map<String, dynamic>), 
        toFirestore: (budget, _) => budget.toJson());
  }

  Stream<QuerySnapshot> getBudgets() {
    return getBudgetRef(UserMethods().getCurrentUserId()).snapshots();
  }

  Stream<QuerySnapshot> getBudgetsByMonth(DateTime time) {
    DateTime startOfMonth = DateTime(time.year, time.month);
    DateTime endOfMonth = time.month != 12 ? DateTime(time.year, time.month + 1) : DateTime(time.year + 1, 1); 
    return getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: startOfMonth).where('month', isLessThan: endOfMonth).snapshots().asBroadcastStream();
  }

  // Stream<List<String>> getCategoriesByMonth(DateTime time) async* {
  //   yield await getCategoriesList(time);
  // }

  // Future<List<String>> getCategoriesList(DateTime time) async {
  //   DateTime firstOfMonth = DateTime(time.year, time.month, 1);
  //   DateTime nextMonth = time.month != 12 ? DateTime(time.year, time.month + 1, 1) : DateTime(time.year + 1, 1, 1);
  //   Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
  //   Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

  //   QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

  //   if (query.docs.isNotEmpty) {
  //     DocumentSnapshot<Budget> budgetDoc = query.docs.first;
  //     Budget existingBudget = budgetDoc.data()!;
  //     return existingBudget.categories.keys.toList();
  //   } else {
  //     return List.empty();
  //   }
  // }

  Future<double> getMonthlyBudgetAsync(DateTime time) async {
    DateTime firstOfMonth = DateTime(time.year, time.month, 1);
    DateTime nextMonth = time.month != 12 ? DateTime(time.year, time.month + 1, 1) : DateTime(time.year + 1, 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    double monthlyBudget = 0.0;

    for (var doc in query.docs) {
      Budget existingBudget = doc.data()!;
      monthlyBudget += existingBudget.amount.toDouble();
    }

    return monthlyBudget;
  }

  Stream<double> getMonthlyBudgetStream(DateTime time) {
    Stream<double> singleSubStream() async* {
      yield await getMonthlyBudgetAsync(time);
    }

    return singleSubStream().asBroadcastStream();
  }

<<<<<<< HEAD
  Future<void> addBudget(Budget budget) async {
    await getBudgetRef(UserMethods().getCurrentUserId()).add(budget);
  }

  void updateBudget(String budgetId, Budget budget) async {
    await getBudgetRef(UserMethods().getCurrentUserId()).doc(budgetId).update(budget.toJson());
=======
  Future<void> addBudget(String category, double amount, bool isRecurring, String color) async {
    DateTime now = DateTime.now();
    DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId())
        .where('month', isGreaterThanOrEqualTo: firstOfMonthTS)
        .where('month', isLessThan: nextMonthTS)
        .get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      existingBudget.categories.update(category, (value) => [
        (value[0] as double) + amount, // update amount
        value[1] as bool, // isRecurring
        value.length > 2 ? value[2] : color, // update color if present
      ], ifAbsent: () => [amount, isRecurring, color]);
      existingBudget.monthlyBudget += amount;
      await budgetDoc.reference.set(existingBudget);
    } else {
      Budget newBudget = Budget(
        categories: {category: [amount, isRecurring, color]},
        month: firstOfMonthTS,
        monthlyBudget: amount,
      );
      await getBudgetRef(UserMethods().getCurrentUserId()).add(newBudget);
    }
  }

  void updateBudget(String category, double amount, bool isRecurring, String color) async {
    DateTime now = DateTime.now();
    DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
    Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
    Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

    QuerySnapshot<Budget> query = await getBudgetRef(UserMethods().getCurrentUserId()).where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

    if (query.docs.isNotEmpty) {
      DocumentSnapshot<Budget> budgetDoc = query.docs.first;
      Budget existingBudget = budgetDoc.data()!;
      if (existingBudget.categories.containsKey(category)) {
        existingBudget.categories[category] = [amount, isRecurring, color];
      } else {
        throw Exception('Category does not exist');
      }
      existingBudget.monthlyBudget = existingBudget.categories.values.fold(0.0, (sum, value) => sum + value[0]);
      await budgetDoc.reference.set(existingBudget);
    } else {
      throw Exception('No budget document exists for the current month');
    }
>>>>>>> origin/old-backend-muhd
  }

  void deleteBudget(String budgetId) async {
    await getBudgetRef(UserMethods().getCurrentUserId()).doc(budgetId).delete();
  }

  Category getCategory(Category category) {
    // hmmm do we actually need to? maybe we can save time if can figure out how to store Category (special type) as a field for the document.
    // then we can just straight away use the methods
  }

  // Future<void> checkAndCreateRecurringBudgets() async {
  //   DateTime now = DateTime.now();
  //   DateTime firstOfMonth = DateTime(now.year, now.month, 1);
  //   DateTime nextMonth = DateTime(now.year, now.month + 1, 1);
  //   Timestamp firstOfMonthTS = Timestamp.fromDate(firstOfMonth);
  //   Timestamp nextMonthTS = Timestamp.fromDate(nextMonth);

  //   String userId = UserMethods().getCurrentUserId();

  //   QuerySnapshot<Budget> query = await getBudgetRef(userId)
  //   .where('month', isGreaterThanOrEqualTo: firstOfMonthTS).where('month', isLessThan: nextMonthTS).get();

  //   if(query.docs.isEmpty) {
  //     await createRecurringBudget(userId, firstOfMonthTS);
  //   }
  // }

  // Future<void> createRecurringBudget(String userId, Timestamp firstOfMonthTS) async {
  //   DateTime previousMonth = DateTime(firstOfMonthTS.toDate().year, firstOfMonthTS.toDate().month - 1, 1);
  //   Timestamp previousMonthTS = Timestamp.fromDate(previousMonth);

  //   QuerySnapshot<Budget> query = await getBudgetRef(userId).where('month', isEqualTo: previousMonthTS).get();

  //   Map<String, List<dynamic>> recurringCategories = {};

  //   if (query.docs.isNotEmpty) {
  //     Budget previousBudget = query.docs.first.data()!;
  //     previousBudget.categories.forEach(
  //       (key, value) { 
  //         if (value[1] as bool) {
  //           recurringCategories[key] = value[0];
  //         }
  //       }
  //     );
  //   }

  //   double newMonthlyBudget = recurringCategories.values.fold(0.0, (previousValue, element) => previousValue + (element[0] as double));

  //   Budget newBudget = Budget(
  //     categories: recurringCategories,
  //     month: firstOfMonthTS,
  //     monthlyBudget: newMonthlyBudget
  //   );

  //   await getBudgetRef(userId).add(newBudget);
  // }

}