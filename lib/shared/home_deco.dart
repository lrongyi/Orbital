import 'package:flutter/material.dart';

class HomeDeco {
  static Widget pieChartTitleWidget(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Text(
        // TODO: Change dummy percentage to actual percentage spending
        '$title (dummy%)',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}