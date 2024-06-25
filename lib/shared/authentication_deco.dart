import 'package:flutter/material.dart';
import 'package:ss/shared/main_screens_deco.dart';

Widget sizedBoxSpacer = const SizedBox(height: 20.0,);
EdgeInsets spaceBetweenForms = const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0);
BoxDecoration textFieldDeco = BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: mainColor),
                      borderRadius: BorderRadius.circular(10)
                      );
InputDecoration inputDeco = const InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0
                          )
                        );
BoxDecoration buttonDeco = BoxDecoration(
                      color: mainColor,
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 74, 23, 23), 
                          mainColor, 
                          const Color.fromARGB(255, 102, 43, 43), 
                          mainColor, 
                          const Color.fromARGB(255, 74, 23, 23), 
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30)
                      );

BoxDecoration switchAuthButtonDeco = BoxDecoration(
      color: Colors.transparent,
      border: Border.all(
        color: mainColor,
        width: 2.0, 
      ),
      borderRadius: BorderRadius.circular(30), 
    );

Row orDivider = Row(
                        children: [
                          Expanded(
                            child: Divider(
                              indent: 20.0,
                              endIndent: 15, 
                              thickness: 1,
                              color: mainColor,
                            ),
                          ),
                          Text(
                            'OR',
                            style: TextStyle(
                              color: mainColor, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              indent: 15, 
                              endIndent: 20.0,
                              thickness: 1,
                              color: mainColor,
                            ),
                          ),
                        ],
                      );