import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/main_screens/expenses_screens/editing_expense.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/navigation_screen/adding_expense.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/adding_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

class EditingIncome extends StatefulWidget {

  String expenseId;
  DateTime date;
  double amount;
  String? category;
  String? note;
  String? description;

  EditingIncome({super.key, required this.expenseId, required this.date, required this.amount, required this.category, required this.note, required this.description});

  @override
  State<EditingIncome> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<EditingIncome> {
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectDate = DateTime.now();

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yyyy').format(widget.date);
    selectDate = widget.date;
    amountController.text = widget.amount.toStringAsFixed(2);
    categoryController.text = widget.category ?? '';
    noteController.text = widget.note ?? '';
    descriptionController.text = widget.description ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Income',
          style: TextStyle(
            color: Colors.white,
          )
          ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
              DatabaseMethods().deleteExpense(widget.expenseId);
              Navigator.pop(context);
            },
          ),
        ]
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 20, right: 20,
          top: 30,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: SizedBox(
                    width: 175,
                    height: 35,
                    child: MaterialButton(
                      color: Colors.grey[100],
                      onPressed: () {},
                      minWidth: 175,
                      child: const Text('Income'),
                    ),
                  ),
                ),
                MaterialButton(
                  color: Colors.grey[100],
                  onPressed: () {
                    // Pops everything but the latest screen
                    // Might need to tidy up the animations
                    Navigator.popUntil(context, (context) => context.isFirst);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => EditingExpense(
                              expenseId: widget.expenseId,
                              date: widget.date,
                              amount: widget.amount,
                              category: widget.category,
                              note: widget.note,
                              description: widget.description,
                              )));
                  },
                  minWidth: 175,
                  child: const Text('Expense'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            //Box containing the titles and the text form fields
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Date',
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: selectDate,
                                firstDate: DateTime(2002),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)));

                            if (newDate != null) {
                              setState(() {
                                dateController.text =
                                    DateFormat('dd/MM/yyyy').format(newDate);
                                selectDate = newDate;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Enter date',
                          ),
                        ),
                      ),
                    ],
                  ),
                  AddingDeco().buildRow('Amount', amountController),
                  AddingDeco().buildRow('Category', categoryController),
                  AddingDeco().buildRow('Note', noteController),
                  const SizedBox(height: 40),
                  AddingDeco().buildRow('Description', descriptionController),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Save button
                MaterialButton(
                  color: Colors.blue[200],
                  onPressed: () {
                    double rawAmount = double.parse(amountController.text);
                    double modAmount =
                        rawAmount < 0 ? -1 * rawAmount : rawAmount;
                    Expense expense = Expense(
                        date: Timestamp.fromDate(selectDate),
                        amount: modAmount,
                        category: categoryController.text,
                        note: noteController.text,
                        description: descriptionController.text);
                    DatabaseMethods().updateExpense(widget.expenseId, expense);
                    Navigator.pop(context);
                  },
                  minWidth: 250,
                  child: const Text('Save'),
                ),
                // Cancel button
                MaterialButton(
                  color: Colors.grey[100],
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  minWidth: 100,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
