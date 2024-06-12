import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/services/models/category.dart';
import 'package:ss/services/user_methods.dart';

const String EXPENSE_COLLECTION = 'Expenses';
const String USER_COLLECTION = 'User';
const String BUDGET_COLLECTION = 'Budgets';
const String CATEGORY_COLLECTION = 'Categories';
const String GOAL_COLLECTION = 'Goals';

class CategoryMethods {
  
  final _firestore = FirebaseFirestore.instance;

  CollectionReference<Category> getCategoriesRef(String userId) {
    return _firestore.collection(USER_COLLECTION)
      .doc(userId)
      .collection(CATEGORY_COLLECTION)
      .withConverter<Category>(fromFirestore: (snapshots, _) => Category.fromJson(snapshots.data() as Map<String, Object?>), 
        toFirestore: (category, _) => category.toJson());
  }

  // The building block of every StreamBuilder that needs to access Categories
  Stream<QuerySnapshot<Category>> getCategories() {
    return getCategoriesRef(UserMethods().getCurrentUserId()).snapshots();
  }

  Future<QuerySnapshot> getAllCategories() {
    return getCategoriesRef(UserMethods().getCurrentUserId()).get();
  }

  void addCategory(Category category) async {
    await getCategoriesRef(UserMethods().getCurrentUserId()).add(category);
  }

  void updateCategory(String categoryId, Category category) async {
    await getCategoriesRef(UserMethods().getCurrentUserId()).doc(categoryId).update(category.toJson());
  }

  void deleteCategory(String categoryId) async {
    await getCategoriesRef(UserMethods().getCurrentUserId()).doc(categoryId).delete();
  }

  // Get color from a String representation
  // Method is needed to convert color field taken from the category in Firebase 
  // into a Color type
  Color getCategoryColor(String colorString) {
    final start = colorString.indexOf('Color(0x') + 8; // Index of the start of the hexadecimal color value
    final end = colorString.indexOf(')'); // Index of the end of the hexadecimal color value
    final hexColor = colorString.substring(start, end);

    return Color(int.parse(hexColor, radix: 16)); // Parse the hexadecimal color value to Color
  }

  Future<List<String>> getCategoryNames() async {
    try {
      QuerySnapshot snapshot = await getCategoriesRef(UserMethods().getCurrentUserId()).get();
      List<String> categoryNames = snapshot.docs.map((doc) {
        Category category = doc.data() as Category;
        return category.name;
      }).toList();
      return categoryNames;
    } catch (e) {
      print('Error fetching category names: $e');
      return [];
    }
  }

  Stream<List<String>> getCategoryNamesStream() async* {
    yield await getCategoryNames();
  }

  

}