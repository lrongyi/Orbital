import 'package:flutter/material.dart';

class BudgetingDeco {
  static Widget buildCategoryTile(String categoryName, double amountSpent) {
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
      leading: CircleAvatar(
        backgroundColor: Colors.blue, // Change color if needed
        child: Icon(
          iconData,
          color: Colors.white,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            categoryName,
            // style: const TextStyle(color: Colors.white),
          ),
          Text(
            '\$${amountSpent.toStringAsFixed(2)}',
            // style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      // Add onTap callback if needed
    );
  }
}