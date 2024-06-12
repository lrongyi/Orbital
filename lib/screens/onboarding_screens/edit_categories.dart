import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/onboarding_screens/set_budget.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/category_methods.dart';
import 'package:ss/services/models/budget.dart';
import 'package:ss/shared/main_screens_deco.dart';
import 'package:uuid/uuid.dart'; 
// special syntax to deal with conflicting class names
import 'package:ss/services/models/category.dart';


class EditCategories extends StatefulWidget {
  final Set<String> selectedCategories;

  const EditCategories({super.key, required this.selectedCategories});

  @override
  State<EditCategories> createState() => _EditCategoriesState();
}

class _EditCategoriesState extends State<EditCategories> {
  TextEditingController categoryNameController = TextEditingController();
  Map<String, Color> categoryColors = {};
  Color _selectedColor = Colors.blue;

  // List of predefined colors for the Block Picker
  final List<Color> predefinedColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.lime,
    Colors.indigo,
    Colors.brown,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.lightBlue,
    Colors.limeAccent,
    Colors.lightBlueAccent, 
    Colors.amberAccent,     
    Colors.lightGreenAccent, 
    Colors.cyanAccent,       
  ];

  @override
  void initState() {
    super.initState();
    _initializeCategoryColors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Edit Your Categories',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: widget.selectedCategories.length,
          itemBuilder: (context, index) {
            final currentCategory = widget.selectedCategories.elementAt(index);
            final color = categoryColors[currentCategory] ?? Colors.grey; // Use a default color (grey) if null
            return ListTile(
              title: Text(currentCategory),
              leading: CircleAvatar(
                backgroundColor: color,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  _showEditCategoryDialog(currentCategory: currentCategory, initialColor: color); // Helper 2
                },
              ),
            );
          },
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
              child: const Text('Next'),
              onPressed: () {  
                widget.selectedCategories.forEach((selectedCategory) {
                  // Create a new Category instance and budget 

                  String categoryId = Uuid().v1();

                  Category newCategory = Category(
                    id: categoryId, 
                    name: selectedCategory, 
                    color: categoryColors[selectedCategory].toString(), 
                    isRecurring: true, 
                    icon: 'Empty', 
                  );

                  CategoryMethods().addCategory(newCategory);

                  Budget newBudget = Budget(
                    categoryId: categoryId,
                    amount: 0.0,
                    month: Timestamp.fromDate(DateTime.now())
                  );

                  BudgetMethods().addBudget(newBudget);
                });
                
                // This one we should use Navigator.pushAndRemoveUntil because they already added the categories
                // to firebase, so cannot backout. Helps minimize possible bugs too
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: ((context) => SetBudget())),
                  (route) => false,
                );
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
      categoryColors[category] = predefinedColors[index % predefinedColors.length];
      index++;
    }
  }

  // Helper 2: Edit Category Dialog Box
  void _showEditCategoryDialog({required String currentCategory, required Color initialColor}) {
    categoryNameController.text = currentCategory;
    _selectedColor = initialColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Edit Category',
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Delete the category
                  setState(() {
                    widget.selectedCategories.remove(currentCategory);
                    categoryColors.remove(currentCategory);
                  });
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.delete,
                ),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: categoryNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 10),
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
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Save changes to category
                final newCategoryName = categoryNameController.text;
                if (newCategoryName != currentCategory) {
                  setState(() {
                    // Remove old category name and add new one
                    widget.selectedCategories.remove(currentCategory);
                    widget.selectedCategories.add(newCategoryName);
                    // Update category color
                    categoryColors[newCategoryName] = _selectedColor;
                  });
                  // Update the ListView item
                  Navigator.of(context).pop();
                } else {
                  // Only update color if the category name is not changed
                  setState(() {
                    categoryColors[currentCategory] = _selectedColor;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Save',
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
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

  // Helper 3: Color Picker Dialog Box
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