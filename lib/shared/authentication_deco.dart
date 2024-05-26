import 'package:flutter/material.dart';

Widget sizedBoxSpacer = const SizedBox(height: 20.0,);
EdgeInsets spaceBetweenForms = const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0);
BoxDecoration textFieldDeco = BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color.fromARGB(255, 88, 33, 33)),
                      // borderRadius: BorderRadius.circular(30)
                      );
InputDecoration inputDeco = const InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0
                          )
                        );
BoxDecoration buttonDeco = const BoxDecoration(
                      color: Color.fromARGB(255, 88, 33, 33),
                      // borderRadius: BorderRadius.circular(30)
                      );