import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/category_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/services/models/category.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/adding_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';
import 'package:uuid/uuid.dart';

class EditingEntry extends StatefulWidget {
  
  final bool isExpense;
  String expenseId;
  DateTime date;
  double amount;
  String? category;
  String? note;
  String? description;

  EditingEntry({super.key, required this.isExpense, required this.expenseId, required this.date, required this.amount, required this.category, required this.note, required this.description});

  @override
  State<EditingEntry> createState() => _EditingEntryState();
}

class _EditingEntryState extends State<EditingEntry> {
  
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
  bool isRecurring = false;
  String color = '';
  bool? isIncome;
  Color _selectedColor = Colors.blue;
  DateTime _currentMonth = DateTime.now();

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
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    dateController.text = DateFormat('dd/MM/yyyy').format(widget.date);
    selectDate = widget.date;
    amountController.text = widget.amount.abs().toStringAsFixed(2);
    categoryController.text = widget.category ?? '';
    noteController.text = widget.note ?? '';
    descriptionController.text = widget.description ?? '';
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
            // Sends back to Expenses page
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Navigation(state: 1,)), (route) => false);
          },
        ),

        centerTitle: true,
        title: Text(
          widget.isExpense ? 'Edit Expense' : 'Edit Income',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
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
                    backgroundColor: Colors.white,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.isExpense ? 'Delete Expense' : 'Delete Income'
                        ),
                        const SizedBox(width: 50,),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    content: const Text(
                      'Are you sure you want to delete this entry?'
                    ),
                    actions: [
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ExpenseMethods().deleteExpense(widget.expenseId);
                            Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Navigation(state: 1,)),
                            (route) => false);
                          },
                          style: ButtonStyle(
                            side: MaterialStateProperty.resolveWith((states) => const BorderSide(
                              color: Colors.red,
                              width: 1.5, 
                            )),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ]
                  );
                }
              );
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
                  _buildDateField(widget.isExpense),
                  const SizedBox(height: 10,),
                  AddingDeco().buildRow('Amount', amountController, 
                        Icon(
                          Icons.monetization_on_outlined,
                          color: widget.isExpense ? mainColor : incomeColor,
                        ),
                        widget.isExpense ? mainColor : incomeColor
                      ),
                  const SizedBox(height: 10,),
                  _buildCategoryField(widget.isExpense),
                  const SizedBox(height: 10,),
                  AddingDeco().buildRow('Note', noteController,
                        Icon(
                          Icons.note_add_outlined,
                          color: widget.isExpense ? mainColor : incomeColor,
                        ),
                        widget.isExpense ? mainColor : incomeColor
                      ),
                  const SizedBox(height: 40),
                  AddingDeco().buildRow('Description', descriptionController, 
                        Icon(
                          Icons.notes_rounded,
                          color: widget.isExpense ? mainColor : incomeColor,
                        ),
                        widget.isExpense ? mainColor : incomeColor
                      ),
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
        )
      )
    );
  }

  Widget _buildSwitchButton(
      BuildContext context, String label, bool isExpense) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.isExpense == isExpense
                ? isExpense
                    ? mainColor
                    : incomeColor
                : Colors.white,
            width: 1.30,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            width: 175,
            height: 35,
            child: MaterialButton(
              color: Colors.grey[100],
              onPressed: () {
                if (widget.isExpense != isExpense) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => EditingEntry(
                              isExpense: isExpense, 
                              expenseId: widget.expenseId,
                              date: widget.date,
                              amount: widget.amount,
                              category: widget.category,
                              note: widget.note,
                              description: widget.description,)));
                }
              },
              minWidth: 175,
              child: Text(
                label,
              ),
            ),
          ),
        ));
  }

  Widget _buildDateField(bool isExpense) {
    return Row(children: [
      Expanded(
        child: TextFormField(
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: isExpense ? mainColor : incomeColor)
              ),
              prefixIcon: Icon(
              Icons.date_range_rounded,
              color: isExpense ? mainColor : incomeColor,
            ),
          ),
          controller: dateController,
          readOnly: true,
          onTap: () async {
            DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: selectDate,
              firstDate: DateTime(2002),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (BuildContext context, Widget? child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: isExpense ? mainColor : incomeColor, 
                      onPrimary: Colors.white, 
                      onSurface: Colors.black, 
                    ),
                    dialogBackgroundColor: Colors.white, 
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: isExpense ? mainColor : incomeColor, 
                      ),
                    ),
                  ),
                  child: child!,
                );
              }
            );
      
            if (newDate != null) {
              setState(() {
                dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
                selectDate = newDate;
                _currentMonth = DateTime(newDate.year, newDate.month);  // Update _currentMonth
              });
            }
          },
        )
      )
    ]);
  }

  Widget _buildCategoryField(bool isExpense) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder(
              stream: isExpense ? BudgetMethods().getExpenseListByMonth(selectDate) : BudgetMethods().getIncomeListByMonth(selectDate),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<String> categories = snapshot.data!;

                return DropdownButtonFormField(
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: isExpense ? mainColor : incomeColor)
                    ),
                    hintText: 'Category',
                    prefixIcon: Icon(
                      Icons.category_rounded,
                      color: isExpense ? mainColor : incomeColor,
                    )
                  ),
                  value: categoryController.text.isEmpty || !categories.contains(categoryController.text)
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
        IconButton(
          icon: Icon(Icons.add, size: 25, color: isExpense ? mainColor : incomeColor,),
          onPressed: () {
            _showAddCategoryDialog(isExpense);
          },
        )
      ],
    );
  }

   Widget _buildSaveButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
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
          ExpenseMethods().updateExpense(widget.expenseId, expense);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Navigation(state: 1,)), (route) => false);
        },
        minWidth: 250,
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: MaterialButton(
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
      ),
    );
  }

  void _showAddCategoryDialog(bool isExpense) {
    showDialog(
    context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), 
              side: const BorderSide(
                color: Colors.black,
                width: 2.0,
              )
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: isExpense ? mainColor : incomeColor,
                ),
                const SizedBox(width: 20,),
                Text(
                  isExpense ? 'New Expense Category' : 'New Income Category',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 25,),
                IconButton(
                  onPressed: () {
                    addCategoryController.clear();
                    budgetAmountController.clear();
                    setState(() {
                      _selectedColor = Colors.blue;
                    });
                    Navigator.of(context).pop();
                  }, 
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  )
                )
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // name
                  TextFormField(
                    cursorColor: isExpense ? mainColor : incomeColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Category';
                      }
                      return null;
                    },
                    controller: addCategoryController,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      prefixIcon: const Icon(
                        Icons.abc_rounded,
                        color: Colors.black,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: isExpense ? mainColor : incomeColor)
                      ),
                    ),
                  ),
                  // Budget allocation only for expenses
                  if (isExpense) ...[
                    TextFormField(
                      cursorColor: mainColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Amount';
                        }
                        return null;
                      },
                      controller: budgetAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Budget Allocation',
                        prefixIcon: const Icon(
                          Icons.money_rounded,
                          color: Colors.black,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: mainColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15.0),
                  ],
                  // Color picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      Row(
                        children: [
                          const Text('Recurring'),
                          Checkbox(
                            activeColor: isExpense ? mainColor : incomeColor,
                            value: isRecurring,
                            onChanged: (bool? value) {
                              setState(() {
                                isRecurring = value ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                ],
              ),
            ),
            actions: [
              Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: isExpense ? mainColor : incomeColor
                  ),
                    // Save
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        if (!isExpense) {
                          category = addCategoryController.text;
                          amount = 0;
                          color = _selectedColor.value.toString();
                          isIncome = true;

                        } else {
                          category = addCategoryController.text;
                          amount = double.parse(budgetAmountController.text).abs();
                          color = _selectedColor.value.toString();
                          isIncome = false;
                        }  
                      });
                      BudgetMethods().addBudget(
                          category, amount, isRecurring, color, isIncome!, _currentMonth); 
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => widget.isExpense
                              ? EditingEntry(
                                isExpense: true,
                                expenseId: widget.expenseId,
                                date: widget.date,
                                amount: widget.amount,
                                category: widget.category,
                                description: widget.description,
                                note: widget.note,
                              )
                              : EditingEntry(
                                isExpense: false,
                                expenseId: widget.expenseId,
                                date: widget.date,
                                amount: widget.amount,
                                category: widget.category,
                                description: widget.description,
                                note: widget.note,
                              )
                        )
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
                    style: TextStyle(color: Colors.white),
                  )),
              )
            ],
        );
      });
    });
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