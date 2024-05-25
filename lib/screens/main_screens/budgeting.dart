import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/main_screens/sub_screens/budget_settings.dart';
import 'package:ss/shared/budgeting_deco.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {
  double monthlySpent = 1400;
  double totalBudget = 1500;

  List<String> categoryIcons = [
    'entertainment',
    'food',
    'home',
    'pet',
    'shopping',
    'tech',
    'travel',
  ];

  String iconSelected = '';

  @override
  Widget build(BuildContext context) {
    double ratioSpent = (monthlySpent / totalBudget);
    double remainingAmount = totalBudget - monthlySpent;
    Color progressBarColour;
    if (ratioSpent < 1/3) {
      progressBarColour = Colors.green;
    } else if (1/3 <= ratioSpent && ratioSpent < 2/3) {
      progressBarColour = Colors.orange;
    } else {
      progressBarColour = Colors.red;
    }

    Map<String, double> categorySpent = {
      'Food': 900.0,
      'Transport': 300.0,
      'Household': 200.0,
      'Clothing': 0,
      'Health': 0,
      'Education': 0,
      'Gaming': 0,
      'Subscriptions': 0,
    };

    return Column(
      children: [
        //container
        Container(
          // color: Colors.redAccent,
          child: Column(
            children: [
              Container(
                  // color: Colors.black,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 5, left: 16, right: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Remaining (Monthly)',
                                  // style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${remainingAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    // color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 150,
                                  child: MaterialButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BudgetSettings()));
                                    },
                                    child: const Text('Budget Settings'),
                                  ),
                                ),
                                Container(
                                  width: 150,
                                  child: MaterialButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          bool isOpen = false;

                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: const Text('Create a Category'),
                                                backgroundColor: Colors.purple[50],
                                                content: SizedBox(
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        textAlignVertical: TextAlignVertical.center,
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          hintText: 'Name',
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                            borderSide: BorderSide.none
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 16),
                                                      TextFormField(
                                                        onTap: () {
                                                          setState(() {
                                                            isOpen = !isOpen;
                                                          });
                                                        },
                                                        textAlignVertical: TextAlignVertical.center,
                                                        readOnly: true,
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          filled: true,
                                                          suffixIcon: const Icon(CupertinoIcons.chevron_down, size: 14,),
                                                          fillColor: Colors.white,
                                                          hintText: 'Icon',
                                                          border: OutlineInputBorder(
                                                            borderRadius: isOpen 
                                                            ? const BorderRadius.vertical(
                                                            top: Radius.circular(12),
                                                            )
                                                            : BorderRadius.circular(12),
                                                            borderSide: BorderSide.none
                                                          ),
                                                        ),
                                                      ),
                                                      isOpen
                                                      ? Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        height: 200,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.vertical(
                                                            bottom: Radius.circular(12),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: GridView.builder(
                                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 3,
                                                              mainAxisSpacing: 5,
                                                              crossAxisSpacing: 5,
                                                              ),
                                                            itemCount: categoryIcons.length,
                                                            itemBuilder: (context, int i) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    iconSelected = categoryIcons[i];
                                                                  });
                                                                },
                                                                child: Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                      width: 3,
                                                                      color: iconSelected == categoryIcons[i]
                                                                      ? Colors.green
                                                                      : Colors.grey
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(12),
                                                                    image: DecorationImage(
                                                                      image: AssetImage(
                                                                        'assets/${categoryIcons[i]}.png'
                                                                      )
                                                                    )
                                                                  )
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      )
                                                      : Container(),
                                                      const SizedBox(height: 16),
                                                      TextFormField(
                                                        textAlignVertical: TextAlignVertical.center,
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          hintText: 'Colour',
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                            borderSide: BorderSide.none
                                                          ),
                                                        ),
                                                      ),
                                                                                                
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          );
                                        }
                                      );
                                    },
                                    child: const Text('Add Category'),
                                  ),
                                ),
                              ],
                            )
                          ]))),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  // color: Colors.purple,
                  height: 50,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Spent',
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      )),
                                  Text(
                                    '\$${monthlySpent.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 150,
                                child: LinearProgressIndicator(
                                  minHeight: 10,
                                  value: ratioSpent,
                                  backgroundColor: Colors.black,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          progressBarColour),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Total',
                                      style: TextStyle(
                                        // color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      )),
                                  Text(
                                    '\$${totalBudget.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Positioned(
                          //   top: 40,
                          //   left: 240,
                          //   right: 0,
                          //   child: Text(
                          //     '${percentageSpent.toStringAsFixed(0)}%',
                          //     textAlign: TextAlign.center,
                          //     style: const TextStyle(
                          //       // color: Colors.white,
                          //       fontWeight: FontWeight.bold,
                          //       fontSize: 15,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Categories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            Text(
              'Spending',
              style: TextStyle(color: Colors.grey),
            )
          ]),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            // color: Colors.blue,
            width: double.maxFinite,
            child: ListView.separated(
              itemCount: categorySpent.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                String categoryName = categorySpent.keys.elementAt(index);
                double amountSpent = categorySpent.values.elementAt(index);
                return BudgetingDeco.buildCategoryTile(
                    categoryName, amountSpent);
              },
            ),
          ),
        ),
      ],
    );
  }
}
