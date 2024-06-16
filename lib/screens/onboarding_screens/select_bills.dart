import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/screens/onboarding_screens/add_bills.dart';
import 'package:ss/screens/onboarding_screens/select_categories.dart';
import 'package:ss/services/bill_methods.dart';
import 'package:ss/services/models/bill.dart';
import 'package:ss/shared/authentication_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';
import 'package:table_calendar/table_calendar.dart';

class SelectBills extends StatefulWidget {

  List<Bill> bills = [];

  SelectBills({super.key, required this.bills});

  @override
  State<SelectBills> createState() => _SelectBillsState();
}

class _SelectBillsState extends State<SelectBills> {

  DateTime now = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    widget.bills.sort((a, b) => a.due.compareTo(b.due));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      now = focusedDay;
    });

    Navigator.push(context, MaterialPageRoute(builder: (context) => AddBill(date: _selectedDay, bills: widget.bills, isAdding: true,)));
  }
  
  List<Bill> _getBillsForDay(DateTime day) {
    final bills = widget.bills.where((bill) =>
    bill.due.toDate().day == day.day).toList();
    return bills;
  }

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,

      body: Column(
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
              pageJumpingEnabled: false,
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

              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white60),
                weekendStyle: TextStyle(color: Colors.white54)
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
                ),
                markerDecoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              ),

              focusedDay: now, 
              firstDay: DateTime(now.year, now.month, 1), 
              lastDay: DateTime(now.year, now.month + 1, 0),
      
              onDaySelected: _onDaySelected,
              eventLoader: (day) => _getBillsForDay(day),
            ),
          ),

          const Divider(),
        
          Expanded(
            child: widget.bills.isNotEmpty 
            ? ListView.builder(
                itemCount: widget.bills.length,
                itemBuilder: (context, index) {
                  final bill = widget.bills[index];


                  // cannot view last tile if it is with the bottom sheet

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: bill.isPaid ? incomeColor : mainColor,
                          radius: 10,
                        ),
                        title: Text(bill.name),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(bill.due.toDate().toLocal()),),
                        trailing: Text('\$${bill.amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14),),
                        onTap: () {
                  
                        },
                      ),
                      Divider(
                        color: bill.isPaid ? incomeColor : mainColor,
                        thickness: 1.0,
                      )
                    ],
                  );
                },
              )
            : const Center(
              child: Text(
                'No bills found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black
                ),
              ),
            )
          )
        ],
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
              Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: ((context) => SelectCategories())),
                    (route) => false
                  );
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
                for (var bill in widget.bills) {
                  BillMethods().addBill(bill);
                }
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: ((context) => SelectCategories())),
                    (route) => false
                  );
              },
            ),
          )
        ],
      ),
    );
  }
}