import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/shared/main_screens_deco.dart';

class EditCategories extends StatefulWidget {
  final Set<String> selectedExpenseCategories;
  final Set<String> selectedIncomeCategories;

  const EditCategories({
    super.key,
    required this.selectedExpenseCategories,
    required this.selectedIncomeCategories,
  });

  @override
  State<EditCategories> createState() => _EditCategoriesState();
}

class _EditCategoriesState extends State<EditCategories> {
  DateTime _currentMonth = DateTime.now();
  TextEditingController categoryNameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _budgetControllers = {};
  final Map<String, Color> _categoryColors = {};
  Color _selectedColor = Colors.blue;

  // List of predefined colors for the Block Picker
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

  Map<String, bool> _isIncomeMap = {};

  @override
  void initState() {
    super.initState();
    _initializeCategoryColors();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    for (var category in _categoryColors.keys) {
      _budgetControllers[category] = TextEditingController(text: '0');
      _isIncomeMap[category] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Edit Your Categories',
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Expense Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Budget',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          )
                        ),
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          color: Colors.grey,
                          iconSize: 20,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.info_outline, size: 50),
                                      SizedBox(height: 20),
                                      Text(
                                        'This is to set your budget allocation for your expense categories. Default value is \$0.',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )
                                      ),
                                    ],
                                  )
                                );
                              }
                            );
                          },
                        )
                      ],
                    )
                  ],
                )                  
              ),
              _buildCategoryList(widget.selectedExpenseCategories, false),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    Text(
                      'Income Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )                  
              ),
              _buildCategoryList(widget.selectedIncomeCategories, true),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: mainColor,
            width: 1,
          ),
          // borderRadius: const BorderRadius.only(
          //   topLeft: Radius.circular(20),
          //   topRight: Radius.circular(20),
          // )
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
                  (route) => false,
                );
              },
            ),
            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: mainColor,
                  elevation: 10.0,
                ),
                child: const Text('Submit'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final Map<String, List<dynamic>> budgetAllocations = {};
                    _budgetControllers.forEach(
                      (category, controller) {
                        budgetAllocations[category] = [
                          double.parse(controller.text.trim()),
                          true, // isRecurring
                          _categoryColors[category]!.value.toString(),
                          _isIncomeMap[category] ?? false,
                        ];
                      },
                    );
        
                    for (var entry in budgetAllocations.entries) {
                      await BudgetMethods().addBudget(entry.key, entry.value[0], entry.value[1], entry.value[2], entry.value[3], _currentMonth);
                    }
        
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fill in all fields'),
                        backgroundColor: Colors.red,
                        showCloseIcon: true,
                      ),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Set<String> categories, bool isIncomeCategories) {
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final currentCategory = categories.elementAt(index);
        final color = _categoryColors[currentCategory] ?? Colors.grey;
        if (isIncomeCategories) {
          return _buildCategoryTile(currentCategory, color, true);
        } else {
          return _buildCategoryTile(currentCategory, color, false);
        }
        
      },
    );
  }

  Widget _buildCategoryTile(String category, Color color, bool isIncomeCategory) {
    if (isIncomeCategory) {
      _isIncomeMap[category] = true;
    }
    
    return ListTile(
      title: Text(category, style: TextStyle(fontSize: 16)),
      leading: GestureDetector(
        onTap: () {
          _showColorPickerDialog((color) {
            setState(() {
              _selectedColor = color;
              _categoryColors[category] = _selectedColor;
            });
          });
        },
        child: CircleAvatar(
          backgroundColor: color,
        ),
      ),
      trailing: isIncomeCategory ? null : _amountWidget(category),
    );
  }

  void _initializeCategoryColors() {
    int index = 0;
    for (var category in widget.selectedExpenseCategories) {
      _categoryColors[category] = predefinedColors[index % predefinedColors.length];
      index++;
    }
    for (var category in widget.selectedIncomeCategories) {
      _categoryColors[category] = predefinedColors[index % predefinedColors.length];
      index++;
    }
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

  Widget _amountWidget(String category) {
    return SizedBox(
      width: 75,
      child: TextFormField(
        textAlign: TextAlign.left,
        cursorColor: mainColor,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Add amount';
          }
          return null;
        },
        controller: _budgetControllers[category],
        decoration: InputDecoration(
          labelText: 'Amount',
          labelStyle: TextStyle(color: mainColor, fontSize: 12),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: mainColor),
          ),
        ),
        keyboardType: TextInputType.number,
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
