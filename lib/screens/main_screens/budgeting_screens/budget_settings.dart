import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ss/shared/main_screens_deco.dart';

class BudgetSettings extends StatefulWidget {
  const BudgetSettings({Key? key}) : super(key: key);

  @override
  State<BudgetSettings> createState() => _BudgetSettingsState();
}

class _BudgetSettingsState extends State<BudgetSettings> {
  late Map<String, double> categoryBudget;
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();

    categoryBudget = {
      'Food': 0.0,
      'Transportation': 0.0,
      'Entertainment': 0.0,
    };

    controllers = Map.fromIterable(categoryBudget.keys,
        key: (key) => key,
        value: (key) => TextEditingController(text: categoryBudget[key]!.toStringAsFixed(2)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: mainColor,
        title: const Text(
          'Budget Settings',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: categoryBudget.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final categoryName = categoryBudget.keys.elementAt(index);
                  final amountSpent = categoryBudget.values.elementAt(index);
                  return buildCategoryTile(context, categoryName, amountSpent);
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 150,
                  child: MaterialButton(
                    onPressed: () {
                      // TODO: Save the changes of the budget amount and reflect it on the budgeting screen (e.g. change totalBudget)
                      Navigator.pop(context);
                    },
                    color: Colors.green,
                    textColor: Colors.white,
                    child: const Text('Save Changes'),
                  ),
                ),
                Container(
                  width: 150,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.red,
                    textColor: Colors.white,
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // this was hard coded, might need to gpt this on how to make it dynamic according to
  // the details provided for the Create a Category
  Widget buildCategoryTile(BuildContext context, String categoryName, double amountSpent) {
    TextEditingController controller = TextEditingController(text: amountSpent.toStringAsFixed(2));
    IconData iconData;
    switch (categoryName) {
      case 'Food':
        iconData = Icons.fastfood;
        break;
      case 'Transport':
        iconData = Icons.directions_car;
        break;
      case 'Household':
        iconData = Icons.home;
        break;
      case 'Clothing':
        iconData = Icons.shopping_bag;
        break;
      case 'Health':
        iconData = Icons.favorite;
        break;
      case 'Education':
        iconData = Icons.school;
        break;
      case 'Gaming':
        iconData = Icons.videogame_asset;
        break;
      case 'Subscriptions':
        iconData = Icons.subscriptions;
        break;
      default:
        iconData = Icons.category;
    }

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: Colors.white,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(categoryName),
          SizedBox(
            width: 100,
            child: TextFormField(
              controller: controllers[categoryName],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  categoryBudget[categoryName] = double.parse(value);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
