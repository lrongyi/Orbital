// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:ss/services/expense_methods.dart';

class HomeDeco {
  static Widget pieChartTitleWidget(String title, double spendingCat, DateTime time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: FutureBuilder(
        
        future: ExpenseMethods().getMonthlySpending(time),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          } else {
            double netSpend = snapshot.data ?? 0.0;
            String percentage = ((spendingCat / netSpend) * -100).toStringAsFixed(1);

            return Text(
              '$title ($percentage%)',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          }

        },
      )
    );
  }
}

