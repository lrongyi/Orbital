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
              colors: [Colors.blue],
              width: 16,
              
              ),
          ],
        ),
      );
    }

    return data.reversed.toList();
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildBarChart()
                  ),
                  const SizedBox(height: 20),
                  
                  // Your Goals & + button
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
                      // + button
                      IconButton(
                        icon: Icon(Icons.add, color: mainColor),
                        onPressed: () {

                        },
                        // onPressed: () async {
                        //   await showDialog(
                        //     context: context,
                        //     builder: (BuildContext context) {
                        //       return AlertDialog(
                        //         shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(0),
                        //         ),
                        //         backgroundColor: Colors.white,
                        //         title: const Text(
                        //           'Add New Goal',
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.bold,
                        //             fontSize: 18,
                        //           ),
                        //         ),
                        //         content: Form(
                        //           key: _formKey,
                        //           child: Column(
                        //             mainAxisSize: MainAxisSize.min,
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.start,
                        //             children: [
                        //               // Name Field
                        //               TextFormField(
                        //                 validator: (value) {
                        //                   if (value == null || value.isEmpty) {
                        //                     return 'Enter Name';
                        //                   }
                        //                   return null;
                        //                 },
                        //                 decoration: const InputDecoration(
                        //                     labelText: 'Name'),
                        //                 controller: nameController,
                        //               ),
                        //               const SizedBox(height: 20),
                        //               // Target Amount Field
                        //               TextFormField(
                        //                 validator: (value) {
                        //                   if (value == null || value.isEmpty) {
                        //                     return 'Enter Target Amount';
                        //                   }
                        //                   return null;
                        //                 },
                        //                 decoration: const InputDecoration(
                        //                     labelText: 'Target Amount'),
                        //                 keyboardType: TextInputType.number,
                        //                 controller: targetAmountController,
                        //               ),
                        //               const SizedBox(height: 20),
                        //               // Target Date Field
                        //               TextFormField(
                        //                 decoration: const InputDecoration(
                        //                     labelText: 'Target Date'),
                        //                 controller: targetDateController,
                        //                 readOnly: true,
                        //                 onTap: () async {
                        //                   // Show date picker to select target date
                        //                   DateTime? newDate =
                        //                       await showDatePicker(
                        //                     context: context,
                        //                     initialDate: selectDate,
                        //                     firstDate: DateTime(2002),
                        //                     lastDate: DateTime.now()
                        //                         .add(const Duration(days: 365)),
                        //                   );

                        //                   if (newDate != null) {
                        //                     setState(() {
                        //                       targetDateController.text =
                        //                           DateFormat('dd/MM/yyyy')
                        //                               .format(newDate);
                        //                       selectDate = newDate;
                        //                     });
                        //                   }
                        //                 },
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         actions: [
                        //           TextButton(
                        //             onPressed: () {
                        //               clearControllers();
                        //               Navigator.of(context).pop();
                        //             },
                        //             child: const Text('Cancel'),
                        //           ),
                        //           TextButton(
                        //             onPressed: () {
                        //               if (_formKey.currentState!.validate()) {
                        //                 setState(() {
                        //                   goalName = nameController.text;
                        //                   goalTargetAmount = double.parse(
                        //                           targetAmountController.text)
                        //                       .abs();
                        //                 });

                        //                 Goal newGoal = Goal(
                        //                   name: goalName,
                        //                   targetAmount: goalTargetAmount,
                        //                   targetDate:
                        //                       Timestamp.fromDate(selectDate),
                        //                 );
                        //                 GoalMethods().addGoal(newGoal);
                        //                 clearControllers();
                        //                 Navigator.pop(context);
                        //               }
                        //             },
                        //             child: const Text('Add'),
                        //           ),
                        //         ],
                        //       );
                        //     },
                        //   );
                        // },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // List view of goals
                  // Expanded(
                  //   child: StreamBuilder(
                  //     stream: GoalMethods().getGoals(), 
                  //     builder: (context, snapshot) {
                  //       if (snapshot.hasError) {
                  //         return Text('Error: ${snapshot.error}');
                  //       } 
                        
                  //       if (!snapshot.hasData) {
                  //         return const Center(
                  //           child: CircularProgressIndicator(),
                  //         );                     
                  //       } 
                        
                  //       final goals = snapshot.data!.docs;

                  //       if (goals.isEmpty) {
                  //         return const Center(
                  //           child: Text('No Goals Found'),
                  //         );
                  //       }
                  //       return ListView.separated(
                  //         separatorBuilder: (context, index) => const Divider(),
                  //         itemCount: goals.length,
                  //         itemBuilder: (context, index) {
                  //           Goal goal = goals[index].data();
                  //           String goalId = goals[index].id;

                  //           return ListTile(
                  //             title: Text(
                  //               goal.name,
                  //               style: const TextStyle(
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //             ),
                  //             subtitle: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text('Target Amount: \$${goal.targetAmount.toStringAsFixed(2)}'),
                  //                 Text('Target Date: ${DateFormat('dd/MM/yyyy').format(goal.targetDate.toDate())}'),
                  //               ],
                  //             ),
                  //             // goal info button
                  //             trailing: IconButton(
                  //               icon: Icon(
                  //                 Icons.info_outline,
                  //                 color: mainColor),
                  //               onPressed: () async {
                  //                 showDialog(
                  //                 context: context,
                  //                 builder: (context) {
                  //                   String newName = goal.name;
                  //                   double newAmount = goal.targetAmount;
                  //                   return StatefulBuilder(
                  //                     builder: (context, setState) {
                  //                       return AlertDialog(
                  //                         shape: RoundedRectangleBorder(
                  //                           borderRadius: BorderRadius.circular(0), 
                  //                         ),
                  //                         backgroundColor:Colors.white,
                  //                         title: const Text('Edit Goal',
                  //                             style: TextStyle(
                  //                               fontWeight: FontWeight.bold,
                  //                               fontSize: 18,
                  //                             )),
                  //                         content: Column(
                  //                           mainAxisSize: MainAxisSize.min,
                  //                           children: [
                  //                             // current goal name
                  //                             TextFormField(                                               
                  //                               initialValue: goal.name,
                  //                               keyboardType:
                  //                                 const TextInputType.numberWithOptions(
                  //                                   decimal: true),
                                              
                  //                               onChanged: (String value) {
                  //                                 newName = value;
                  //                               },
                  //                             ),
                  //                             // current goal target amount
                  //                             TextFormField(
                  //                               initialValue: goal.targetAmount.toStringAsFixed(2),
                  //                               keyboardType:
                  //                                 const TextInputType.numberWithOptions(
                  //                                   decimal: true),           
                  //                               onChanged: (value) {
                  //                                 newAmount =
                  //                                   double.tryParse(value) ?? goal.targetAmount;
                  //                               },
                  //                             ),
                  //                             // current date form field
                  //                             // TextFormField(
                  //                             //   // don't need to declare a new controller in the class. temporary instance
                  //                             //   controller: editDateController,
                  //                             //   readOnly: true,
                  //                             //   onTap: () async {
                  //                             //     DateTime? newDate = await showDatePicker(
                  //                             //       context: context,
                  //                             //       initialDate: goal.targetDate.toDate(),
                  //                             //       firstDate: DateTime(2002),
                  //                             //       lastDate: DateTime.now().add(const Duration(days: 365)),
                  //                             //     );

                  //                             //     if (newDate != null) {
                  //                             //       setState(() {
                  //                             //         editDateController.text = DateFormat('dd/MM/yyyy').format(newDate); 
                  //                             //         selectDate = newDate;
                  //                             //       });
                  //                             //     }
                  //                             //   },
                  //                             // ),
                  //                           ]
                  //                         ),
                  //                         actions: [
                  //                           // save button
                  //                           TextButton(
                  //                               onPressed: () {
                  //                                 Map<String, dynamic> updatedData = {
                  //                                   'name': newName,
                  //                                   'targetAmount': newAmount,
                  //                                   'targetDate': Timestamp.now(),
                  //                                 };
                  //                                 GoalMethods().updateGoal(goalId, updatedData);
                  //                                 Navigator.of(context).pop();
                  //                               },
                  //                               child: const Text(
                  //                                 'Save',
                  //                                 style: TextStyle(
                  //                                   color: Colors.black,
                  //                                 ),
                  //                               )),
                  //                         ],
                  //                       );
                  //                     }
                  //                   );
                  //                 });
                  //               },
                  //             ),
                  //             onLongPress: () {
                  //               showDialog(
                  //                 context: context,
                  //                 builder: (context) {
                  //                   return AlertDialog(              
                  //                     shape: RoundedRectangleBorder(
                  //                       borderRadius: BorderRadius.circular(0), 
                  //                     ),
                  //                     backgroundColor: Colors.white,
                  //                     title: const Text(
                  //                       'Delete Goal'
                  //                     ),
                  //                     // content: const Text(
                  //                     //   'Are you sure you want to delete this goal?'
                  //                     // ),
                  //                     content: const Column(
                  //                       mainAxisSize: MainAxisSize.min,
                  //                       crossAxisAlignment: CrossAxisAlignment.start,
                  //                       children: [
                  //                         Text('Are you sure you want to delete this goal?'),
                  //                         Text(
                  //                           'You cannot undo this action!',
                  //                           style: TextStyle(
                  //                             fontWeight: FontWeight.bold,
                  //                           )
                  //                         ),
                  //                       ]
                  //                     ),
                  //                     actions: [
                  //                       TextButton(
                  //                         onPressed: () {
                  //                           Navigator.of(context).pop();
                  //                         },
                  //                         child: const Text(
                  //                           'Cancel',
                  //                           style: TextStyle(
                  //                             color: Colors.black,
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       TextButton(
                  //                         onPressed: () {
                  //                           GoalMethods().deleteGoal(goalId);
                  //                           Navigator.of(context).pop();
                  //                         },
                  //                         child: const Text(
                  //                           'Delete',
                  //                           style: TextStyle(
                  //                             color: Colors.red,
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ]
                  //                   );
                  //                 }
                  //               );
                  //             },
                  //           );
                  //         },
                  //       );                       
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  FutureBuilder<List<BarChartGroupData>> _buildBarChart() {
    return FutureBuilder<List<BarChartGroupData>>(
      future: _createData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '\$${rod.y.toStringAsFixed(2)}',
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
