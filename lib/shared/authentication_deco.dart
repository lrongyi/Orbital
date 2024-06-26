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

class GoogleBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final borderRadius = BorderRadius.circular(30.0).toRRect(rect);

    final colors = [
      Color(0xFF3367D6), 
      Color(0xFF287B37), 
      Color(0xFFE1A500), 
      Color(0xFFC0342D), 
    ];

    final gradient = LinearGradient(
      colors: colors,
      stops: [0.0, 0.33, 0.66, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final shader = gradient.createShader(rect);

    paint.shader = shader;

    canvas.drawRRect(borderRadius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}