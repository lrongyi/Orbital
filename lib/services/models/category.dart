import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;
  bool isRecurring;
  String color;
  String icon;

  Category({required this.id, required this.name, required this.isRecurring, required this.color, required this.icon});

  Category.fromJson(Map<String, Object?> json)
      : this(
          id: json['id'] as String,
          name: json['name'] as String,
          isRecurring: json['isRecurring'] as bool,
          color: json['color'] as String,
          icon: json['icon'] as String,
        );

  Category copyWith({String? id, String? name, bool? isRecurring, String? color, String? icon}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isRecurring: isRecurring ?? this.isRecurring,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'isRecurring': isRecurring,
      'color' : color,
      'icon' : icon,
    };
  }
}
