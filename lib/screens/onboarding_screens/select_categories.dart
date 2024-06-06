import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/onboarding_screens/set_budget.dart';
import 'package:ss/shared/main_screens_deco.dart';

class SelectCategories extends StatefulWidget {
  const SelectCategories({super.key});

  @override
  State<SelectCategories> createState() => _SelectCategoriesState();
}

class _SelectCategoriesState extends State<SelectCategories> {
  
  final List<String> _availableCategories = [
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

  final Set<String> _selectedCategories = {};
  final TextEditingController categoryController = TextEditingController();

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
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
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
          
                // Insert buttons here
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: _availableCategories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
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
                ),
          
                //Add in new categories
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Did not see your category?',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
          
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: categoryController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainColor)
                              ),
                              labelText: 'Enter category',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(),
                            ),
                            cursorColor: mainColor,
                          ),
                        )
                      ),
          
                      const SizedBox(width: 10,),
          
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: mainColor,
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0)
                          )
                        ),
                        child: Text('Add'),
                        onPressed: () {
                          final newCategory = categoryController.text.trim();
                          if (newCategory.isNotEmpty && !_availableCategories.contains(newCategory)) {
                            setState(() {
                              _availableCategories.add(newCategory);
                              _selectedCategories.add(newCategory);
                              categoryController.clear();
                            });
                          }
                        },
                      )
                    ],
                    
                  ),
                ),
          
              ],
            ),
          );
        }
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
                if (_selectedCategories.isNotEmpty) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SetBudget(selectedCategories: _selectedCategories)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    showCloseIcon: true,
                    content: Text(
                      'Add some categories',
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
    );
  }
}