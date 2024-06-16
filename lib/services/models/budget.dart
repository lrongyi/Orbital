import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  Timestamp month;
  double amount;
  String categoryId;
  // bool isRecurring;

<<<<<<< HEAD
  Budget({required this.month, required this.amount, required this.categoryId});

  Budget.fromJson(Map<String, Object?> json)
      : this(
            month: json['month']! as Timestamp,
            amount: (json['amount'] as num)!.toDouble() as double,
            // categories: (json['categories']! as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble()))
            // categories: (json['categories']! as Map<String, dynamic>).map((key, value) {
            //   final categoryList = value as List<dynamic>;
            //   return MapEntry(key, [
            //     (categoryList[0] as num).toDouble(),
            //     categoryList[1] as bool,
            //   ]);
            // }),
            categoryId: json['categoryId'] as String);

  Budget copyWith({Timestamp? month, double? amount, String? categoryId}) {
    return Budget(
        month: month ?? this.month,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId);
  }

  Map<String, Object?> toJson() {
    return {'month': month, 'amount': amount, 'categoryId': categoryId};
=======
  Budget(
      {required this.month,
      required this.monthlyBudget,
      required this.categories});
      

  Budget.fromJson(Map<String, Object?> json)
      : this(
          month: json['month']! as Timestamp,
          monthlyBudget: (json['monthlyBudget'] as num).toDouble(),
          // categories: (json['categories']! as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble()))
          categories: (json['categories']! as Map<String, dynamic>).map((key, value) {
            final categoryList = value as List<dynamic>;
            return MapEntry(key, [
              // amount
              (categoryList[0] as num).toDouble(),
              // isRecurring
              categoryList[1] as bool,
              // Color
              categoryList.length > 2 ? categoryList[2] as String : '', // handle missing color
            ]);
          }),
        );

  Map<String, Object?> toJson() {
    return {
      'month': month,
      'monthlyBudget': monthlyBudget,
      'categories': categories
    };
>>>>>>> origin/old-backend-muhd
  }
}
