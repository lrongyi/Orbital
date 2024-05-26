import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void incrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void decrementMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey,
          ),
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
                    onPressed: decrementMonth,
                  ),
                  // the date itself
                  Text(
                    DateFormat.yMMMM().format(_currentMonth),
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
                    onPressed: incrementMonth,
                  ),
                ],
              )),
          const SizedBox(height: 20),
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
          Expanded(
            child: StreamBuilder(
              stream: DatabaseMethods().getExpenses(),
              builder: (context, snapshot) {
                List expenses = snapshot.data?.docs ?? [];
                if (expenses.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Expenses Found',
                    ),
                  );
                }
                return ListView.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    Expense expense = expenses[index].data();
                    double amount = expense.amount;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 5,
                      ),
                      child: ListTile(
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
                          style: const TextStyle(fontSize: 18.0),
                        ),
                        onTap: () {
                          // make a view to see the expense description
                        },
                        onLongPress: () {
                          // make option to delete or edit expense
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
  }
}
