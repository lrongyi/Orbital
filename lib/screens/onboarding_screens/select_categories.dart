import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/onboarding_screens/edit_categories.dart';
import 'package:ss/shared/main_screens_deco.dart';

class SelectCategories extends StatefulWidget {
  const SelectCategories({super.key});

  @override
  State<SelectCategories> createState() => _SelectCategoriesState();
}

class _SelectCategoriesState extends State<SelectCategories> {
  
  final List<String> _availableExpenseCategories = [
    'Food',
    'Groceries',
    'Transportation',
    'Healthcare',
    'Education',
    'Fitness',
    'Sports',
    'Entertainment',
    'Video Games',
    'Socializing',
    'Shopping',
    'Travel',
    'Gifts',
    'Personal Care',
    'Hobbies',
    'Technology',
    'Home Decor',
    'Pet Expenses',
    'Investments',
    'Books',
    'Arts',
    'Outdoor Activities',
  ];

  final List<String> _availableIncomeCategories = [
    'Reimbursement',
    'Allowance',
    'Bonus',
    'Rebates',
    'Petty Cash',
    'Others',
  ];

  final Set<String> _selectedExpenseCategories = {};
  final Set<String> _selectedIncomeCategories = {};
  final TextEditingController expenseCategoryController = TextEditingController();
  final TextEditingController incomeCategoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SafeArea(
                  child: SizedBox(
                    height: 75.0,
                    width: MediaQuery.of(context).size.width,
                    //insert an image
                    child: Image.asset(
                      "assets/ss_red.png",
                      fit: BoxFit.scaleDown,
                    )
                  ),
                ),
          
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Text(
                    'Choose some categories to start planning your budget',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
          
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Expense Categories
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expense Categories',
                            style: TextStyle(
                              color: mainColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: mainColor),
                            onPressed: () => _showAddCategoryDialog('expense'),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: _availableExpenseCategories.map((category) {
                          final isSelected = _selectedExpenseCategories.contains(category);
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedExpenseCategories.add(category);
                                } else {
                                  _selectedExpenseCategories.remove(category);
                                }
                              });
                            },
                            selectedColor: mainColor,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 10), // Add space between sections

                      // Income Categories
                      Row(
                        children: [
                          const Text(
                            'Income Categories',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () => _showAddCategoryDialog('income'),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 10.0,
                        runSpacing: 10.0,
                        children: _availableIncomeCategories.map((category) {
                          final isSelected = _selectedIncomeCategories.contains(category);
                          return ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedIncomeCategories.add(category);
                                } else {
                                  _selectedIncomeCategories.remove(category);
                                }
                              });
                            },
                            selectedColor: Colors.green,
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        }
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
                      (route) => false
                    );
              },
            ),
            SizedBox(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: mainColor,
                  elevation: 10.0  
                ),
                child: const Text('Next'),
                onPressed: () {
                  if (_selectedExpenseCategories.isNotEmpty || _selectedIncomeCategories.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditCategories(
                      selectedExpenseCategories: _selectedExpenseCategories,
                      selectedIncomeCategories: _selectedIncomeCategories,
                    )));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      showCloseIcon: true,
                      content: Text(
                        'Select some categories',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      backgroundColor: Colors.red,
                      )
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

  void _showAddCategoryDialog(String categoryType) {
    final TextEditingController categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), 
            side: const BorderSide(
              color: Colors.black,
              width: 2.0,
            )
          ),
          title: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.add_box,
                color: Colors.black,
              ),
              const SizedBox(width: 20,),
              const Text(
                'Add New Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black
                ),
              ),
              const SizedBox(width: 35,),
              IconButton(
                onPressed: () {
                  categoryController.clear();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close,
                  color: Colors.black,
                ),
              )
            ],
          ),
          content: TextFormField(
            cursorColor: mainColor,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter Category';
              } 
              return null;
            },
            controller: categoryController,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: mainColor)
              ),
              hintText: 'Enter Category',
              hintStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
              prefixIcon: const Icon(
                applyTextScaling: true,
                Icons.category_rounded,
                color: Colors.black
              )
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: categoryType == 'expense' ? mainColor : incomeColor,
                ),
                onPressed: () {
                  final newCategory = categoryController.text.trim();
                  if (newCategory.isNotEmpty) {
                    setState(() {
                      if (categoryType == 'expense') {
                        if (!_availableExpenseCategories.contains(newCategory)) {
                          _availableExpenseCategories.add(newCategory);
                          _selectedExpenseCategories.add(newCategory);
                        }
                      } else {
                        if (!_availableIncomeCategories.contains(newCategory)) {
                          _availableIncomeCategories.add(newCategory);
                          _selectedIncomeCategories.add(newCategory);
                        }
                      }
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save', style: TextStyle(color: Colors.white),),
              ),
            ),
          ],
        );
      },
    );
  }
}
