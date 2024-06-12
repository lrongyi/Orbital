import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String id;
  String name;
  String type;
  String color;
  String icon;

  Category({required this.id, required this.name, required this.type, required this.color, required this.icon});

  Category.fromJson(Map<String, Object?> json)
      : this(
          id: json['id'] as String,
          name: json['name'] as String,
          type: json['type'] as String,
          color: json['color'] as String,
          icon: json['icon'] as String,
        );

  Category copyWith({String? id, String? name, Timestamp? due, bool? isPaid}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'color' : color,
      'icon' : icon,
    };
  }
}
