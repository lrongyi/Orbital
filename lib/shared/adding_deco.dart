import 'package:flutter/material.dart';

class AddingDeco {
  // method used to build a child that is a row (with title + text form field)
  Widget buildRow(labelText, TextEditingController controller) {
    String hintText = labelText.toLowerCase();
    TextInputType keyboardType;
    if (labelText == 'Amount') {
      keyboardType = TextInputType.number;
    } else {
      keyboardType = TextInputType.text;
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
            textAlignVertical: TextAlignVertical.center,
            controller: controller,
            keyboardType: keyboardType,
            readOnly: labelText == 'Category' ? true : false,
            decoration: InputDecoration(
              hintText: labelText == 'Category'
                  ? 'Select $hintText'
                  : 'Enter $hintText',
              suffixIcon: labelText == 'Category'
                  ? IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 25,
                      ),
                      onPressed: () {})
                  : null,
            ),
          ),
        ),
      ],
    );
  }


}
