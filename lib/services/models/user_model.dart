class UserModel {
  String email;
  String name;
  String id;
  // double monthlyBudget;
  double salary;

  UserModel({
    required this.email, 
    required this.name,
    required this.id, 
    // required this.monthlyBudget,
    required this.salary,  
    });

  UserModel.fromjson(Map<String, Object?> json) 
    : this(
      email: json['email']! as String,
      name: json['name']! as String,
      id: json['id'] as String,
      // monthlyBudget: json['monthlyBudget'] as double,
      salary: json['salary'] as double,
    ); 

  Map<String, Object?> toJson() {
    return {
      'email': email,
      'name': name,
      'id': id,
      // 'monthlyBudget': monthlyBudget,
      'salary': salary,
    };
  }
}