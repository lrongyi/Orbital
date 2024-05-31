import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/navigation_screen/adding_income.dart';
import 'package:ss/services/database.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/adding_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

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
  String? selectedItem;
  final List<DropdownMenuItem<String>> dropdownItems = [
    DropdownMenuItem(value: 'Food', child: Text('Food')),
    DropdownMenuItem(value: 'Transport', child: Text('Transport')),
    DropdownMenuItem(value: 'Entertainment', child: Text('Entertainment')),
  ];

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
        backgroundColor: mainColor,
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
          'Expense',
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
                      Expanded(
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
                                selectedItem = await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      title: const Text(
                                        'Select a category',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        )
                                      ),
                                      // TODO: need to change this to the dynamic list of categories in firebase
                                      children: dropdownItems.map((category) {
                                        return SimpleDialogOption(
                                          onPressed: () {
                                            // return the selected item when an option is tapped
                                            Navigator.pop(context, category.value);
                                          },
                                          child: Text(
                                            category.value ?? '',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            )
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                );
                                // i already made it such that the categoryController
                                // will change to become the selectedItem
                                // so upon saving, it works
                                if (selectedItem != null) {
                                  categoryController.text = selectedItem!;
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      // + button to add category
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 25,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0), 
                                  ),
                                  backgroundColor: Colors.white,
                                  title: const Text(
                                    'New Category',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        controller: categoryController,
                                        decoration: const InputDecoration(
                                            labelText: 'Category'),
                                      ),
                                      // TextFormField(
                                      //   controller: budgetController,
                                      //   decoration: const InputDecoration(
                                      //     labelText: 'Budget Allocated',
                                      //   ),
                                      //   keyboardType: const TextInputType
                                      //       .numberWithOptions(
                                      //     decimal: true,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        categoryController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel',
                                        style: TextStyle(
                                          color: Colors.black,
                                        )
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        String category =
                                            categoryController.text;
                                        double amount = 0;
                                        DatabaseMethods()
                                            .addBudget(category, amount);
                                        categoryController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Save',
                                        style: TextStyle(
                                          color: Colors.black,
                                        )
                                      ),
                                    ),
                                  ],
                                );
                              }
                            );
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
                  color: Colors.red[300],
                  onPressed: () {
                    double rawAmount = double.parse(amountController.text);
                    double modAmount =
                        rawAmount > 0 ? -1 * rawAmount : rawAmount;
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
