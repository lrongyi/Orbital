import 'package:flutter/material.dart';

class AddingDeco {
  // method used to build a child that is a row (with title + text form field)
  Widget buildRow(labelText, TextEditingController controller, Icon icon, Color color) {
    String hintText = labelText.toLowerCase();
    TextInputType keyboardType;
    if (labelText == 'Amount') {
      keyboardType = TextInputType.number;
    } else {
      keyboardType = TextInputType.text;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SizedBox(
        //   width: 100,
        //   child: Text(
        //     labelText,
        //     textAlign: TextAlign.start,
        //   ),
        // ),
        // const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            cursorColor: color,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter $labelText';
              }
              return null;
            },
            textAlignVertical: TextAlignVertical.center,
            controller: controller,
            keyboardType: keyboardType,
            readOnly: labelText == 'Category' ? true : false,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: color)
              ),
              prefixIcon: icon,
              hintText: labelText == 'Category'
                  ? '$labelText'
                  : '$labelText',
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
