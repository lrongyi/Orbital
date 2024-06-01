import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/navigation_screen/adding_expense.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/adding_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

class AddingIncome extends StatefulWidget {
  const AddingIncome({super.key});

  @override
  State<AddingIncome> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AddingIncome> {
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectDate = DateTime.now();
  final List<DropdownMenuItem<String>> dropdownItems = [
    DropdownMenuItem(value: 'Food', child: Text('Food')),
    DropdownMenuItem(value: 'Transport', child: Text('Transport')),
    DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
  ];
  String? selectedItem; // Variable to store the selected item

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // App Bar
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Navigation()),
                (route) => false);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Income',
          style: TextStyle(
            color: Colors.white,
            )
          ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(
          left: 20, right: 20,
          top: 30,
        ),

        child: Column(
          children: [

            // Select between adding income or expense
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => AddingExpense()));
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

                  // TextFormFields
                  AddingDeco().buildRow('Amount', amountController),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                        child: Text(
                          'Category',
                          textAlign: TextAlign.start,
                        ),
                      ),

                      const SizedBox(width: 10),

                      StreamBuilder(
                        stream: DatabaseMethods().getCategoriesByMonth(selectDate), 
                        
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            print('no data');
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        
                          List<String> categories = snapshot.data!;

                          return Expanded(
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              controller: categoryController,
                              readOnly: true, 
                              decoration: InputDecoration(
                                hintText: 'Select category',
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 25,
                                  ),

                                  onPressed: () async {
                                     // open a dialog to show the dropdown items
                                    selectedItem = await showDialog<String> (
                                      context: context,
                                      builder: (BuildContext context) {
                                        return SimpleDialog(
                                          backgroundColor: Colors.white,
                                          shape: const RoundedRectangleBorder (
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          title: const Text(
                                            'Select a category',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            )
                                          ),
                                          children: categories.map((category) {
                                            return SimpleDialogOption(
                                              onPressed: () {
                                                // return the selected item when an option is tapped
                                                Navigator.pop(context, category);
                                              },
                                              child: Text(
                                                category,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                )
                                              ),
                                            );
                                          }).toList()
                                        );
                                      },
                                    );
                                    if (selectedItem != null) {
                                      categoryController.text = selectedItem!;
                                    }
                                  }
                                ),
                              )
                            )
                          );
                        }
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 25,
                        ),
                        onPressed: () {

                        },
                      ),
                    ],
                  ),
                  AddingDeco().buildRow('Note', noteController),
                  const SizedBox(height: 40),
                  AddingDeco().buildRow('Description', descriptionController),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Save or cancel
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
