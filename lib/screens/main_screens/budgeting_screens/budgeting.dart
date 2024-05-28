import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/main_screens/budgeting_screens/budget_settings.dart';
import 'package:ss/shared/budgeting_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {
  // TODO: replace dummy categories with user categories from firebase
  List<Category> categories = [
    Category(name: 'Food', spending: 100, budget: 200),
    Category(name: 'Transportation', spending: 50, budget: 150),
    Category(name: 'Health', spending: 300, budget: 150),
  ];
  // TODO: replace with firebase values. budgetTotal should be 0 first because initial state
  // user would not have implemented a bnudget
  double monthlyTotalSpent = 450;
  double budgetTotal = 500;
  double moneyLeftToSpend = 50;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
            color: Colors.grey,
            height: 1,
            thickness: 1,
        ),
        // date picker
        Container(
          color: mainColor,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // back arrow
              IconButton(
                icon: const Icon(
                  Icons.arrow_left,
                  color: Colors.white,
                ),
                onPressed: () {
                  // I didn't copy paste the class that u used (monthNotifier) fyi
                  // monthNotifier.decrementMonth();
                },
              ),
              // the date itself
              Text(
                // DateFormat.yMMMM().format(monthNotifier.currentMonth),
                DateFormat.yMMMM().format(DateTime.now()),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              // right arrow
              IconButton(
                icon: const Icon(
                  Icons.arrow_right,
                  color: Colors.white,
                ),
                onPressed: () {
                  // monthNotifier.incrementMonth();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        //Money Left to spend and budget this month
        Container(
          // color: Colors.red,
          height: 200,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              //money left to spend
              Text(
                '\$${moneyLeftToSpend.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 60,
                ),
              ),
              const Text(
                'Left to spend',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                )
              ),
              Text(
                '(Budget this month: \$${budgetTotal.toStringAsFixed(2)})',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                )
              )
            ],
            
          )
        ),
        //row to show the Categories label
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                )
              ),
              Text(
                'Spending / Budget',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                )
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        //List view of the categories itself
        Expanded(
          child: ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              Category category = categories[index];
              return ListTile(
                // if you tap the category tile, you can change the budget
                onTap: () {
                  showDialog(
                    context: context, 
                    builder: (context) {
                      double newBudget = category.budget;
                      return AlertDialog(
                        backgroundColor: Color.fromARGB(255, 255, 239, 242),
                        title: const Text(
                          'Change Budget',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                        content: TextFormField(
                          initialValue: category.budget.toStringAsFixed(2),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (value) {
                            // update newBudget
                            newBudget = double.tryParse(value) ?? category.budget;
                          },
                        ),
                        actions: [
                          // cancel button
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();                        
                            },
                            child: const Text(
                              'Cancel',
                              // style: TextStyle(
                              //   color: Colors.black,
                              // ),
                            )
                          ),
                          // save button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                //when saved, old category budeget is replaced with new
                                category.budget = newBudget;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Save',
                              // style: TextStyle(
                              //   color: Colors.black,
                              // ),
                            )
                          ),
                        ],
                      );
                    }
                  );
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.name),
                    Text.rich(
                      TextSpan(
                        text: '\$',
                        style: TextStyle(
                          color: category.spending < category.budget ? Colors.green : Colors.red,
                        ),
                        children: [
                          TextSpan(
                            text: '${category.spending.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: category.spending < category.budget ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${category.budget.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.black, // Default color
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        )
      ],
    );
  }
}

class Category {
  String name;
  double spending;
  double budget;

  Category({required this.name, required this.spending, required this.budget});
}
