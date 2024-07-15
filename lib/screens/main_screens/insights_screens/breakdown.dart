import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/user_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';
import 'package:fl_chart/fl_chart.dart';

class Breakdown extends StatefulWidget {
  const Breakdown({Key? key}) : super(key: key);

  @override
  State<Breakdown> createState() => _BreakdownState();
}

class _BreakdownState extends State<Breakdown> {
  bool allBudgetsMet = true;
  bool isOverallNetFlowPositive = false;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _checkAllBudgetsMet();
    _checkPositiveOverallNetFlow();
    _retrieveUsername();
  }

  Future<void> _checkAllBudgetsMet() async {
    DateTime now = DateTime.now();

    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      int totalBudgets = await getTotalBudgetCount(month);
      int budgetsWithinZone = await getBudgetsWithinZone(month);

      if (budgetsWithinZone != totalBudgets) {
        setState(() {
          allBudgetsMet = false;
        });
        return;
      }
    }
  }

  Future<void> _checkPositiveOverallNetFlow() async {
    DateTime now = DateTime.now();
    double overallNetFlow = 0.0;

    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      double netFlow = await ExpenseMethods().getMonthlyNetChange(month);
      overallNetFlow += netFlow;
    }

    setState(() {
      isOverallNetFlowPositive = overallNetFlow > 0;
    });
  }

  // This one increased the loading time by a bit 
  Future<void> _retrieveUsername() async {
    String temp = await UserMethods().getUserNameAsync();

    setState(() {
      userName = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Monthly Spending vs Budget',
          style: TextStyle(
            color: mainColor,
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.white, // Customize app bar color as needed
        leading: IconButton(
          icon: Icon(
            Icons.close, // Close icon (X)
            color: mainColor, // Icon color
          ),
          onPressed: () {
            Navigator.pop(context); // Pop current context on icon press
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBarChart(),
            _buildDetailsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsList() {
    return FutureBuilder<List<Widget>>(
      future: _buildBudgetTiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: allBudgetsMet ? Colors.green : Colors.amber,
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: ListTile(
                  leading: Icon(
                    allBudgetsMet ? Icons.sentiment_very_satisfied : Icons.sentiment_dissatisfied,
                    color: allBudgetsMet ? Colors.green : Colors.amber,
                    size: 50,
                  ),
                  title: Text(
                    allBudgetsMet 
                        ? 'Good job, $userName! You\'ve met all your budgets within these 5 months!'
                        : 'Oh no, $userName! You did not meet all your budgets within these 5 months!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isOverallNetFlowPositive ? Colors.green : Colors.red,
                    width: 2,
                  ),
                  color: Colors.white,
                ),
                child: ListTile(
                  leading: Icon(
                    isOverallNetFlowPositive ? Icons.sentiment_very_satisfied : Icons.sentiment_dissatisfied,
                    color: isOverallNetFlowPositive ? Colors.green : Colors.red,
                    size: 50,
                  ),
                  title: Text(
                    isOverallNetFlowPositive
                        ? 'Good job, $userName! Your overall net flow is positive!'
                        : 'Oh no, $userName! Your overall net flow isn\'t looking good! Let\'s work on it!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              if (snapshot.hasData && snapshot.data!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 120),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Budgets Met',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 25),
                          Icon(
                            Icons.trending_up, // Replace with your suitable icon for Net Flow
                            color: Colors.black,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Net Flow',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => Navigation(state: 2)),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'View budgets',
                                style: TextStyle(
                                  color: Colors.blue,
                                )
                              )
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => Navigation(state: 1)),
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'View transactions',
                                style: TextStyle(
                                  color: mainColor,
                                )
                              )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ...snapshot.data ?? [const Text('No data available')],
            ],
          );
        }
      },
    );
  }


  Future<List<Widget>> _buildBudgetTiles() async {
  List<Widget> tiles = [];
  DateTime now = DateTime.now();

  for (int i = 0; i < 5; i++) {
    DateTime month = DateTime(now.year, now.month - i, 1);
    int totalBudgets = await getTotalBudgetCount(month);
    int budgetsWithinZone = await getBudgetsWithinZone(month);
    // int budgetsWithinZone = 0;

    tiles.add(
      Padding(
        padding: const EdgeInsets.only(left: 30, top: 8.0, right: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat.MMMM().format(month),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[600],
                // color: Colors.blue[200],
              ),
            ),
            Row(
              children: [
                Icon(
                  budgetsWithinZone < totalBudgets ? Icons.close : Icons.check,
                  color: budgetsWithinZone < totalBudgets ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 15),
                Text(
                  '$budgetsWithinZone/$totalBudgets',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 60),
                _buildNetFlow(month),
              ],
            ),
          ],
        ),
      ),
    );
  }
  return tiles;
}

