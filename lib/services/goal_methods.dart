import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/services/models/goal.dart';
import 'package:ss/services/user_methods.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';
const String BILL_COLLECTION = 'Bills';
const String GOAL_COLLECTION = 'Goals';

class GoalMethods {

  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Goal> getGoalRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(GOAL_COLLECTION)
      .withConverter<Goal>(
        fromFirestore: (snapshots, _) => Goal.fromJson(snapshots.data() as Map<String, dynamic>),
        toFirestore: (goal, _) => goal.toJson()
      );
  }
  // Create (CRUD)
  Future<void> addGoal(Goal newGoal) async {
    String userId = UserMethods().getCurrentUserId();
    await getGoalRef(userId).add(newGoal);
  }

  // Read all goals (CRUD)
  Stream<QuerySnapshot<Goal>> getGoals() {
    return getGoalRef(UserMethods().getCurrentUserId()).snapshots();
  }

  // Update (CRUD)
  Future<void> updateGoal(String goalId, Map<String, dynamic> updatedData) async {
    String userId = UserMethods().getCurrentUserId();
    DocumentReference<Goal> goalDoc = getGoalRef(userId).doc(goalId);

    await goalDoc.update(updatedData);
  }

  // Delete (CRUD)
  Future<void> deleteGoal(String goalId) async {
    String userId = UserMethods().getCurrentUserId();
    DocumentReference<Goal> goalDoc = getGoalRef(userId).doc(goalId);

    await goalDoc.delete();
  }

  // Read a particular goal (CRUD)
  Future<Goal?> getGoal(String goalId) async {
    String userId = UserMethods().getCurrentUserId();
    DocumentReference<Goal> goalDoc = getGoalRef(userId).doc(goalId);

    DocumentSnapshot<Goal> snapshot = await goalDoc.get();
    return snapshot.data();
  }
}