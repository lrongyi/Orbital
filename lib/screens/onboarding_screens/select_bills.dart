import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/onboarding_screens/add_bills.dart';
import 'package:ss/shared/authentication_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectBills extends StatefulWidget {
  const SelectBills({super.key});

  @override
  State<SelectBills> createState() => _SelectBillsState();
}

class _SelectBillsState extends State<SelectBills> {

  DateTime now = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      now = focusedDay;
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddBill(date: _selectedDay,)));
  }
  
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  SafeArea(
                    child: Text(
                      'Add your monthly bills',
                      style: TextStyle(
                        color: mainColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    'Select the date of payment and enter your bills',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 14
                    ),
                    textAlign: TextAlign.center,
                  ),
                  sizedBoxSpacer
                ],
              ),
            ),
            
            Container(
              color: mainColor,
              child: TableCalendar(
                pageJumpingEnabled: true,
                selectedDayPredicate: (day) => isSameDay(day, now),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(
                    color: Colors.white
                  ),
                  leftChevronVisible: false,
                  rightChevronVisible: false, 
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: false,
                  defaultTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.black),
                  holidayTextStyle: TextStyle(color: Colors.white),
                  disabledTextStyle: TextStyle(color: Colors.black),
                  weekendTextStyle: TextStyle(color: Colors.white60),
                  withinRangeTextStyle: TextStyle(color: Colors.white),
                  selectedDecoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.rectangle
                  )
                ),
                focusedDay: now, 
                firstDay: DateTime(now.year, now.month, 1), 
                lastDay: DateTime(now.year, now.month + 1, 0),

                onDaySelected: _onDaySelected,
              ),
            ),
          ],
        ),
      ),

      bottomSheet: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            onPressed: () {
              // Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(builder: ((context) => Navigation(state: 0))),
              //       (route) => false
              //     );
            },
          ),
          SizedBox(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: mainColor,
                elevation: 10.0  
              ),
              child: const Text('Next'),
              onPressed: () {
                
              },
            ),
          )
        ],
      ),
    );
  }
}