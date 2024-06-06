import 'package:flutter/material.dart';

class AddBill extends StatefulWidget {

  final DateTime date;

  const AddBill({super.key, required this.date});

  @override
  State<AddBill> createState() => _AddBillState();
}

class _AddBillState extends State<AddBill> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}