// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/screens/main_screens/bill_screens/billing.dart';
import 'package:ss/screens/main_screens/expenses_screens/editing_entry.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/bill_methods.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/services/user_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key? key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  DateTime _currentMonth = DateTime.now();

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
          return Scaffold(
            resizeToAvoidBottomInset: false,           
            backgroundColor: Colors.white,
            body: Column(
              children: [
                const Divider(height: 1, thickness: 1, color: Colors.grey),

                // Select month
                _monthPicker(monthNotifier),

                const SizedBox(height: 20),

                // Expenses card
                _expensesCard(monthNotifier._currentMonth),

                const SizedBox(height: 10),

                _unpaidBillsTile(),

                const SizedBox(height: 10),

                // Header for Transaction History and Amount
                _header('Transaction History', 'Amount'),

                const SizedBox(height: 20),

                // List of expenses
                _userExpenses(monthNotifier._currentMonth),
              ],
            ),
          );
        },
      ),
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

  Widget _expensesCard(DateTime time) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            // Color.fromARGB(255, 128, 43, 37)
            colors: [mainColor, Color.fromARGB(255, 146, 45, 53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Net Flow',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    // Change salary dialog. See helper 2
                    _showChangeSalaryDialog(context); 
                  },
                ),


              ],
            ),
            FutureBuilder<double>(
              future: ExpenseMethods().getMonthlyNetChange(time),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Display a loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  );
                } else if (snapshot.hasData) {              
                  return 
                  snapshot.data! < 0 ? 
                  Text(
                    '-\$${snapshot.data!.abs().toStringAsFixed(2)}', // Display the amount returned by the method
                    style: TextStyle(
                      color: snapshot.data! < 0 ? Colors.red : Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : Text(
                    '\$${snapshot.data!.toStringAsFixed(2)}', // Display the amount returned by the method
                    style: TextStyle(
                      color: snapshot.data! < 0 ? Colors.red : Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  return Text(
                    '\$0.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Income',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    FutureBuilder<double>(
                      future: ExpenseMethods().getMonthlyIncome(time),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Display a loading indicator while waiting
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return Text(
                            '\$${snapshot.data!.toStringAsFixed(2)}', // Display the amount returned by the method
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return Text(
                            '\$0.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: Colors.white70,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Expenses',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),

                    FutureBuilder<double>(
                      future: ExpenseMethods().getMonthlySpending(time),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Display a loading indicator while waiting
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return Text(
                            '\$${snapshot.data!.toStringAsFixed(2)}', // Display the amount returned by the method
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return Text(
                            '\$0.00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _unpaidBillsTile() {
    return FutureBuilder<int>(
      future: BillMethods().getNumberOfUnpaidBills(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
    
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading unpaid bills'));
        }
    
        int unpaidCount = snapshot.data ?? 0;
    
        return Container(
          margin: const EdgeInsets.only(bottom: 16, left: 40, right: 40),
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
              color: unpaidCount == 0 ? Colors.green : Colors.amber,
              width: 2,
            ),
            color: Colors.white,
          ),
          child: ListTile(
            title: Text(
              unpaidCount == 1 
              ? 'You have $unpaidCount unpaid bill'
              : 'You have $unpaidCount unpaid bills',
                style: TextStyle(color: Colors.black),
            ),
            leading: unpaidCount == 0 
            ? Icon(Icons.check, color: Colors.green)
            : Icon(Icons.lightbulb, color: Colors.amber),
            tileColor: Colors.white,
            trailing: IconButton(icon: Icon(Icons.arrow_forward), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Billing(previousContext: 1,)));
            },),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _header(String first, String second) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // transaction history text
          Text(
            first,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          // amount text
          Text(
            second,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeSalaryDialog(BuildContext context) async {
    double currentSalary = await UserMethods().getSalaryAsync();
    TextEditingController _salaryController = TextEditingController(text: currentSalary.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), 
            side: const BorderSide(
              color: Colors.black,
              width: 2.0,
            )
          ),
          title: Row(
            children: [
              Icon(
                Icons.update_rounded,
                color: incomeColor,
              ),
              const SizedBox(width: 30,),
              Text('Update Salary'),
              const SizedBox(width: 30,),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                }, 
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                )
              )
            ],
          ),
          content: TextFormField(
            cursorColor: mainColor,
            controller: _salaryController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter new salary',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: mainColor)
              ),
              prefixIcon: const Icon(
                Icons.monetization_on_outlined,
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: incomeColor,
                  foregroundColor: Colors.white
                ),
                onPressed: () async {
                  // Implement salary update logic here
                  String userInput = _salaryController.text;
                  if (userInput.isNotEmpty) {
                    double? newSalary = double.tryParse(userInput);
                    if (newSalary != null && newSalary != currentSalary) {
                      String userId = UserMethods().getCurrentUserId();
                      await UserMethods().updateUserSalary(userId, newSalary);
                    }
                  }
                  Navigator.pushAndRemoveUntil(context, 
                      MaterialPageRoute(builder: (context) => Navigation(state: 1)), (route) => false);
                },
                child: Text('Save'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _userExpenses(DateTime month) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: ExpenseMethods().getExpensesByMonth(month),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final expenses = snapshot.data!.docs;

          if (expenses.isEmpty) {
            return const Center(
              child: Text('No expenses found'),
            );
          }

          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              Expense expense = expenses[index].data() as Expense;
              String expenseId = expenses[index].id;
              // double amount = expense.amount;
              return StreamBuilder<QuerySnapshot>(
                stream: BudgetMethods().getBudgetsByMonth(month),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final budgets = snapshot.data!.docs;

                  Budget budget = budgets[0].data() as Budget;
                  Color color = Color(int.parse(budget.categories[expense.category]![2]));

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 5,
                    ),
                    child: ListTile(
                      // Icon
                      leading: CircleAvatar(
                        backgroundColor: color,
                        child: Icon(Icons.food_bank, color: Colors.white, size: 20),
                      ),
                      // List Tile
                      title: Text(
                        expense.category ?? '',
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            DateFormat("EEE, dd-MM-yy").format(expense.date.toDate()),
                            style: const TextStyle(fontSize: 13.0),
                          ),
                          const SizedBox(width: 15.0),
                          Text(
                            expense.note ?? '',
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ],
                      ),
                      trailing: expense.amount < 0
                          ? Text(
                              '-\$${expense.amount.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: expense.amount > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            )
                          : Text(
                              '+\$${expense.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: expense.amount > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                      // See description
                      onTap: () {
                        String? description = expense.description;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), 
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                )
                              ),
                              backgroundColor: expense.amount > 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              title: Text(expense.amount > 0 
                                ? 'Income Description'
                                : 'Expense Description',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              content: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  color: Colors.white,                                 
                                  constraints: BoxConstraints(
                                    minHeight: 150,
                                    maxWidth: MediaQuery.of(context).size.width * 0.5,
                                  ),
                                  child: Text(
                                    description == '' ? 'No description provided' : description ?? '',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                Center(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: expense.amount > 0 ? incomeColor : mainColor
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      'Close',
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      // Edit or Delete expense
                      onLongPress: () {
                        if (expense.amount < 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditingEntry(
                                    isExpense: true,
                                    expenseId: expenseId, 
                                    date: expense.date.toDate(), 
                                    amount: expense.amount, 
                                    category: expense.category, 
                                    note: expense.note, 
                                    description: expense.description,
                                  ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditingEntry(
                                    isExpense: false,
                                    expenseId: expenseId, 
                                    date: expense.date.toDate(), 
                                    amount: expense.amount, 
                                    category: expense.category, 
                                    note: expense.note, 
                                    description: expense.description,
                                  ),
                            ),
                          );    
                        }                                 
                      },
                    ),
                  );
                },
              );
            },
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