import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  Timestamp date;
  double amount;
  String? category = '';
  String? note = '';
  String? description = '';

  Expense({
    required this.date, 
    required this.amount, 
    this.category,
    this.note,
    this.description
    });

  Expense.fromjson(Map<String, Object?> json) 
    : this(
      date: json['date']! as Timestamp,
      amount: json['amount']! as double,
      category: json['category'] as String?,
      note: json['note'] as String?,
      description: json['description'] as String?,
    ); 

  Expense copyWith({Timestamp? date, double? amount, String? category, String? note, String? description}) {
    return Expense(
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      description: description ?? this.description,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'date': date,
      'amount': amount,
      'category': category,
      'note': note,
      'description': description,
    };
  }
}