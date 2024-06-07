import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/bill_methods.dart';
import 'package:ss/services/models/bill.dart';
import 'package:ss/shared/main_screens_deco.dart';
import 'package:table_calendar/table_calendar.dart';

class Billing extends StatefulWidget {
  const Billing({super.key});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {

  bool notifications = true;

  DateTime now = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<Bill>> _billsByDay = {};

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      now = focusedDay;
    });
    print('Selected day: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}');
  }

  void _fetchBills() async {
    DateTime firstDay = DateTime(now.year, now.month, 1);
    DateTime lastDay = DateTime(now.year, now.month + 1, 0);

    for (DateTime day = firstDay;
        day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay);
        day = day.add(const Duration(days: 1))) {
      List<Bill> bills = await BillMethods().getBillsForDay(day);
      print('Fetched ${bills.length} bills for ${DateFormat('yyyy-MM-dd').format(day)}');
      setState(() {
        _billsByDay.putIfAbsent(day, () => bills);
      });
    }
  }

  List<Bill> _getBillsForDay(DateTime day) {
    return _billsByDay[day] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text(
          'Bills',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500
          ),
        ),

        leading: Center(
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Navigation(state: 0,)), (route) => false);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                weight: 1000,
              ),
            ),
          ),
        ),
        
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                notifications = !notifications;
              });
            }, 
            icon: notifications 
            ? const Icon(
                Icons.notifications,
                color: Colors.white,
              ) 
            : const Icon(
                Icons.notifications_off,
                color: Colors.white
              ),
          )
        ],
      ),

      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.grey,),
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
                    selectedDecoration: BoxDecoration(),
                    markerDecoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  focusedDay: now, 
                  firstDay: DateTime(now.year, now.month, 1), 
                  lastDay: DateTime(now.year, now.month + 1, 0),
          
                  onDaySelected: _onDaySelected,
                  // Enter database method
                  eventLoader: (day) => _getBillsForDay(day),
                ),
              ),

              // Expanded(
              //   child: ListView.builder(
              //     itemCount: _getBillsForDay(_selectedDay).length,
              //     itemBuilder: (context, index) {
              //       Bill bill = _getBillsForDay(_selectedDay)[index];
              //       return ListTile(
              //         title: Text(bill.name),
              //         subtitle: Text('Amount: ${bill.amount}'),
              //         trailing: Icon(
              //           bill.isPaid ? Icons.check_circle : Icons.warning,
              //           color: bill.isPaid ? Colors.green : Colors.red,
              //         ),
              //       );
              //     }
              //   )
              // ),
        ],
      ),
      );
  }
}