import 'package:flutter/material.dart';
import 'package:ss/screens/main_screens/navigation.dart';
import 'package:ss/screens/main_screens/sub_screens/adding_income.dart';
import 'package:ss/shared/adding_deco.dart';

class AddingExpense extends StatefulWidget {
  const AddingExpense({super.key});

  @override
  State<AddingExpense> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<AddingExpense> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Navigation()),
                (route) => false);
          },
        ),
        centerTitle: true,
        title: const Text('Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
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
                  AddingDeco.buildRow('Date'),
                  AddingDeco.buildRow('Amount'),
                  AddingDeco.buildRow('Category'),
                  AddingDeco.buildRow('Note'),
                  const SizedBox(height: 40),
                  AddingDeco.buildRow('Description'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Save button
                MaterialButton(
                  color: Colors.red[300],
                  onPressed: () {
                    // TODO: Handle saving data to firebase and routing back to home page
                    Navigator.pop(context);
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