import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {

  final _formKey = GlobalKey<FormState>();
  DateTime _currentMonth = DateTime.now();
  final categoryController = TextEditingController();
  final budgetController = TextEditingController();
  String category = '';
  double amount = 0.0;
  bool isRecurring = false;
  bool isIncome = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MonthNotifier(_currentMonth),
      child: Consumer<MonthNotifier>(
        builder: (context, monthNotifier, _) {
          return Column(
            children: [
              const Divider(
                color: Colors.grey,
                height: 1,
                thickness: 1,
              ),
           
              Container(  // Month selector
                color: mainColor,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton( // Previous month arrow
                      icon: const Icon(
                        Icons.arrow_left,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        monthNotifier.decrementMonth();
                      },
                    ),

                    Text( // Date text
                      DateFormat.yMMMM().format(monthNotifier.currentMonth),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),

                    IconButton( // Next month arrow
                      icon: const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        monthNotifier.incrementMonth();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(  // Money left to spend + budget
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    FutureBuilder<double>(
                      future: BudgetMethods().getMonthlyBudgetAsync(
                          monthNotifier._currentMonth),
                      builder: (BuildContext context,
                          AsyncSnapshot<double> snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                              'Error: ${snapshot.error}'); // Display error message if any
                        } else {
                          double budgetTotal = snapshot.data?.toDouble() ??
                              0.0; // Default to 0.0 if no data
                          return Text(
                            '\$${budgetTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 60,
                              color: Colors.blue,
                            ),
                          );
                        }
                      }
                    ),
                    //money left to spend
                    FutureBuilder<double>(
                        future: ExpenseMethods()
                            .getRemainingMonthly(monthNotifier._currentMonth),
                        builder: (BuildContext context,
                            AsyncSnapshot<double> snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                                'Error: ${snapshot.error}'); // Display error message if any
                          } else {
                            double moneyLeftToSpend =
                                snapshot.data?.toDouble() ??
                                    0.0; // Default to 0.0 if no data
                            if (moneyLeftToSpend < 0) {
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '\$${moneyLeftToSpend.abs().toStringAsFixed(2)}\n',
                                      style: const TextStyle(
                                        fontSize: 60,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'Overspent',
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ]
                                ),
                                textAlign: TextAlign.center,
                              );
                            } else {
                              return RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '\$${moneyLeftToSpend.abs().toStringAsFixed(2)}\n',
                                      style: const TextStyle(
                                        fontSize: 60,
                                        color: Colors.green
                                      ),
                                    ),
                                    const TextSpan(
                                      text: 'Left to spend',
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ]
                                ),
                                textAlign: TextAlign.center,
                              );
                            }
                          }
                        }),
                    // const Text('Left to spend',
                    //     style: TextStyle(
                    //       fontSize: 30,
                    //       color: Colors.grey,
                    //     )),
                    
                  ],
                )
              ),

              // add budget button
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        color: Colors.white,
                        // Allocate new budget
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      surfaceTintColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10), 
                                        side: const BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        )
                                      ),
                                      backgroundColor: Colors.white,
                                      title: Row(
                                        children: [
                                          Icon(
                                            Icons.monetization_on_rounded,
                                            color: incomeColor,
                                          ),
                                          const SizedBox(width: 20,),
                                          const Text(
                                            'Add Budget',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black
                                            ),
                                          ),
                                          const SizedBox(width: 75,),
                                          IconButton(
                                            onPressed: () {
                                              categoryController.clear();
                                              budgetController.clear();
                                              Navigator.of(context).pop();
                                            },
                                            icon: const Icon(Icons.close,
                                              color: Colors.black,
                                            ),
                                          )
                                        ],
                                      ),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              cursorColor: mainColor,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Enter Category';
                                                } 
                                                return null;
                                              },
                                              controller: categoryController,
                                              decoration: InputDecoration(
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: mainColor)
                                                ),
                                                hintText: 'Category',
                                                hintStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
                                                prefixIcon: const Icon(
                                                  applyTextScaling: true,
                                                  Icons.category_rounded,
                                                  color: Colors.black,
                                                )
                                              ),
                                            ),

                                            TextFormField(
                                              cursorColor: mainColor,
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Enter Amount';
                                                } 
                                                return null;
                                              },
                                              controller: budgetController,
                                              decoration: InputDecoration(
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: mainColor)
                                                ),
                                                hintText: 'Budget Allocation',
                                                hintStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
                                                prefixIcon: const Icon(
                                                  applyTextScaling: true,
                                                  Icons.money_rounded,
                                                  color: Colors.black,
                                                )
                                              ),
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                decimal: true,
                                              ),
                                            ),
                                    
                                            const SizedBox(height: 15.0,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('Recurring',),
                                                    Checkbox(
                                                      activeColor: mainColor,
                                                      value: isRecurring,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          isRecurring = value ?? false;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text('Income only'),
                                                    Checkbox(
                                                      activeColor: mainColor,
                                                      value: isIncome,
                                                      onChanged: (bool? value) {
                                                        setState(() {
                                                          isIncome = value ?? false;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        Center(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mainColor,
                                            ),
                                            onPressed: () {
                                              if (_formKey.currentState!.validate()) {
                                                setState(() {
                                                  category = categoryController.text;
                                                  amount = double.parse(budgetController.text).abs();
                                                });
                                                BudgetMethods().addBudget(category, amount, isRecurring, Colors.black.value.toString(), isIncome, _currentMonth); // Need to give it a color
                                                Navigator.of(context).pop();
                                              }
                                                          
                                              setState(() {
                                                categoryController.clear();
                                                budgetController.clear();
                                              });
                                            },
                                            child: const Text('Save', style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                );
                              });
                        },
                        child: const Text(
                          'Add Budget',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ))
                  ],
                ),
              ),

              // Row to show the Categories label
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        )),
                    Text('Spending / Budget',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ))
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //List view of the categories itself
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                stream: BudgetMethods()
                    .getBudgetsByMonth(monthNotifier._currentMonth),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final budgets = snapshot.data!.docs;

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error fetching data'),
                    );
                  }

                  if (budgets.isEmpty) {
                    return const Center(
                      child: Text('No Budget Found'),
                    );
                  }

                  List<MapEntry<String, dynamic>> allCategories = [];
                  for (var budgetDoc in budgets) {
                    Budget budget = budgetDoc.data() as Budget;
                    // budget.categories.forEach((category, details) { 
                    //   allCategories.add(MapEntry(category, details[0] as double));
                    // });
                    allCategories.addAll(budget.categories.entries);
                  }

                  return ListView.separated(
                    itemCount: allCategories.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      // Budget budget = budgets[index].data() as Budget;
                      // String budgetId = budgets[index].id;
                      // Map<String, double> categories = budget.categories;

                      var entry = allCategories[index];
                      String category = entry.key;
                      double amount = entry.value[0];
                      bool isBudgetRecurring = entry.value[1];
                      Color color = Color(int.parse(entry.value[2]));
                      bool isIncome = entry.value[3];

                      return ListTile(
                        // Update the budget
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                double newAmount = amount;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      surfaceTintColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10), 
                                        side: const BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        )
                                      ),
                                      backgroundColor: Colors.white,
                                      title: Row(
                                        children: [
                                          Icon(
                                            Icons.price_change_outlined,
                                            color: incomeColor
                                          ),
                                          const SizedBox(width: 20,),
                                          const Text(
                                            'Change Budget',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            )
                                          ),
                                          const SizedBox(width: 50,),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }, 
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            )
                                          )
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            cursorColor: mainColor,
                                            initialValue: amount.toStringAsFixed(2),
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                    decimal: true),
                                            decoration: InputDecoration(
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: mainColor)
                                                ),
                                                hintText: 'Budget Allocation',
                                                hintStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
                                                prefixIcon: const Icon(
                                                  applyTextScaling: true,
                                                  Icons.money_rounded,
                                                  color: Colors.black,
                                                )
                                              ),
                                            // Update budget as value is changed
                                            onChanged: (value) {
                                              newAmount =
                                                  double.tryParse(value) ?? amount;
                                              BudgetMethods().updateBudget(category, newAmount, isBudgetRecurring, entry.value[2], isIncome, _currentMonth);
                                            },
                                          ),
                                          const SizedBox(height: 15.0,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Recurring',
                                              ),
                                              Switch(
                                                activeColor: mainColor,
                                                value: isBudgetRecurring,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    isBudgetRecurring = value;
                                                    BudgetMethods().updateBudget(category, newAmount, isBudgetRecurring, entry.value[2], isIncome, _currentMonth);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ]
                                      ),
                                      actions: [
                                        // save button
                                        Center(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mainColor,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Save', style: TextStyle(color: Colors.white),),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                );
                              });
                        },

                        // Delete budget
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                surfaceTintColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), 
                                  side: const BorderSide(
                                    color: Colors.black,
                                    width: 2.0,
                                  )
                                ),
                                backgroundColor: Colors.white,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Delete Budget'
                                    ),
                                    const SizedBox(width: 50,),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                    )
                                  ],
                                ),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Are you sure you want to delete this budget?'),
                                    Text(
                                      'You cannot undo this action!',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )
                                    ),
                                  ]
                                ),
                                actions: [
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        BudgetMethods().deleteBudget(category);
                                        Navigator.of(context).pop();
                                      },
                                      style: ButtonStyle(
                                        side: MaterialStateProperty.resolveWith((states) => const BorderSide(
                                          color: Colors.red,
                                          width: 1.5, 
                                        )),
                                      ),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              );
                            }
                          );
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  child: Icon(Icons.food_bank, color: Colors.white, size: 20),
                              ),
                                SizedBox(width: 16),
                                Text(category),
                              ],
                            ),
                            FutureBuilder<double>(
                                future: ExpenseMethods()
                                    .getMonthlySpendingCategorized(
                                        monthNotifier._currentMonth, category),
                                builder: (BuildContext context,
                                    AsyncSnapshot<double> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(
                                        '${snapshot.error}'); // Display error message if any
                                  } else {
                                    double catSpending = snapshot.data ?? 0.0;

                                    return Text.rich(
                                      TextSpan(
                                        text: catSpending < 0
                                        ? '-\$'
                                        : '\$',
                                        style: TextStyle(
                                          color: catSpending <= amount
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: catSpending < 0
                                            ? catSpending.abs().toStringAsFixed(2)
                                            : catSpending.toStringAsFixed(2),
                                            style: TextStyle(
                                              color: catSpending <= amount
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' / \$${amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color:
                                                  Colors.black, // Default color
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }),
                          ],
                        ),
                      );
                    },
                  );
                },
              ))
            ],
          );
        },
      ),
    );
  }
}

class MonthNotifier extends ChangeNotifier {
  DateTime _currentMonth;

  MonthNotifier(this._currentMonth);

  DateTime get currentMonth => _currentMonth;

  void incrementMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    notifyListeners();
  }

  void decrementMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    notifyListeners();
  }
}