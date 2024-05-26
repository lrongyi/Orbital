import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/main_screens/sub_screens/adding_expense.dart';
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 100,
            // Insert total spending of user from firebase netSpend
            // Add button to add / insert expenses 

          ),
          SizedBox(
            // may need to edit height
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: StreamBuilder(
              stream: DatabaseMethods().getExpenses(),
              builder: (context, snapshot) {
                List expenses = snapshot.data?.docs ?? [];
                if (expenses.isEmpty) {
                  // Style the button
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddingExpense()));
                      }, 
                      style: const ButtonStyle(),
                      child: const Text('Add Expenses'),
                    ),
                  );
                }
                return ListView.separated(
                  separatorBuilder:(context, index) => const Divider(),
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
                          backgroundColor: amount < 0 ? Colors.red : Colors.blue,
                          child: Icon(
                            amount < 0 ? Icons.money_off_csred_outlined : Icons.monetization_on_outlined,
                            color: Colors.white,
                          )
                        ),
                        title: Text(expense.category ?? '', style: const TextStyle(fontSize: 20.0),),
                        subtitle: Row(
                          children: [
                            Text(DateFormat("EEE, dd-MM-yy").format(expense.date.toDate()), style: const TextStyle(fontSize: 13.0)),
                            const SizedBox(width: 15.0,),
                            Text(expense.note ?? '', style: const TextStyle(fontSize: 12.0)),
                          ],
                        ),
                        trailing: Text(expense.amount.toString(), style: const TextStyle(fontSize: 18.0),),
                        onTap: () {
                          // make a view to see the expense description
                        },
                        onLongPress: () {
                          // make option to delete or edit expense
                        },
                      )
                    );
                  }
                );
              },
            )
          )
        ],
      )
      
    );
  }
}