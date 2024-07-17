// ignore_for_file: sized_box_for_whitespace, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/screens/main_screens/insights_screens/insights.dart';
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
  final DateTime _currentMonth = DateTime.now();
  Color? _selectedColor;

  final List<Color> predefinedColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.yellowAccent,
    Colors.limeAccent,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
    Colors.pinkAccent,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MonthNotifier(_currentMonth),
      child: Consumer<MonthNotifier>(builder: (context, monthNotifier, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Divider(color: Colors.grey, height: 1, thickness: 1),

              // Month picker
              _monthPicker(monthNotifier),

              const SizedBox(height: 20),

              // Pie chart with total spending in its center
              _pieChart(monthNotifier._currentMonth),

              // View your insights button
              _viewYourInsightsButton('View your insights'),

              // Header for Categories and Spending
              _header('Categories', 'Spending'),

              // ListView: User categories and spending
              _userCategoriesAndSpending(monthNotifier._currentMonth),
            ],
          ),
        );
      }),
    );
  }

  Widget _monthPicker(MonthNotifier monthNotifier) {
    return Container(
      color: mainColor,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back arrow
          IconButton(
            icon: const Icon(
              Icons.arrow_left,
              color: Colors.white,
            ),
            onPressed: () {
              monthNotifier.decrementMonth();
            },
          ),

          // Date itself
          Text(
            DateFormat.yMMMM().format(monthNotifier.currentMonth),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),

          // Right arrow
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
    );
  }

  Widget _pieChart(DateTime month) {
    return Expanded(
      child: Stack(
        children: [
          // Piechart
          Center(
            child: Container(
              height: 300,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: StreamBuilder(
                    stream: BudgetMethods().getBudgetsByMonth(month),
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
                        return Center(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  color: Colors.grey[200]!,
                                  value: 1,
                                  title: '',
                                ),
                              ],
                              centerSpaceRadius: 80,
                              sectionsSpace: 2,
                            ),
                          ),
                        );
                      }

                      List<Future<PieChartSectionData?>> futureSections = [];
                      for (var budgetDoc in budgets) {
                        Budget budget = budgetDoc.data() as Budget;
                        budget.categories
                            .forEach((category, details) {
                              Color color = Color(int.parse(details[2]));
                              futureSections.add(ExpenseMethods()
                                .getMonthlySpendingCategorized(
                                    month,
                                    category)
                                .then((spending) {
                              if (spending > 0) {
                                return PieChartSectionData(
                                  color: color,
                                  value: spending,
                                  title: '',
                                  titleStyle: const TextStyle(
                                      color: Colors.black),
                                  badgeWidget:
                                      HomeDeco.pieChartTitleWidget(
                                          category,
                                          (-1 * spending),
                                          month),
                                  badgePositionPercentageOffset: 1,
                                );
                              } else {
                                return null;
                              }
                          }));
                        });
                      }

                      return FutureBuilder<List<PieChartSectionData>>(
                          future: Future.wait(futureSections).then(
                              (sections) => sections
                                  .where((section) => section != null)
                                  .cast<PieChartSectionData>()
                                  .toList()),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<PieChartSectionData>>
                                  snapshot) {
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

                            List<PieChartSectionData> sections = snapshot.data!;

                            if (sections.isEmpty) {
                              // Show a grey-out pie chart if no data
                              sections = [
                                PieChartSectionData(
                                  color: Colors.grey[200]!,
                                  value: 1,
                                  title: '',
                                ),
                              ];
                            }

                            return PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 80,
                                sectionsSpace: 2,
                              ),
                            );
                          });
                    }),
              ),
            ),
          ),

          // Centre of the piechart
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StreamBuilder<double>(
                        stream: BudgetMethods()
                            .getMonthlyBudgetStream(
                                month),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.hasError) {
                            return Text(
                                'Error: ${snapshot.error}'); 
                          } else {
                            return StreamBuilder(
                                stream: ExpenseMethods()
                                    .getMonthlySpendingStream(
                                        month),
                                builder: (BuildContext context,
                                    spendingSnapshot) {
                                  if (snapshot.hasError) {
                                    return Text(
                                        'Error: ${snapshot.error}'); 
                                  } else {
                                    double totalSpending =
                                        spendingSnapshot.data
                                                ?.toDouble() ??
                                            0.0;
                                    return Text(
                                      '\$${totalSpending.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    );
                                  }
                                });
                          }
                        }),
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
    );
  }

  Widget _viewYourInsightsButton(String first) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Insights()));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 30), // needed to hardcode the position 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(first),
            const SizedBox(width: 8), 
            const Icon(Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _header(String first, String second) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 16, right: 16, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(first,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            )
          ),
          Text(second,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            )
          ),
        ]
      ),
    );
  }

  Widget _userCategoriesAndSpending(DateTime month) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: BudgetMethods().getBudgetsByMonth(month),
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
              child: Text('No categories found'),
            );
          }

          List<MapEntry<String, List<dynamic>>> allCategories = [];
          
          for (var budgetDoc in budgets) {
            Budget budget = budgetDoc.data() as Budget;
            budget.categories.forEach((category, details) {
              // if-block required to just filter expense categories (i.e. check isIncome == false)
              if (details[3] == false) {
                allCategories
                  .add(MapEntry(category, [
                    details[0] as double,   // amount
                    details[1],             // isRecurring
                    details[2]              // color
                    ]
                  ));
              }                       
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
              double amount = entry.value[0];
              bool isRecurring = entry.value[1];
              Color color = Color(int.parse(entry.value[2]));
              // bool isIncome = entry.value[3]; doesn't work for some reason
                
              return ListTile(
                // Circle Avatar
                leading: GestureDetector(
                  onTap: () {
                    setState(() {
                        _selectedColor = color;
                      });
                    _showColorPickerDialog(_selectedColor!, (newColor) {
                      _selectedColor = newColor;
                      BudgetMethods().updateBudget(category, amount, isRecurring, newColor.value.toString(), false, month);
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor:
                        color,
                    child: const Icon(Icons.food_bank, color: Colors.white, size: 20),
                  ),
                ),

                // Category
                title: FutureBuilder<double>(
                  future: ExpenseMethods().getMonthlySpending(month),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(category); // Display category if there's an error
                    } else if (!snapshot.hasData) {
                      return const CircularProgressIndicator(); // Show a loader if data is still being fetched
                    } else {
                      double netSpend = snapshot.data ?? 0.0;
                      return FutureBuilder<double>(
                        future: ExpenseMethods()
                            .getMonthlySpendingCategorized(
                                month,
                                category),
                        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                          if (snapshot.hasError) {
                            return Text(category); // Display category if there's an error
                          }

                          double spending =
                              snapshot.data ?? 0.0;
                          String percentage = netSpend == 0
                              ? "0.0"
                              : (spending / netSpend * 100)
                                  .toStringAsFixed(1);

                          return Row(
                            children: [
                              Text(category),
                              const SizedBox(width: 8),
                              Text(
                                '($percentage%)',
                                style: const TextStyle(
                                  color: Color.fromARGB(184, 20, 19, 19),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          );
                        }
                      );
                    }
                  }
                ),

                // Spending
                trailing: FutureBuilder<double>(
                    future: ExpenseMethods()
                        .getMonthlySpendingCategorized(
                            month,
                            category),
                    builder: (BuildContext context,
                        AsyncSnapshot<double> snapshot) {
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
                    }),
              );
            });
          }),
    );
  }

  void _showColorPickerDialog(Color initialColor, Function(Color) onColorSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Select Color',
            style: TextStyle(
              color: mainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: initialColor,
              onColorChanged: (Color color) {
                onColorSelected(color);
              },
              availableColors: predefinedColors,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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