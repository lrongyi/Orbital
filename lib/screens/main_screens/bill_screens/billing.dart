import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/navigation_screen/navigation.dart';
import 'package:ss/services/bill_methods.dart';
import 'package:ss/services/models/bill.dart';
import 'package:ss/shared/adding_deco.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Future<Map<DateTime, List<Bill>>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _billsFuture = _fetchBills();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      now = focusedDay;
    });
    print('Selected day: ${DateFormat('yyyy-MM-dd').format(_selectedDay)}');
  }

  Future<Map<DateTime, List<Bill>>> _fetchBills() async {
    try {
      QuerySnapshot snapshot = await BillMethods().getBills().first;
      Map<DateTime, List<Bill>> billsByDay = {};
      for (var doc in snapshot.docs) {
        Bill bill = doc.data() as Bill;
        DateTime dueDate = (bill.due).toDate();
        DateTime normalizedDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
        if (!billsByDay.containsKey(normalizedDueDate)) {
          billsByDay[normalizedDueDate] = [];
        }
        billsByDay[normalizedDueDate]!.add(bill);
      }
      // print('Fetched bills by day: $billsByDay');
      return billsByDay;
    } catch (e) {
      print('Error fetching bills: $e');
      return {};
    }
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          }
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 3,
              color: mainColor,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
        onPressed: _showAddBillDialog,
        child: Icon(
            CupertinoIcons.add,
            color: mainColor,
          ),
      ),

      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.grey,),
          Container(
            color: mainColor,
          
            child: FutureBuilder<Map<DateTime, List<Bill>>>(
              future: _billsFuture,
              builder: (context, snapshot) {

                if(!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                
                Map<DateTime, List<Bill>> billsByDay = snapshot.data!;
                // print('Fetched bills by day: $billsByDay');
 
                return TableCalendar(
                      pageJumpingEnabled: false,
                      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
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
                          
                      calendarStyle: CalendarStyle(
                        isTodayHighlighted: false,
                        defaultTextStyle: const TextStyle(color: Colors.white),
                        outsideTextStyle: const TextStyle(color: Colors.black),
                        holidayTextStyle: const TextStyle(color: Colors.white),
                        disabledTextStyle: const TextStyle(color: Colors.black),
                        weekendTextStyle: const TextStyle(color: Colors.white60),
                        withinRangeTextStyle: const TextStyle(color: Colors.white),
                        selectedDecoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      focusedDay: now, 
                      firstDay: DateTime(now.year, now.month, 1), 
                      lastDay: DateTime(now.year, now.month + 1, 0),
                          
                      onDaySelected: _onDaySelected,
                      // Enter database method
                      eventLoader: (day) {
                        final events = billsByDay[DateTime(day.year, day.month, day.day)] ?? [];
                        // print('Events for ${DateFormat('yyyy-MM-dd').format(day)}: ${events.length}');
                        return events;
                      },
                    );
              }
            ),
          ),
          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: BillMethods().getBillsForDayStream(_selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No bills for this day.'));
                }

                final bills = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    Bill bill = bills[index].data() as Bill;
                    String billId = bills[index].id;
                    double amount = bill.amount;
                    bool isBillPaid = bill.isPaid;

                    return ListTile(
                      title: Text(bill.name),
                      subtitle: Text('\$${bill.amount.toStringAsFixed(2)}'),
                      trailing: Icon(
                        bill.isPaid ? Icons.check_circle : Icons.warning_outlined,
                        size: 30,
                        color: bill.isPaid ? incomeColor : mainColor,
                      ),

                      // Edit the bill
                      onTap: () { 
                          showDialog(
                              context: context,
                              builder: (context) {
                                double newAmount = amount;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0), 
                                      ),
                                      backgroundColor:Colors.white,
                                      title: const Text('Edit Bill',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          )),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFormField(
                                            initialValue: amount.toStringAsFixed(2),
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                    decimal: true),
                                          
                                            // Update budget as value is changed
                                            onChanged: (value) {
                                              newAmount =
                                                  double.tryParse(value) ?? amount;
                                              BillMethods().updateBill(billId, bill.copyWith(amount: newAmount));
                                            },
                                          ),
                                          const SizedBox(height: 15.0,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Paid',
                                              ),
                                              Switch(
                                                activeColor: mainColor,
                                                value: isBillPaid,
                                                onChanged: (bool value) {
                                                  setState(() {
                                                    isBillPaid = value;
                                                    BillMethods().updateBill(billId, bill.copyWith(isPaid: isBillPaid));
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ]
                                      ),
                                      actions: [
                                        // save button
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              'Save',
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            )),
                                      ],
                                    );
                                  }
                                );
                              });
                      },

                      // Delete the bill
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              backgroundColor: Colors.white,
                              title: const Text('Delete Bill'),
                              content: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Are you sure you want to delete this bill?'),
                                  Text(
                                    'You cannot undo this action!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    BillMethods().deleteBill(billId);
                                    setState(() {
                                      _billsFuture = _fetchBills();
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
      );
  }

  void _showAddBillDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    bool isPaid = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              backgroundColor: Colors.white,
              title: const Text(
                'Add New Bill',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AddingDeco().buildRow('Name', nameController),
                    const SizedBox(height: 15.0),
                    AddingDeco().buildRow('Amount', amountController),
                    const SizedBox(height: 15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Paid'),
                        Switch(
                          activeColor: mainColor,
                          value: isPaid,
                          onChanged: (bool value) {
                            setState(() {
                              isPaid = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Bill newBill = Bill(
                        name: nameController.text,
                        amount: double.parse(amountController.text),
                        due: Timestamp.fromDate(_selectedDay),
                        isPaid: isPaid,
                      );
                      BillMethods().addBill(newBill);
                      setState(() {
                        _billsFuture = _fetchBills();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}