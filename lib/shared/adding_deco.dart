import 'package:flutter/material.dart';

class AddingDeco {

  // method used to build a child that is a row (with title + text form field)
  static Widget buildRow(labelText) {
    String hintText = labelText.toLowerCase();
    TextInputType keyboardType;
    if (labelText == 'Amount') {
      keyboardType = TextInputType
          .number; // Set keyboardType to number for Date and Amount
    } else {
      keyboardType =
          TextInputType.text; // Set keyboardType to text for other fields
    }

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            labelText,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: 'Enter $hintText',
            ),
          ),
        ),
      ],
    );
  }
}
