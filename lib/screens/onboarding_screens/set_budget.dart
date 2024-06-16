<<<<<<< HEAD
=======
import 'dart:async';
import 'package:flutter/foundation.dart';
>>>>>>> origin/old-backend-muhd
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/category_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/models/category.dart';
import 'package:ss/services/user_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class SetBudget extends StatefulWidget {
<<<<<<< HEAD
=======
  final Map<String, Color> categoryColors;

  const SetBudget({super.key, required this.categoryColors});

>>>>>>> origin/old-backend-muhd
  @override
  _SetBudgetState createState() => _SetBudgetState();
}

class _SetBudgetState extends State<SetBudget> {
<<<<<<< HEAD
  late List<Category> categories;
  late Map<String, TextEditingController> budgetControllers;
  final _formKey = GlobalKey<FormState>();

=======
  final Map<String, TextEditingController> _budgetControllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    for (var category in widget.categoryColors.keys) {
      _budgetControllers[category] = TextEditingController(text: "0");
    }
  }

>>>>>>> origin/old-backend-muhd
  @override
  void dispose() {
    budgetControllers.forEach((_, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    budgetControllers = {}; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Set Budget Allocation',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
      ),
<<<<<<< HEAD

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot<Category>>(
          stream: CategoryMethods().getCategories(),
          builder: (context, snapshot) {
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No categories found. Press Skip'));
            } else {

              categories = snapshot.data!.docs.map((doc) => doc.data()).toList();
              _initialiseBudgetControllers(); // See Helper 1
        
              return Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: CategoryMethods().getCategoryColor(category.color),
                        ),
                        title: Text(category.name),
                        trailing: SizedBox(
                          width: 75,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Empty';
                              }
                              return null;
                            },
                            controller: budgetControllers[category.name],
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              labelStyle:
                                  TextStyle(color: mainColor, fontSize: 12),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainColor),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                              
                      ),
                    );
                  },
=======
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: widget.categoryColors.keys.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  title: Text(category),
                  leading: CircleAvatar(
                    backgroundColor: widget.categoryColors[category],
                  ),
                  trailing: _amountWidget(category), // See Helper 1
>>>>>>> origin/old-backend-muhd
                ),
              );
            }
          },
        ),
      ),
      bottomSheet: _buildBottomSheet(context), // See Helper 2
    );
  }

  // Helper 1: Initialise budget controllers
  void _initialiseBudgetControllers() {
    for (Category category in categories) {
      budgetControllers[category.name] = TextEditingController();
    }
  } 


  // Helper 2: Bottom Sheet
  Widget _buildBottomSheet(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          child: const Text(
            'Skip',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
            ),
<<<<<<< HEAD
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
              (route) => false,
            );
          },
        ),
        SizedBox(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: mainColor,
              elevation: 10.0,
            ),
            child: const Text('Submit'),
            onPressed: () async {
              
              if (_formKey.currentState!.validate()) {
                  final Map<String, double> budgetAllocations = {};
                  budgetControllers.forEach(
=======
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
                (route) => false,
              );
            },
          ),
          SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: mainColor,
                elevation: 10.0,
              ),
              child: const Text('Submit'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final Map<String, List<dynamic>> budgetAllocations = {};
                  _budgetControllers.forEach(
>>>>>>> origin/old-backend-muhd
                    (category, controller) {
                      budgetAllocations[category] = [
                        double.parse(controller.text.trim()), // amount
                        true, // isRecurring
                        widget.categoryColors[category]!.value.toString(), // color
                      ];
                    },
                  );

<<<<<<< HEAD
                  QuerySnapshot<Budget> querySnapshot = await BudgetMethods().getBudgetRef(UserMethods().getCurrentUserId()).get();
                  final existingBudget = querySnapshot.docs;
                  
                  for (var entry in budgetAllocations.entries) {
                    final category = categories.firstWhere((cat) => cat.name == entry.key);
                    final amount = entry.value;

                    final budgetDoc = existingBudget.firstWhere((doc) => doc.data().categoryId == category.id);

                    BudgetMethods().updateBudget(budgetDoc.id, Budget(month: Timestamp.fromDate(DateTime.now()), amount: amount, categoryId: category.id));

=======
                  for (var entry in budgetAllocations.entries) {
                    await BudgetMethods().addBudget(entry.key, entry.value[0], entry.value[1], entry.value[2]);
>>>>>>> origin/old-backend-muhd
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fill in all fields'),
                      backgroundColor: Colors.red,
                      showCloseIcon: true,
                    ),
                  );
                }
<<<<<<< HEAD
                
            },
          ),
        ),
      ],
    );
  }

}

=======
              },
            ),
          )
        ],
      ),
    );
  }

  // Helper 1: Amount Field
  Widget _amountWidget(String category) {
    return SizedBox(
      width: 75,
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Empty';
          }
          return null;
        },
        controller: _budgetControllers[category],
        decoration: InputDecoration(
          labelText: 'Amount',
          labelStyle: TextStyle(color: mainColor, fontSize: 12),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mainColor),
          ),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
>>>>>>> origin/old-backend-muhd
