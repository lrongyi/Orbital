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

  Bill copyWith({String? name, double? amount, Timestamp? due, bool? isPaid}) {
    return Bill(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      due: due ?? this.due,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'amount': amount,
      'due': due,
      'isPaid': isPaid,
    };
  }
}