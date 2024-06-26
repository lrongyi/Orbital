import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/screens/main_screens/insights_screens/breakdown.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/goal_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/models/goal.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Insights extends StatefulWidget {
  const Insights({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  TextEditingController nameController = TextEditingController();
  TextEditingController targetAmountController = TextEditingController();
  TextEditingController targetDateController = TextEditingController();
  DateTime selectDate = DateTime.now();
  final DateTime _currentMonth = DateTime.now();
  // String goalName = '';
  // double goalTargetAmount = 0.0;

  @override
  void initState() {
    targetDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    super.initState();
  }

  void clearControllers() {
    nameController.clear();
    targetAmountController.clear();
    setState (() {
      targetDateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
      selectDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MonthNotifier(_currentMonth),
      child: Consumer<MonthNotifier>(builder: (context, monthNotifier, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: mainColor,
            title: const Text(
              'Insights',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Container(
            margin: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Monthly Spending vs Budget',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: mainColor,
                          ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                backgroundColor: Colors.white,
                                shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),                         
                                content: Text(
                                'This is a comparison chart of your monthly spending over the last 5 months'
                                ),
                             );
                            }
                          );                        
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Bar Chart
                  _buildBarChart(), // See Bar Chart 

                  const SizedBox(height: 20),
                  
                  // Insights Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Insights',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: mainColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildAverageSpendingTile(),  // See Insight 1
                          
                          const SizedBox(height: 20),
                          
                          // Insight 2: Overall net change over the last 5 months
                          _buildNetChangeTile(), // See Insight 2
                          
                          const SizedBox(height: 20),
                          
                          _buildBreakdownTile(),
                        ],
                      ),
                    ),
                  ), 
                ],
              ),
            ),
          ),
        );
      }),
    );
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

  // Bar Chart (Helper): Get the highest spending category along with its spending amount
  Future<Map<String, dynamic>> _getHighestSpendingCategoryData(DateTime month) async {
    final budgetsSnapshot = await BudgetMethods().getBudgetsByMonth(month).first;

    if (budgetsSnapshot.docs.isEmpty) {
      return {'category': 'No category', 'spending': 0.0};
    }

    String highestSpendingCategory = '';
    double highestExpenditure = 0.0;

    for (var budgetDoc in budgetsSnapshot.docs) {
      Budget budget = budgetDoc.data() as Budget;
      for (var category in budget.categories.keys) {
        double categorySpending = await ExpenseMethods().getMonthlySpendingCategorized(month, category);
        if (categorySpending > highestExpenditure) {
          highestExpenditure = categorySpending;
          highestSpendingCategory = category;
        }
      }
    }

    return {'category': highestSpendingCategory, 'spending': highestExpenditure};
  }


  // Insight 1: Builds the ListTile that shows average spending per month
  Widget _buildAverageSpendingTile() {
    return FutureBuilder<int>(
      future: _countMonthsWithSpending(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          int numberOfMonths = snapshot.data ?? 0;
          String monthText = numberOfMonths == 1 ? 'month' : 'months';
          return FutureBuilder<double>(
            future: _calculateAverageSpending(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                double averageSpending = snapshot.data ?? 0.0;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Icon(
                        Icons.attach_money,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "Over the last $numberOfMonths $monthText, you've spent on average \$${averageSpending.toStringAsFixed(2)} per month",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  // Insight 1 (Helper) : Calculating average spending of months
  Future<double> _calculateAverageSpending() async {
    DateTime now = DateTime.now();
    List<double> spendingList = [];

    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      double spending = await ExpenseMethods().getMonthlySpending(month);
      if (spending > 0) {
        spendingList.add(spending);
      }
    }

    if (spendingList.isEmpty) return 0.0;
    double totalSpending = spendingList.reduce((a, b) => a + b);
    return totalSpending / spendingList.length;
  }

  // Insight 1 (Helper): Calculate number of months with actual spending
  Future<int> _countMonthsWithSpending() async {
    DateTime now = DateTime.now();
    int count = 0;

    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      double spending = await ExpenseMethods().getMonthlySpending(month);
      if (spending > 0) {
        count++;
      }
    }

    return count;
  }

  // Insight 2: Builds the ListTile that shows the overall net change over 5 months.
  Widget _buildNetChangeTile() {
    return FutureBuilder<List<double>>(
      future: _getNetChangesForMonths(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<double> netChanges = snapshot.data ?? [];
          double overallNetChange = netChanges.fold(0, (prev, element) => prev + element);
          String sign = overallNetChange > 0 ? '+' : overallNetChange < 0 ? '-' : '';
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.greenAccent,
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "Overall net change over the last ${netChanges.length} months: ${sign}\$${overallNetChange.abs().toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  
  // Insight 2 (Helper): Calculate overall net change over the last 5 months
  Future<List<double>> _getNetChangesForMonths() async {
    DateTime now = DateTime.now();
    List<double> netChanges = [];

    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      double netChange = await ExpenseMethods().getMonthlyNetChange(month);
      netChanges.add(netChange);
    }

    return netChanges;
  }

  Widget _buildBreakdownTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue, width: 2.0), // Yellow border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Breakdown()),
        );
        },
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.lightbulb_outline,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'See complete breakdown',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
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