Widget _buildNetFlow(DateTime month) {
  return FutureBuilder<double>(
    future: ExpenseMethods().getMonthlyNetChange(month),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SizedBox(
          width: 120,
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        double netChange = snapshot.data ?? 0.0;
        String sign = netChange > 0 ? '+' : netChange < 0 ? '-' : '';

        return Container(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$sign\$${netChange.abs().toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      }
    },
  );
}

  Future<int> getTotalBudgetCount(DateTime month) async {
    try {
      // Retrieve current month's budget categories
      List<String> categories = await BudgetMethods().getExpenseList(month);

      // Return the total number of categories
      return categories.length;
    } catch (e) {
      print('Error retrieving total budget count: $e');
      return 0;
    }
  }

  Future<int> getBudgetsWithinZone(DateTime month) async {
    try {
      // Fetch the number of budgets within the zone for the given month
      int budgetsWithinZone = await ExpenseMethods().getBudgetsWithinZone(month);
      return budgetsWithinZone;
    } catch (e) {
      print('Error retrieving budgets within zone: $e');
      return 0;
    }
  }

  // Bar Chart: Builds the Bar Chart Graph that contains 5 months of user spending
  Widget _buildBarChart() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBarChartData(),
              const SizedBox(height: 10), // Adjust spacing between chart and legends
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegend(color: Colors.redAccent.withOpacity(0.4), label: 'Total Spent'),
                  const SizedBox(width: 20), // Adjust spacing between legends
                  _buildLegend(color: Colors.blueAccent.withOpacity(0.4), label: 'Budget'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bar Chart (Helper): Builds the legends for the two bars
  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(label),
        const SizedBox(width: 20), // Adjust spacing as needed
      ],
    );
  }

  // Bar Chart (Helper): Bar Chart
  Widget _buildBarChartData() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _createData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          List<Map<String, dynamic>> data = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(16),
            height: 200,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color.fromARGB(255, 139, 96, 98).withOpacity(0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String categoryName = rodIndex == 0 ? 'Expenditure' : 'Budget';
                      return BarTooltipItem(
                        '$categoryName: \$${rod.y.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                barGroups: List.generate(data.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        y: data[index]['spending'] as double? ?? 0,
                        colors: [Colors.redAccent.withOpacity(0.4)],
                        width: 16,
                      ),
                      BarChartRodData(
                        y: data[index]['budget'] as double? ?? 0,
                        colors: [Colors.blueAccent.withOpacity(0.4)],
                        width: 16,
                      ),
                    ],
                  );
                }),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(showTitles: false),
                  bottomTitles: SideTitles(
                    showTitles: true,
                    getTitles: (value) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        return data[value.toInt()]['monthLabel'] ?? '';
                      }
                      return '';
                    },
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // Bar Chart (Helper): Bar Chart Data
  Future<List<Map<String, dynamic>>> _createData() async {
    DateTime now = DateTime.now();
    List<Map<String, dynamic>> data = [];

    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      double spending = await ExpenseMethods().getMonthlySpending(month);
      double budget = await BudgetMethods().getMonthlyBudgetAsync(month); 

      data.add({
        'month': month,
        'monthLabel': DateFormat('MMM yyyy').format(month), 
        'spending': spending,
        'budget': budget,
      });
    }

    return data.reversed.toList();
  }
}