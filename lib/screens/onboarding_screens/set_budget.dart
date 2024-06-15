import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/main_screens/home_screens/home.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class SetBudget extends StatefulWidget {
  final Map<String, Color> categoryColors;

  const SetBudget({super.key, required this.categoryColors});

  @override
  State<SetBudget> createState() => _SetBudgetState();
}

class _SetBudgetState extends State<SetBudget> {
  final Map<String, TextEditingController> _budgetControllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    for (var category in widget.categoryColors.keys) {
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
            fontSize: 18,
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
            children: widget.categoryColors.keys.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ListTile(
                  title: Text(category),
                  leading: CircleAvatar(
                    backgroundColor: widget.categoryColors[category],
                  ),
                  trailing: _amountWidget(category), // See Helper 1
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
                    (category, controller) {
                      budgetAllocations[category] = [
                        double.parse(controller.text.trim()), // amount
                        true, // isRecurring
                        widget.categoryColors[category]!.value.toString(), // color
                      ];
                    },
                  );

                  for (var entry in budgetAllocations.entries) {
                    await BudgetMethods().addBudget(entry.key, entry.value[0], entry.value[1], entry.value[2]);
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
