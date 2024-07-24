class UserModel {
  String email;
  String name;
  String id;
  // double monthlyBudget;
  double netSpend;

  UserModel({
    required this.email, 
    required this.name,
    required this.id, 
    // required this.monthlyBudget,
    required this.netSpend,  
    });

  UserModel.fromjson(Map<String, Object?> json) 
    : this(
      email: json['email']! as String,
      name: json['name']! as String,
      id: json['id'] as String,
      // monthlyBudget: json['monthlyBudget'] as double,
      netSpend: json['netSpend'] as double,
    ); 

  Map<String, Object?> toJson() {
    return {
      'email': email,
      'name': name,
      'id': id,
      // 'monthlyBudget': monthlyBudget,
      'netSpend': netSpend,
    };
  }
}