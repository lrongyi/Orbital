import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/adding_expense.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/expense.dart';

class Expenses extends StatefulWidget {
  const Expenses({super.key});

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                    // Insert total spending of user from firebase netSpend
                    // Add button to add / insert expenses
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                            ),
                        ),
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            )
                            ,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    // may need to edit height
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width,
                    child: StreamBuilder(
                      stream: DatabaseMethods().getExpenses(),
                      builder: (context, snapshot) {
                        List expenses = snapshot.data?.docs ?? [];
                        if (expenses.isEmpty) {
                          return const Center(
                            child: Text('No Expenses Found'),
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
            ),
          ),
        ],
      ),
    );
  }
}
