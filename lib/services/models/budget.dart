import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {

  Timestamp month;
  double monthlyBudget;
  Map<String, double> categories;

  Budget({
    required this.month, 
    required this.monthlyBudget, 
    required this.categories});

  Budget.fromjson(Map<String, Object?> json) 
    : this (
      month: json['month']! as Timestamp,
      monthlyBudget: (json['monthlyBudget'] as num)!.toDouble() as double,
      categories: (json['categories']! as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble()))
    );

  Map<String, Object?> toJson() {
    return {
      'month': month,
      'monthlyBudget': monthlyBudget,
      'categories': categories 
    };
  }
}