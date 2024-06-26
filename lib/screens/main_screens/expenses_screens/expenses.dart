import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ss/screens/main_screens/expenses_screens/editing_expense.dart';
import 'package:ss/screens/main_screens/expenses_screens/editing_income.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

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
            backgroundColor: Colors.white,
            body: Column(
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey,
                ),

                // Select month
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

                // Header for Transaction History and Amount
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // transaction history text
                      Text(
                        'Transaction History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      // amount text
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // List of expenses 
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    
                    stream: DatabaseMethods().getExpensesByMonth(monthNotifier.currentMonth),
                    
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final expenses = snapshot.data!.docs;

                      if (expenses.isEmpty) {
                        return const Center(
                          child: Text('No Expenses Found'),
                        );
                      }

                      return ListView.separated(
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          Expense expense = expenses[index].data() as Expense;
                          String expenseId = expenses[index].id;
                          double amount = expense.amount;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 5,
                            ),
                            child: ListTile(

                              // Icon 
                              leading: CircleAvatar(
                                backgroundColor:
                                    amount < 0 ? Colors.red : Colors.blue,
                                child: Icon(
                                  amount < 0
                                      ? Icons.money_off_csred_outlined
                                      : Icons.monetization_on_outlined,
                                  color: Colors.white,
                                ),
                              ),

                              // List Tile
                              title: Text(
                                expense.category ?? '',
                                style: const TextStyle(fontSize: 20.0),
                              ),

                              subtitle: Row(
                                children: [
                                  Text(
                                    DateFormat("EEE, dd-MM-yy")
                                        .format(expense.date.toDate()),
                                    style: const TextStyle(fontSize: 13.0),
                                  ),
                                  const SizedBox(width: 15.0),
                                  Text(
                                    expense.note ?? '',
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),

                              trailing: Text(
                                expense.amount.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: expense.amount > 0
                                  ? Colors.blue
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
                                      backgroundColor: expense.amount > 0
                                      ? Colors.blue[50]
                                      : Colors.red[50],
                                      
                                      title: Text(expense.amount > 0 
                                        ? 'Income Description'
                                        : 'Expense Description',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),

                                      content: Container(
                                        color: Colors.white,                                 
                                        constraints: BoxConstraints(
                                          // size of description box, can change minHeight
                                          // according to what looks best
                                          minHeight: 200, 
                                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                                        ),
                                        child: Text(
                                          description == '' ? 'No description provided' : description ?? '',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),

                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Close',
                                          ),
                                        ),
                                      ]
                                    );
                                  }
                                );
                              },

                              // Edit or Delete expense
                              onLongPress: () {
                                // make option to delete or edit expense
                                if (expense.amount < 0) {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditingExpense(
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
                                        EditingIncome(
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
                  ),
                ),
              ],
            ),
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


