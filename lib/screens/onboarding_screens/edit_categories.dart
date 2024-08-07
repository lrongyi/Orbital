import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/shared/main_screens_deco.dart';

class EditCategories extends StatefulWidget {
  final Set<String> selectedCategories;

  const EditCategories({super.key, required this.selectedCategories});
  
  @override
  State<EditCategories> createState() => _EditCategoriesState();
}

class _EditCategoriesState extends State<EditCategories> {
  DateTime _currentMonth = DateTime.now();
  TextEditingController categoryNameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _budgetControllers = {};
  Map<String, Color> _categoryColors = {};
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
      _budgetControllers[category] = TextEditingController(text: null);
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
            const SizedBox(width: 10,),
            GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              surfaceTintColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2.0
                                )
                              ),
                              backgroundColor: Colors.white,
                              icon: Icon(
                                Icons.info_outline_rounded,
                                color: mainColor,
                                size: 50,
                              ),
                              content: const Text(
                                'If you wish to have the category only be shown under Income, please check the "Income only" box. Otherwise, leave this unchecked to account for rebates.',
                                style: TextStyle(color: Colors.black),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        color: mainColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.help_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: widget.selectedCategories.length,
            itemBuilder: (context, index) {
              final currentCategory = widget.selectedCategories.elementAt(index);
              final color = _categoryColors[currentCategory] ?? Colors.grey; // Use a default color (grey) if null
              return ListTile(
                title: Text(currentCategory, style: TextStyle(fontSize: 18),),
                leading: GestureDetector(
                  onTap: () {
                    _showColorPickerDialog((color) {
                      setState(() {
                        _selectedColor = color;
                        _categoryColors[currentCategory] = _selectedColor;
                      });
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: color,
                  ),
                ),
                trailing: _amountWidget(currentCategory),
                subtitle: Row(
                  children: [
                    const Text('Income only', style: TextStyle(fontSize: 12),),
                    Checkbox(
                      activeColor: mainColor,
                      value: _isIncomeMap[currentCategory] ?? false, 
                      onChanged: (bool? value) {
                        setState(() {
                          _isIncomeMap[currentCategory] = value ?? false;
                        });
                      }
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomSheet: Row(
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
                        double.parse(controller.text.trim()), // amount
                        true, // isRecurring
                        _categoryColors[category]!.value.toString(), // color
                        _isIncomeMap[category] ?? false,
                      ];
                    },
                  );

                  for (var entry in budgetAllocations.entries) {
                    await BudgetMethods().addBudget(entry.key, entry.value[0], entry.value[1], entry.value[2], entry.value[3], _currentMonth); // replace with isIncome
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
    );
  }
  
  // Helper 1: To allow all categories to have an initial (different) color. 
  // The first category will have the first color in the predefinedColors array,
  // second category will have the second color and so forth
  void _initializeCategoryColors() {
    int index = 0;
    for (var category in widget.selectedCategories) {
      _categoryColors[category] = predefinedColors[index % predefinedColors.length];
      index++;
    }
  }

  // Helper 2: Color Picker Dialog Box
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
          labelStyle: TextStyle(color: mainColor, fontSize: 12,),
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
