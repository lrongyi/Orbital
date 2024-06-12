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

  // StreamBuilder building block
  Stream<QuerySnapshot<Category>> getCategories() {
    return getCategoriesRef(UserMethods().getCurrentUserId()).snapshots();
  }

  Future<QuerySnapshot> getAllCategoriesAsDocs() {
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

  //FutureBuilder building block
  Future<List<Category>> getAllCategoriesAsList() async {
    try {
      QuerySnapshot<Category> snapshot = await getCategoriesRef(UserMethods().getCurrentUserId()).get();
      List<Category> categories = snapshot.docs.map((doc) => doc.data()).toList();
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<DocumentReference> getDocRefFromCategory(Category category) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Categories')
        .where('id', isEqualTo: category.id)
        .get();

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      // Return the ID of the first matching document
      return querySnapshot.docs.first.reference;
    } else {
      throw Exception('Category not found');
    }
  }

  DocumentReference getDocRefFromDocId(String docId) {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('Categories')
        .doc(docId);
    
    return docRef;
  }

  Future<Category> getCategoryFromDocRef(DocumentReference docRef) async {
    DocumentSnapshot docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Convert document data into a Category object
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      return Category(
        id: docSnapshot.id,
        name: data['name'],
        isRecurring: data['isRecurring'],
        color: data['color'],
        icon: data['icon'],
      );
    } else {
      throw Exception('Category document does not exist');
    }
  }
}

  

