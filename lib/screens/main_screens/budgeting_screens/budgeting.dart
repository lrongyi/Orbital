import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {

  DateTime _currentMonth = DateTime.now();
  final categoryController = TextEditingController();
  final budgetController = TextEditingController();

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
                height: 150,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    //money left to spend
                    FutureBuilder<double>(
                      
                      future: DatabaseMethods().getRemainingMonthly(monthNotifier._currentMonth),
                      
                      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}'); // Display error message if any
                        } else {
                          double moneyLeftToSpend = snapshot.data?.toDouble() ?? 0.0; // Default to 0.0 if no data
                          return Text(
                            '\$${moneyLeftToSpend.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 60,
                              color: moneyLeftToSpend < 0 ? Colors.red : Colors.green
                            ),
                          );
                        }
                      }
                    ),
                    const Text(
                      'Left to spend',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      )
                    ),
                    FutureBuilder<double>(
                      
                      future: DatabaseMethods().getMonthlyBudgetAsync(monthNotifier._currentMonth),
                      
                      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}'); // Display error message if any
                        } else {
                          double budgetTotal = snapshot.data?.toDouble() ?? 0.0; // Default to 0.0 if no data
                          return Text(
                            '(Budget this month: \$${budgetTotal.toStringAsFixed(2)})',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            ),
                          );
                        }
                      }
                    )
                  ],
                  
                )
              ),
              // add budget button
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      color: Colors.white,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text(
                                'Add Budget',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,                           
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: categoryController,
                                    decoration: const InputDecoration(
                                      labelText: 'Category'
                                    ),
                                  ),
                                  TextFormField(
                                    controller: budgetController,
                                    decoration: const InputDecoration(
                                      labelText: 'Budget Value',
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    categoryController.clear();
                                    budgetController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.black,
                                    )
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Perform save operation (firebase)

                                    categoryController.clear();
                                    budgetController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: Colors.black,
                                    )
                                  ),
                                ),
                              ],
                            );
                          }
                        );
                      },
                      child: const Text(
                        'Add Budget',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    )
                
                  ],
                ),
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
                child: StreamBuilder<QuerySnapshot> (
                  
                  stream: DatabaseMethods().getBudgetsByMonth(monthNotifier._currentMonth),
                  
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

                    List<MapEntry<String, double>> allCategories = [];
                    for (var budgetDoc in budgets) {
                      Budget budget = budgetDoc.data() as Budget;
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
                        double amount = entry.value;

                        return ListTile(
                          // if you tap the category tile, you can change the budget
                          onTap: () {
                            showDialog(
                              context: context, 
                              builder: (context) {
                                double newAmount = amount;
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
                                    initialValue: amount.toStringAsFixed(2),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (value) {
                                      // update newBudget
                                      newAmount = double.tryParse(value) ?? amount;
                                      DatabaseMethods().updateBudget(category, newAmount);
                                    },
                                  ),
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
                                      )
                                    ),
                                  ],
                                );
                              }
                            );
                          },
                          onLongPress: () {
                            // Delete the budget
                            // add some type of confirmation 
                            DatabaseMethods().deleteBudget(category);
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(category),
                              FutureBuilder<double>(
                                
                                future: DatabaseMethods().getMonthlySpendingCategorized(monthNotifier._currentMonth, category),
                                
                                builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('${snapshot.error}'); // Display error message if any
                                  } else {
                                    
                                    double catSpending = snapshot.data ?? 0.0;

                                    return Text.rich(
                                      TextSpan(
                                        text: '\$',
                                        style: TextStyle(
                                          color: catSpending < amount ? Colors.green : Colors.red,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: catSpending.toStringAsFixed(2),
                                            style: TextStyle(
                                              color: catSpending < amount ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' / \$${amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Colors.black, // Default color
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                }
                              ),
                            ],
                          ),
                        );
                      },
                    );  
                  },
                )
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