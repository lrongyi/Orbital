import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/category_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/models/category.dart';
import 'package:ss/shared/main_screens_deco.dart';
import 'package:uuid/uuid.dart';

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
  bool isRecurring = true;

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
                        monthNotifier.decrementMonth();
                      },
                    ),

                    // the date itself
                    Text(
                      DateFormat.yMMMM().format(monthNotifier.currentMonth),
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
                        monthNotifier.incrementMonth();
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0), 
                                      ),
                                      backgroundColor: Colors.white,
                                      title: const Text(
                                        'Add Budget',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Enter Category';
                                                } 
                                                return null;
                                              },
                                              controller: categoryController,
                                              decoration: const InputDecoration(
                                                  labelText: 'Category'),
                                            ),
                                            TextFormField(
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Enter Amount';
                                                } 
                                                return null;
                                              },
                                              controller: budgetController,
                                              decoration: const InputDecoration(
                                                labelText: 'Budget Allocated',
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
                                                const Text(
                                                  'Recurring',
                                                ),
                                                Switch(
                                                  activeColor: mainColor,
                                                  value: isRecurring,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      isRecurring = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            categoryController.clear();
                                            budgetController.clear();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel',
                                            style: TextStyle(
                                              color: Colors.black,
                                            )
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              setState(() {
                                                category = categoryController.text;
                                                amount = double.parse(budgetController.text).abs();
                                              });
                                              
                                              Category newCategory = Category(
                                                id: const Uuid().v1(), 
                                                name: category, 
                                                isRecurring: isRecurring, 
                                                color: Colors.black.toString(), 
                                                icon: 'empty'
                                              );

                                              CategoryMethods().addCategory(newCategory);
                                              DocumentReference newCategoryDocRef = await CategoryMethods().getDocRef(newCategory);
                                              BudgetMethods().addBudget(Budget(month: Timestamp.fromDate(DateTime.now()), amount: amount, categoryId: newCategoryDocRef.id));

                                              Navigator.of(context).pop();
                                            }
                                                        
                                            setState(() {
                                              categoryController.clear();
                                              budgetController.clear();
                                            });
                                          },
                                          child: const Text('Save',
                                            style: TextStyle(
                                              color: Colors.black,
                                            )
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
                  stream: BudgetMethods().getBudgetsByMonth(monthNotifier._currentMonth),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error fetching data'),
                      );
                    }

                    final budgets = snapshot.data!.docs;

                    if (budgets.isEmpty) {
                      return const Center(
                        child: Text('No Budget Found'),
                      );
                    }

                    // Create a list of pairs of document ID and budget
                    List<MapEntry<String, Budget>> budgetList = budgets.map((doc) {
                      return MapEntry(doc.id, Budget.fromJson(doc.data() as Map<String, dynamic>));
                    }).toList();

                    return FutureBuilder<List<Category>>(
                      future: CategoryMethods().getAllCategoriesAsList(),
                      builder: (context, categorySnapshot) {
                        if (!categorySnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (categorySnapshot.hasError) {
                          return const Center(
                            child: Text('Error fetching categories'),
                          );
                        }

                        final List<Category> categories = categorySnapshot.data!;
                        
                        // Bug to fix: this assumes the categoryId for entry.value.categoryId to be the same as the cat.id but no it is not
                        // since cat.id is Uuid but budget.categoryId is docRef 
                        // I think can still work we just change this docRef into a category again then get the id
                        // The reason i'm doing this roundabout way is because the UpdateCategory button will not work if it was Uuid
                        // since updateCategory assumes the id 
                        List<MapEntry<Budget, Category>> budgetCategory/Entries = budgetList.map((entry) {
                          final category = categories.firstWhere((cat) => cat.id == entry.value.categoryId);
                          return MapEntry(entry.value, category); 
                        }).toList();

                       

                        return ListView.separated(
                          itemCount: budgetCategoryEntries.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            var entry = budgetCategoryEntries[index];
                            Budget budget = entry.key;
                            double amount = budget.amount;
                            Category category = entry.value;
                            bool isRecurring = category.isRecurring;
                            String budgetId = budgetList[index].key; // Get the document ID

                            return ListTile(
                              // Update the budget
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      double newAmount = amount;
                                      return StatefulBuilder(builder: (context, setState) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          backgroundColor: Colors.white,
                                          title: const Text('Change Budget',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              )),
                                          content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  initialValue: amount.toStringAsFixed(2),
                                                  keyboardType:
                                                      const TextInputType.numberWithOptions(
                                                          decimal: true),

                                                  // Update budget as value is changed
                                                  onChanged: (value) {
                                                    newAmount =
                                                        double.tryParse(value) ?? amount;
                                                  },
                                                ),
                                                const SizedBox(
                                                  height: 15.0,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    const Text(
                                                      'Recurring',
                                                    ),
                                                    Switch(
                                                      activeColor: mainColor,
                                                      value: isRecurring,
                                                      onChanged: (bool value) {
                                                        setState(() {
                                                          isRecurring = value;
                                                          CategoryMethods().updateCategory(
                                                              budget.categoryId,
                                                              category.copyWith(
                                                                  isRecurring: value));
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ]),
                                          actions: [
                                            // save button
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Save',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                )),
                                          ],
                                        );
                                      });
                                    });
                              },

                              // Delete budget
                              onLongPress: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          backgroundColor: Colors.white,
                                          title: const Text('Delete Budget'),
                                          content: const Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Are you sure you want to delete this budget?'),
                                                Text('You cannot undo this action!',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                              ]),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cancel',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  )),
                                            ),

                                            // Delete here

                                            TextButton(
                                              onPressed: () {
                                                BudgetMethods().deleteBudget(budgetId);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  )),
                                            ),
                                          ]);
                                    });
                              },

                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(category.name),
                                  FutureBuilder<double>(
                                      future: ExpenseMethods()
                                          .getMonthlySpendingCategorized(
                                              monthNotifier._currentMonth, category.name),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<double> snapshot) {
                                        if (snapshot.hasError) {
                                          return Text(
                                              '${snapshot.error}'); // Display error message if any
                                        } else {
                                          double catSpending = snapshot.data ?? 0.0;

                                          return Text.rich(
                                            TextSpan(
                                              text: catSpending < 0 ? '-\$' : '\$',
                                              style: TextStyle(
                                                color: catSpending <= amount
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: catSpending < 0
                                                      ? catSpending
                                                          .abs()
                                                          .toStringAsFixed(2)
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
                                                    color: Colors.black, // Default color
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
                    );
                  },
                ),
              )

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
