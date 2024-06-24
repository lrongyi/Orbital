import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/goal_methods.dart';
import 'package:ss/services/models/goal.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Insights extends StatefulWidget {
  const Insights({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  final _formKey = GlobalKey<FormState>();
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

  // Helper 1.1: Bar Chart Data
  Future<List<BarChartGroupData>> _createData() async {
    DateTime now = DateTime.now();
    List<BarChartGroupData> data = [];
    
    for (int i = 0; i < 5; i++) {
      DateTime month = DateTime(now.year, now.month - i, 1);
      double spending = await ExpenseMethods().getMonthlySpending(month);

      // Set a minimum height for the bar if spending is 0. 
      // EDIT: onPressed shows the value to be $0.10
      // double barHeight = spending == 0 ? 0.1 : spending;
    
      data.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: spending, 
              colors: [Colors.redAccent.withOpacity(0.4)],
              width: 16,
              
              ),
          ],
        ),
      );
    }

    return data.reversed.toList();
  }

  // Helper 2.1: Calculating Average Spending of Months
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

  // Helper 2.2: Calculate number of months with actual spending
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

  // Helper 3.1: Calculate overall net change over the last 5 months
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
                        'Comparison Chart',
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildBarChart() // See Helper 1
                  ),
                  const SizedBox(height: 20),
                  
                  // Insights
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

                  // Insight 1: Average Spending per Month
                  _buildAverageSpendingTile(),  // See Helper 2

                  const SizedBox(height: 20),

                  // Insight 2: Overall net change over the last 5 months
                  _buildNetChangeTile(), // See Helper 3
            
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Helper 1: Builds the Bar Chart Graph that contains 5 months of user spending 
  FutureBuilder<List<BarChartGroupData>> _buildBarChart() {
    return FutureBuilder<List<BarChartGroupData>>(
      future: _createData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          return Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: const Color.fromARGB(255, 139, 96, 98).withOpacity(0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '\$${rod.y.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  barGroups: snapshot.data!,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: false),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        // Subtract months directly from the current date
                        List<String> months = [
                          DateFormat('MMM yyyy').format(DateTime.now().subtract(Duration(days: 30 * (0 - value.toInt())))),
                          DateFormat('MMM yyyy').format(DateTime.now().subtract(Duration(days: 30 * (2 - value.toInt())))),
                          DateFormat('MMM yyyy').format(DateTime.now().subtract(Duration(days: 30 * (4 - value.toInt())))),
                          DateFormat('MMM yyyy').format(DateTime.now().subtract(Duration(days: 30 * (6 - value.toInt())))),
                          DateFormat('MMM yyyy').format(DateTime.now().subtract(Duration(days: 30 * (8 - value.toInt())))),
                        ];
                        return months[value.toInt()];
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  // Helper 2: Builds the ListTile that shows average spending per month
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

  // Helper 3: Builds the ListTile that shows the overall net change over 5 months.
  Widget _buildNetChangeTile() {
    return FutureBuilder<List<double>>(
      future: _getNetChangesForMonths(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.greenAccent,
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white,
                ),
              ),
              title: Text(
                "Overall net change over the last ${netChanges.length} months: ${sign}\$${overallNetChange.abs().toStringAsFixed(2)}",
                style: TextStyle(
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
