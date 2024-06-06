import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {

  String name;
  double amount;
  Timestamp due;
  bool isPaid;

  
  Bill({required this.name, required this.amount, required this.due, required this.isPaid});

  Bill.fromJson(Map<String, Object?> json)
    : this(
      name: json['name'] as String,
      amount: json['amount']! as double,
      due: json['due']! as Timestamp,
      isPaid: json['isPaid']! as bool,
    ); 

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'amount': amount,
      'due': due,
      'isPaid': isPaid,
    };
  }
}