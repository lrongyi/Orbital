import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Dummy data for demonstration
  // Need to link with the Add category button in budgeting.
  final List<Category> categories = [
    Category(name: 'Food', spending: 200, color: Colors.blue, icon: Icons.fastfood),
    Category(name: 'Transportation', spending: 150, color: Colors.green, icon: Icons.directions_car),
    Category(name: 'Entertainment', spending: 100, color: Colors.orange, icon: Icons.movie),
  ];

  @override
  Widget build(BuildContext context) {
    double totalSpending = categories.fold(0, (total, category) => total + category.spending);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(
          top: 40, bottom: 0,
          right: 16, left: 16,
          ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pie chart with total spending in its center
            Stack(
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: categories.map((category) {
                        return PieChartSectionData(
                          color: category.color,
                          value: category.spending,
                          title: '',
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '\$$totalSpending',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          'Total monthly spending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Categories label + View All button
            // For some reason the outer padding doesn't work
            // So the row needs its own padding
            const Padding(
              padding: EdgeInsets.only(
                top: 0, bottom: 16,
                right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )
                  ),
                  Text(
                    'Amount',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    )
                  ),
                ]
              ),
            ),
            // List of categories and their spending
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: categories[index].color,
                      child: Icon(categories[index].icon, color: Colors.white),
                    ),
                    title: Text(categories[index].name),
                    trailing: Text(
                      '\$${categories[index].spending.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                      ),
                      ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Category {
  final String name;
  final double spending;
  final Color color;
  final IconData icon;

  Category({required this.name, required this.spending, required this.color, required this.icon});
}
