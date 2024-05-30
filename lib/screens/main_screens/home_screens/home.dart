import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/budget.dart';
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
                Stack(
                  children: [
                    
                    // Piechart
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: StreamBuilder(
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
                              child: Text('No Spending Found'),
                            );
                          }

                          List<Future<PieChartSectionData?>> futureSections = [];
                          List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red];
                          Random random = Random();
                          
                          for (var budgetDoc in budgets) {
                            Budget budget = budgetDoc.data() as Budget;
                            budget.categories.forEach((category, spending) {
                              futureSections.add(
                                DatabaseMethods().getMonthlySpendingCategorized(monthNotifier._currentMonth, category)
                                .then(
                                  (spending) {
                                    if (spending > 0) {
                                      Color color = colorManager.getColorForCategory(category);
                                      return PieChartSectionData(
                                      color: color,
                                      value: spending,
                                      title: category,
                                      titleStyle: const TextStyle(color: Colors.black),
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
                                  centerSpaceRadius: 100,
                                ),
                              );
                            }
                          );
                        }
                      ),
                    ),

                    // Centre of the piechart
                    Positioned.fill(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StreamBuilder<double>(
                              
                              stream: DatabaseMethods().getMonthlyBudgetStream(monthNotifier._currentMonth),
                              
                              builder: (BuildContext context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}'); // Display error message if any
                                } else {
                                  double budget = snapshot.data?.toDouble() ?? 0.0; // Default to 0.0 if no data
                                  return StreamBuilder(
                                    
                                    stream: DatabaseMethods().getMonthlySpendingStream(monthNotifier._currentMonth), 
                                    
                                    builder: (BuildContext context, spendingSnapshot) {
                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}'); // Display error message if any
                                      } else {
                                        double totalSpending = spendingSnapshot.data?.toDouble() ?? 0.0;
                                        return Text(
                                          '\$${totalSpending.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 40,
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
                              'Total monthly spending',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                // Categories label + View All button
                // For some reason the outer padding doesn't work
                // So the row needs its own padding

                // Header for Categories and Amount
                const Padding(
                  padding: EdgeInsets.only(top: 0, bottom: 16, right: 16, left: 16),
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
                          child: Text('No Spending Found'),
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
                            leading: CircleAvatar(
                              backgroundColor: colorManager.getColorForCategory(category),
                              // child: Icon(Icons.category, color: Colors.white),
                            ),
                            
                            // Category 
                            title: Text(category),

                            // Spending
                            trailing: FutureBuilder<double>(

                              future: DatabaseMethods().getMonthlySpendingCategorized(monthNotifier._currentMonth, category),

                              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                                
                                if (snapshot.hasError) {
                                    return Text('${snapshot.error}'); 
                                }

                                double spending = snapshot.data ?? 0.0;

                                return Text(
                                  '\$${spending.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                );
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