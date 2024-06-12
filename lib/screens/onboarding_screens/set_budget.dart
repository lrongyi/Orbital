import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/category_methods.dart';
import 'package:ss/services/models/category.dart';
import 'package:ss/shared/main_screens_deco.dart';

class SetBudget extends StatefulWidget {
  @override
  _SetBudgetState createState() => _SetBudgetState();
}

class _SetBudgetState extends State<SetBudget> {
  late List<Category> categories;
  late Map<String, TextEditingController> budgetControllers;
  final _formKey = GlobalKey<FormState>();

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
        
              return ListView.builder(
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
            // Check if any field is empty
            if (budgetControllers.values.any((controller) => controller.text.isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fill in all fields'),
                  backgroundColor: Colors.red,
                  showCloseIcon: true,
                ),
              );
              return; // Terminate early
            }

            // Continue with validation if fields are not empty
            if (_formKey.currentState!.validate()) {
              final Map<String, double> budgetAllocations = {};
              budgetControllers.forEach(
                (categoryName, controller) {
                  budgetAllocations[categoryName] = double.parse(controller.text.trim());
                },
              );

              BuildContext currentContext = context;

              for (var entry in budgetAllocations.entries) {
                await BudgetMethods().addBudget(entry.key, entry.value, false);
              }

              Navigator.pushAndRemoveUntil(
                currentContext,
                MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
                (route) => false,
              );
            }
          },
        ),
      ),
    ],
  );
}

}

