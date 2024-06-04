import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/budget_methods.dart';
import 'package:ss/services/expense_methods.dart';
import 'package:ss/services/models/expense.dart';
import 'package:ss/shared/adding_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

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

 @override
  void initState() {
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0), 
                    ),
                    backgroundColor: Colors.white,
                    title: Text(
                      widget.isExpense ? 'Delete Expense' : 'Delete Income'
                    ),
                    content: const Text(
                      'Are you sure you want to delete this entry?'
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ExpenseMethods().deleteExpense(widget.expenseId);
                          Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Navigation(state: 1,)),
                          (route) => false);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.red,
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
                  _buildDateField(),
                  AddingDeco().buildRow('Amount', amountController),
                  _buildCategoryField(),
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
                _buildSaveButton(),
                _buildCancelButton(context),
              ],
            )
          ],
        )
      )
    );
  }

  Widget _buildSwitchButton(BuildContext context, String label, bool isExpense) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.isExpense == isExpense ? isExpense ? mainColor : incomeColor : Colors.white,
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
      )
    );
  }

  Widget _buildDateField() {
    return Row(
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
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (newDate != null) {
                setState(() {
                  dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
                  selectDate = newDate;
                });
              }
            },
          )
        )
      ]
    );
  }

  Widget _buildCategoryField() {
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
            
            stream: BudgetMethods().getCategoriesByMonth(selectDate),
          
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }   
          
              List<String> categories = snapshot.data!;
          
              return DropdownButtonFormField(
                  decoration: const InputDecoration(
                    hintText: 'Select Category',
                    
                  ),
                
                  value: categoryController.text.isEmpty ? null : categoryController.text,
                  onChanged: (newValue) {
                    setState(() {
                      categoryController.text = newValue!;
                    });
                  },
                
                  items: categories.map<DropdownMenuItem<String>>((String category) {
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
            }
          ),
        ),

        IconButton(
          icon: const Icon(Icons.add, size: 25),

          onPressed: () {
            showDialog(
              context: context, 
              builder: (context) {
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
                          decoration: const InputDecoration(labelText: 'Category'),
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
                        )
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        addCategoryController.clear();
                        budgetAmountController.clear();
                        Navigator.of(context).pop();
                      },

                      child: const Text('Cancel', style: TextStyle(color: Colors.black),)
                    ),

                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                                setState(() {
                                  category = addCategoryController.text;
                                  amount = double.parse(budgetAmountController.text).abs();
                                });
                                BudgetMethods().addBudget(category, amount);
                                Navigator.of(context).pop();
                              }
       
                        setState(() {
                          addCategoryController.clear();
                          budgetAmountController.clear();
                        });
                      }, 
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.black),
                      )
                    )
                  ],
                );
              }
            );
          },
        )
      ],
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
        Navigator.popUntil(context, (context) => context.isFirst);
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
                        MaterialPageRoute(builder: (context) => Navigation(state: 1,)),
                        (route) => false);
      },
      minWidth: 100,
      child: const Text('Cancel'),
    );
  }
}

