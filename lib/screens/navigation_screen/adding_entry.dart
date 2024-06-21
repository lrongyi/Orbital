import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/adding_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

class AddingEntry extends StatefulWidget {
  final bool isExpense;
  const AddingEntry({super.key, required this.isExpense});

  @override
  State<AddingEntry> createState() => _AddingEntryState();
}

class _AddingEntryState extends State<AddingEntry> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController addCategoryController = TextEditingController();
  TextEditingController budgetAmountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectDate = DateTime.now();
  String? selectedItem;
  String category = '';
  double amount = 0.0;
  String color = '';
  bool isRecurring = false;
  bool isIncome = false;
  Color _selectedColor = Colors.blue;

  final List<Color> predefinedColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Colors.yellowAccent,
    Colors.limeAccent,
    Colors.lime,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
    Colors.pinkAccent,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.black,
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

        //App Bar
        appBar: AppBar(
          backgroundColor: widget.isExpense ? mainColor : incomeColor,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Navigation(state: 1,)), (route) => false);
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(
            widget.isExpense ? 'Expense' : 'Income',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 30,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSwitchButton(context, 'Income', false),
                    _buildSwitchButton(context, 'Expense', true)
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateField(),
                      AddingDeco().buildRow('Amount', amountController),
                      _buildCategoryField(widget.isExpense),
                      AddingDeco().buildRow('Note', noteController),
                      const SizedBox(height: 40),
                      AddingDeco()
                          .buildRow('Description', descriptionController),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSaveButton(),
                    _buildCancelButton(context),
                  ],
                )
              ],
            )));
  }

  Widget _buildSwitchButton(
      BuildContext context, String label, bool isExpense) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isExpense == isExpense
                ? isExpense
                    ? mainColor
                    : incomeColor
                : Colors.white,
            width: 1.30,
          ),
        ),
        child: SizedBox(
          width: 175,
          height: 35,
          child: MaterialButton(
            color: Colors.grey[100],
            onPressed: () {
              if (widget.isExpense != isExpense) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            AddingEntry(isExpense: isExpense)));
              }
            },
            minWidth: 175,
            child: Text(
              label,
            ),
          ),
        ));
  }

  Widget _buildDateField() {
    return Row(children: [
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
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );

          if (newDate != null) {
            setState(() {
              dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
              selectDate = newDate;
            });
          }
        },
      ))
    ]);
  }

  Widget _buildCategoryField(bool isExpense) {
    return Row(
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
          child: StreamBuilder(
              stream: isExpense ? BudgetMethods().getCategoriesByMonth(selectDate) : BudgetMethods().getIncomeListByMonth(selectDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<String> categories = snapshot.data!;

                return DropdownButtonFormField(
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Select Category',
                  ),
                  value: categoryController.text.isEmpty
                      ? null
                      : categoryController.text,
                  onChanged: (newValue) {
                    setState(() {
                      categoryController.text = newValue!;
                    });
                  },
                  items: categories
                      .map<DropdownMenuItem<String>>((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
        ),
        // Add a category button
        IconButton(
          icon: const Icon(Icons.add, size: 25),
          onPressed: () {
            _showAddCategoryDialog();
          },
        )
      ],
    );
  }

  void _showAddCategoryDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: const BeveledRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          title: const Text(
            'New Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Category';
                    }
                    return null;
                  },
                  controller: addCategoryController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Amount';
                    }
                    return null;
                  },
                  controller: budgetAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget Allocation'),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                // Color picker
                Row(
                  children: [
                    const Text(
                      'Color:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        _showColorPickerDialog((color) {
                          setState(() {
                            _selectedColor = color;
                          });
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Recurring'),
                        Checkbox(
                          activeColor: mainColor,
                          value: isRecurring,
                          onChanged: (bool? value) {
                            setState(() {
                              isRecurring = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Income'),
                        Checkbox(
                          activeColor: mainColor,
                          value: isIncome,
                          onChanged: (bool? value) {
                            setState(() {
                              isIncome = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              // Cancel
              onPressed: () {
                addCategoryController.clear();
                budgetAmountController.clear();
                setState(() {
                  _selectedColor = Colors.blue;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              // Save
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    category = addCategoryController.text;
                    amount = double.parse(budgetAmountController.text).abs();
                    color = _selectedColor.value.toString();
                  });
                  BudgetMethods().addBudget(category, amount, isRecurring, color, isIncome); // last argument change to isIncome
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.isExpense ? const AddingEntry(isExpense: true) : const AddingEntry(isExpense: false),
                    ),
                  );
                  // Navigator.of(context).pop();
                }

                setState(() {
                  addCategoryController.clear();
                  budgetAmountController.clear();
                  _selectedColor = Colors.blue;
                });
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        );
      });
    },
  );
}

  Widget _buildSaveButton() {
    return MaterialButton(
      color: widget.isExpense ? mainColor : incomeColor,
      onPressed: () {
        double modAmount = double.parse(amountController.text).abs();
        Expense expense = Expense(
          date: Timestamp.fromDate(selectDate),
          amount: widget.isExpense ? -1 * modAmount : modAmount,
          category: categoryController.text,
          note: noteController.text,
          description: descriptionController.text,
        );
        ExpenseMethods().addExpense(expense);
        // Navigator.popUntil(context, (context) => context.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Navigation(state: 0)));
      },
      minWidth: 250,
      child: const Text(
        'Save',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return MaterialButton(
      color: Colors.grey[100],
      onPressed: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => Navigation(
                      state: 1,
                    )),
            (route) => false);
      },
      minWidth: 100,
      child: const Text('Cancel'),
    );
  }

  void _showColorPickerDialog(Function(Color) onColorSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Select Color',
            style: TextStyle(
              color: mainColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                onColorSelected(color);
              },
              availableColors: predefinedColors,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
