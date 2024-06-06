import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/shared/home_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  DateTime _currentMonth = DateTime.now();
  final ColorManager colorManager = ColorManager();

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => MonthNotifier(_currentMonth),
      child: Consumer<MonthNotifier>(
      builder: (context, monthNotifier, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
          
                // Pie chart with total spending in its center                
                Expanded(
                  child: Stack(
                    children: [
                      
                      // Piechart
                      Center(
                        child: Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            // width: 300,
                            // height: 300,
                            child: StreamBuilder(
                              stream: BudgetMethods().getBudgetsByMonth(monthNotifier._currentMonth),
                                            
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
                                    child: Text(''),
                                  );
                                }
                                            
                                List<Future<PieChartSectionData?>> futureSections = [];
                                for (var budgetDoc in budgets) {
                                  Budget budget = budgetDoc.data() as Budget;
                                  budget.categories.forEach((category, spending) {
                                    futureSections.add(
                                      ExpenseMethods().getMonthlySpendingCategorized(monthNotifier._currentMonth, category)
                                      .then(
                                        (spending) {
                                          if (spending > 0) {
                                            Color color = colorManager.getColorForCategory(category);
                                            return PieChartSectionData(
                                            color: color,
                                            value: spending,
                                            title: '',
                                            titleStyle: const TextStyle(color: Colors.black),
                                            badgeWidget: HomeDeco.pieChartTitleWidget(
                                              category, (-1 * spending), monthNotifier._currentMonth
                                            ),
                                            badgePositionPercentageOffset: 1,
                                            );
                                          } else {
                                            return null;
                                          }
                                        }
                                      )
                                    );
                                  });
                                }
                                            
                                return FutureBuilder<List<PieChartSectionData>>(
                                  future: Future.wait(futureSections).then((sections) =>
                                    sections.where((section) => section != null).cast<PieChartSectionData>().toList()),
                                  builder: (BuildContext context, AsyncSnapshot<List<PieChartSectionData>> snapshot) {
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
                                            
                                    return PieChart(
                                      PieChartData(
                                        sections: snapshot.data!,
                                        centerSpaceRadius: 80,
                                        sectionsSpace: 2,
                                      ),
                                    );
                                  }
                                );
                              }
                            ),
                          ),
                        ),
                      ),
                  
                      // Centre of the piechart
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                StreamBuilder<double>(
                                  
                                  stream: BudgetMethods().getMonthlyBudgetStream(monthNotifier._currentMonth),
                                  
                                  builder: (BuildContext context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}'); // Display error message if any
                                    } else {
                                      double budget = snapshot.data?.toDouble() ?? 0.0; // Default to 0.0 if no data
                                      return StreamBuilder(
                                        
                                        stream: ExpenseMethods().getMonthlySpendingStream(monthNotifier._currentMonth), 
                                        
                                        builder: (BuildContext context, spendingSnapshot) {
                                          if (snapshot.hasError) {
                                            return Text('Error: ${snapshot.error}'); // Display error message if any
                                          } else {
                                            double totalSpending = spendingSnapshot.data?.toDouble() ?? 0.0;
                                            return Text(
                                              '\$${totalSpending.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: totalSpending > budget ? Colors.red : totalSpending < 0 ? Colors.green : Colors.black,
                                              ),
                                            );
                                          }
                                        }
                                      );   
                                    }
                                  }
                                ),
                                              
                                const Text(
                                  'Monthly spending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
                // Net change display (WIP)
                // Container(
                //   padding: EdgeInsets.only(top: 10),
                //   // color: Colors.red,
                //   height: 20,
                //   child: Text(
                //     'Net Change: ',                 
                //     textAlign: TextAlign.start,
                //   )
                // ),
          
                // Header for Categories and Amount
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16, right: 16, left: 16),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Categories',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            )),
                        Text('Spending',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            )),
                      ]),
                ),
          
                // List of user's categories and spending
                Expanded(
          
                  child: StreamBuilder(
                    
                    stream: BudgetMethods().getBudgetsByMonth(monthNotifier._currentMonth),
          
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
                          child: Text('No Spending Found'),
                        );
                      }
          
                      List<MapEntry<String, double>> allCategories = [];
                      for (var budgetDoc in budgets) {
                        Budget budget = budgetDoc.data() as Budget;
                        budget.categories.forEach((category, details) { 
                          allCategories.add(MapEntry(category, details[0] as double));
                        });
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
                            leading: CircleAvatar(
                              backgroundColor: colorManager.getColorForCategory(category),
                              // child: Icon(Icons.category, color: Colors.white),
                            ),
                            
                            // Category 
                            title: Text(category),
          
                            // Spending
                            trailing: FutureBuilder<double>(
          
                              future: ExpenseMethods().getMonthlySpendingCategorized(monthNotifier._currentMonth, category),
          
                              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                                
                                if (snapshot.hasError) {
                                    return Text('${snapshot.error}'); 
                                }
          
                                double spending = snapshot.data ?? 0.0;
          
                                // return Text(
                                //   '\$${spending.toStringAsFixed(2)}',
                                //   style: const TextStyle(
                                //     fontSize: 17,
                                //   ),
                                // );
                                if (spending < 0) {
                                  return Text(
                                  '-\$${spending.abs().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    ),       
                                  );
                                } else {
                                  return Text(
                                  '\$${spending.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    ),       
                                  );
                                }
                              }
                            ),
                          );
                        }
                      );
                    }
                  ),
                ),   
              ],
            ),
          );
        }
      ),
    );
  }
}

class ColorManager {
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.brown,
    Colors.indigo,
    Colors.pink,
  ];

  final Map<String, Color> _assignedColors = {};

  Color getColorForCategory(String category) {
    if (_assignedColors.containsKey(category)) {
      return _assignedColors[category]!;
    } else {
      // Find a color that hasn't been assigned yet
      for (var color in _availableColors) {
        if (!_assignedColors.containsValue(color)) {
          _assignedColors[category] = color;
          return color;
        }
      }
      // If all colors are assigned, default to a hash-based color (optional)
      int hash = category.hashCode;
      int index = hash % _availableColors.length;
      Color color = _availableColors[index];
      _assignedColors[category] = color;
      return color;
    }
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