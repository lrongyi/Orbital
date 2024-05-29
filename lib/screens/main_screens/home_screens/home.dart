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
  // Dummy data for demonstration
  // Need to link with the Add category button in budgeting.
  final List<Category> categories = [
    Category(
        name: 'Food', spending: 200, color: Colors.blue, icon: Icons.fastfood),
    Category(
        name: 'Transportation',
        spending: 150,
        color: Colors.green,
        icon: Icons.directions_car),
    Category(
        name: 'Entertainment',
        spending: 100,
        color: Colors.orange,
        icon: Icons.movie),
  ];

  // Piechart Colors
  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.yellow,
    Colors.cyan,
  ];

  // To get a random color for the piechart
  final Random random = Random();

  DateTime _currentMonth = DateTime.now();

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
                      child: PieChart(
                        PieChartData(
                          sections: categories.map((category) {
                            return PieChartSectionData(
                              color: colors[random.nextInt(colors.length)],
                              value: category.spending,
                              title: '',
                            );
                          }).toList(),
                        ),
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

                  // Icon for each category 
                  // child: ListView.builder(
                  //   itemCount: categories.length,
                  //   itemBuilder: (context, index) {
                  //     return ListTile(
                  //       leading: CircleAvatar(
                  //         backgroundColor: categories[index].color,
                  //         child: Icon(categories[index].icon, color: Colors.white),
                  //       ),
                  //       title: Text(categories[index].name),
                  //       trailing: Text(
                  //         '\$${categories[index].spending.toStringAsFixed(2)}',
                  //         style: const TextStyle(
                  //           fontSize: 17,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),

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
                            // leading: CircleAvatar(
                            //   backgroundColor: categories[index].color,
                            //   child: Icon(categories[index].icon, color: Colors.white),
                            // ),
                            
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

class Category {
  final String name;
  final double spending;
  final Color color;
  final IconData icon;

  Category(
      {required this.name,
      required this.spending,
      required this.color,
      required this.icon});
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