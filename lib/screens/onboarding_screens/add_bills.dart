import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ss/screens/onboarding_screens/select_bills.dart';
import 'package:ss/services/models/bill.dart';
import 'package:ss/shared/adding_deco.dart';
import 'package:ss/shared/authentication_deco.dart';
import 'package:ss/shared/main_screens_deco.dart';

class AddBill extends StatefulWidget {

  final DateTime date;
  final List<Bill> bills;
  bool isAdding;
  

  AddBill({super.key, required this.date, required this.bills, required this.isAdding});

  @override
  State<AddBill> createState() => _AddBillState();
}

class _AddBillState extends State<AddBill> {

  TextEditingController amountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  bool _isPaid = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    List<Bill> billsForSelectedDate = _getBillsForSelectedDate(widget.date);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: mainColor,
                          weight: 1000,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10,),

                      Text(
                        'Add/Edit Bills',
                        style: TextStyle(
                          fontSize: 20,
                          color: mainColor,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  )
                ),

                const SizedBox(height: 25,),

                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _isPaid ? incomeColor : mainColor, width: 2.0)
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(widget.date.toLocal()),
                      style: TextStyle(
                        fontSize: 20,
                        color: _isPaid ? incomeColor : mainColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 20, right: 20,
                    top: 40,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      _buildSwitchButton(context, 'Add', true),
                      _buildSwitchButton(context, 'Edit', false)
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: widget.isAdding 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddingDeco().buildRow('Name', nameController, Icon(Icons.abc, color: _isPaid ? incomeColor : mainColor,), _isPaid ? incomeColor : mainColor,),
                          sizedBoxSpacer,
                          AddingDeco().buildRow('Amount', amountController, Icon(Icons.monetization_on_outlined, color: _isPaid ? incomeColor : mainColor,), _isPaid ? incomeColor : mainColor,),
                          sizedBoxSpacer,
                          _buildPaidSwitch(),
                        ],
                      )
                    : billsForSelectedDate.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: billsForSelectedDate.length,
                          itemBuilder: (context, index) {
                            final bill = billsForSelectedDate[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(bill.name),
                                  subtitle: Text(DateFormat('dd/MM/yyyy').format(bill.due.toDate().toLocal())),
                                  trailing: Text('\$${bill.amount.toStringAsFixed(2)}'),
                                  onTap: () {
                                    _showEditDialog(bill);
                                  },
                                  onLongPress: () {
                                    _showDeleteConfirmation(bill);
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
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: widget.isAdding
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    
                      children: [
                        _buildSaveButton(),
                        _buildCancelButton(context),
                      ],
                    )
                  : null
                )
              ],
            ),
          )
        ],
      )

    );
  }

  List<Bill> _getBillsForSelectedDate(DateTime date) {
    return widget.bills.where((bill) {
      DateTime billDate = bill.due.toDate().toLocal();
      return billDate.year == date.year &&
          billDate.month == date.month &&
          billDate.day == date.day;
    }).toList();
  }

   void _showEditDialog(Bill bill) {
    final GlobalKey<FormState> _dialogFormKey = GlobalKey<FormState>();

    nameController.text = bill.name;
    amountController.text = bill.amount.toStringAsFixed(2);
    _isPaid = bill.isPaid;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), 
                side: const BorderSide(
                  color: Colors.black,
                  width: 2.0,
                )
              ),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: _isPaid ? incomeColor : mainColor,
                  ),
                  const SizedBox(width: 30,),
                  const Text('Edit Bill'),
                  const SizedBox(width: 50,),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    }, 
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    )
                  )
                ],
              ),
              content: Form(
                key: _dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AddingDeco().buildRow('Name', nameController, Icon(Icons.abc, color: _isPaid ? incomeColor : mainColor,), _isPaid ? incomeColor : mainColor,),
                    sizedBoxSpacer,
                    AddingDeco().buildRow('Amount', amountController, Icon(Icons.monetization_on_outlined, color: _isPaid ? incomeColor : mainColor,), _isPaid ? incomeColor : mainColor,),
                    sizedBoxSpacer,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Paid',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        Switch(
                          value: _isPaid,
                          onChanged: (value) {
                            setState(() {
                              _isPaid = value;
                            });
                          },
                          activeColor: incomeColor,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: _isPaid ? incomeColor : mainColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_formKey.currentState!.validate()) {
                          bill.name = nameController.text;
                          bill.amount = double.parse(amountController.text);
                          bill.isPaid = _isPaid;
                        }
                      });
                      Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SelectBills(bills: widget.bills,)),
                            (route) => false);
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showDeleteConfirmation(Bill bill) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), 
            side: const BorderSide(
              color: Colors.black,
              width: 2.0,
            )
          ),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delete Bill'
              ),
              const SizedBox(width: 50,),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              )
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this bill?'),
              Text(
                'You cannot undo this action!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )
              ),
            ]
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    widget.bills.remove(bill);
                  });
                  Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SelectBills(bills: widget.bills,)),
                            (route) => false);
                },
                style: ButtonStyle(
                  side: MaterialStateProperty.resolveWith((states) => const BorderSide(
                    color: Colors.red,
                    width: 1.5, 
                  )),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ]
        );
      }
    );
  }

   Widget _buildSwitchButton(BuildContext context, String label, bool isAdd) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isAdding == isAdd ? _isPaid ? incomeColor : mainColor : Colors.white,
          width: 1.30,
        ),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 175,
          height: 35,
          child: MaterialButton(
            color: Colors.grey[100],
        
            onPressed: () {
              if (widget.isAdding != isAdd) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => AddBill(date: widget.date, bills: widget.bills, isAdding: isAdd,)));
              }
            },
            minWidth: 175,
            child: Text(
              label,
            ),
          ),
        ),
      )
    );
  }

  Widget _buildPaidSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Paid',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        Switch(
          value: _isPaid, 
          onChanged: (value) {
            setState(() {
              _isPaid = value;
            });
          },
          activeColor: incomeColor,
        )
      ],
    );
  }

   Widget _buildSaveButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        color: _isPaid ? incomeColor : mainColor,
      
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            String name = nameController.text;
            if (name.isNotEmpty) {
              name = name[0].toUpperCase() + name.substring(1);
            }
            
                  Bill added = Bill(
              name: name, 
              amount: double.parse(amountController.text), 
              due: Timestamp.fromDate(widget.date), 
              isPaid: _isPaid,
            );
            widget.bills.add(added);
            Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => SelectBills(bills: widget.bills,)),
                            (route) => false);
          }
        },
        minWidth: 200,
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
          ),
          ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        color: Colors.grey[100],
        onPressed: () {
          Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SelectBills(bills: widget.bills,)),
                          (route) => false);
        },
        minWidth: 100,
        child: const Text('Cancel'),
      ),
    );
  }
}