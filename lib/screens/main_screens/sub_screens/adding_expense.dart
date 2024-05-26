import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/main_screens/navigation.dart';
import 'package:ss/screens/main_screens/sub_screens/adding_income.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/adding_deco.dart';

class AddingExpense extends StatefulWidget {
  const AddingExpense({super.key});

  @override
  State<AddingExpense> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AddingExpense> {

  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectDate = DateTime.now();

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Navigation()),
                (route) => false);
          },
        ),
        centerTitle: true,
        title: const Text('Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MaterialButton(
                  color: Colors.grey[100],
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => AddingIncome()));
                  },
                  minWidth: 175,
                  child: const Text('Income'),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: SizedBox(
                    width: 175,
                    height: 35,
                    child: MaterialButton(
                      color: Colors.grey[100],
                      onPressed: () {},
                      minWidth: 175,
                      child: const Text('Expense'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            //SizedBox containing the titles and the text form fields
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
                                dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
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
                  color: Colors.red[300],
                  onPressed: () {
                    double rawAmount = double.parse(amountController.text);
                    double modAmount = rawAmount > 0 ? -1 *rawAmount : rawAmount;
                    Expense expense = Expense(
                      date: Timestamp.fromDate(selectDate), 
                      amount: modAmount, 
                      category: categoryController.text,
                      note: noteController.text,
                      description: descriptionController.text
                      );
                    DatabaseMethods().addExpense(expense);  
                    Navigator.popUntil(context, (context) => context.isFirst);
                  },
                  minWidth: 250,
                  child: const Text('Save'),
                ),
                // Cancel button
                MaterialButton(
                  color: Colors.grey[100],
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Navigation()),
                        (route) => false);
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
