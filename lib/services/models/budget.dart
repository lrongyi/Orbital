import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {

  Timestamp month;
  double monthlyBudget;
  Map<String, List<dynamic>> categories;

  Budget({
    required this.month, 
    required this.monthlyBudget, 
    required this.categories});

  Budget.fromjson(Map<String, Object?> json) 
    : this (
      month: json['month']! as Timestamp,
      monthlyBudget: (json['monthlyBudget'] as num)!.toDouble() as double,
      // categories: (json['categories']! as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble()))
      categories: (json['categories']! as Map<String, dynamic>).map((key, value) {
        final categoryList = value as List<dynamic>;
        return MapEntry(key, [
          (categoryList[0] as num).toDouble(),
          categoryList[1] as bool,
        ]);
      }),
    );

  Map<String, Object?> toJson() {
    return {
      'month': month,
      'monthlyBudget': monthlyBudget,
      'categories': categories 
    };
  }
}