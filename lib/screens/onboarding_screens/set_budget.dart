import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/main_screens/home_screens/home.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class SetBudget extends StatefulWidget {

  final Set<String> selectedCategories;

  const SetBudget({super.key, required this.selectedCategories});

  @override
  State<SetBudget> createState() => _SetBudgetState();
}

class _SetBudgetState extends State<SetBudget> {

  final Map<String, TextEditingController> _budgetControllers = {};
  final _formKey = GlobalKey<FormState>();

  @override 
  void initState() {
    super.initState();
    for (var category in widget.selectedCategories) {
      _budgetControllers[category] = TextEditingController(text: "0");
    }
  }

  @override
  void dispose() {
    _budgetControllers.forEach((_, controller) {
      controller.dispose();
     });
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Budget Allocation',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 18
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: widget.selectedCategories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),

                    SizedBox(
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
                    ),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      bottomSheet: Row(
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
                    (route) => false
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
                  _budgetControllers.forEach(
                    (category, controller) {
                      budgetAllocations[category] = double.parse(controller.text.trim());
                    }
                  );
                  
                  for (var entry in budgetAllocations.entries) {
                    await BudgetMethods().addBudget(entry.key, entry.value, true);
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
                    (route) => false
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fill in all fields'),
                      backgroundColor: Colors.red,
                      showCloseIcon: true,
                    )
                  );
                }
                
              },
            ),
          )
        ],
      ),
    );
  }
}