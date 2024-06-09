import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  String name;
  double targetAmount;
  Timestamp targetDate;

  Goal({
    required this.name,
    required this.targetAmount,
    required this.targetDate,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      name: json['name'],
      targetAmount: json['targetAmount'],
      targetDate: json['targetDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      'targetDate': targetDate,
    };
  }
}