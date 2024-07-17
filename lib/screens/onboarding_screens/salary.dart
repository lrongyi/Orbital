import 'package:flutter/material.dart';
import 'package:ss/screens/onboarding_screens/select_bills.dart';
import 'package:ss/services/user_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Salary extends StatefulWidget {
  const Salary({super.key});

  @override
  State<Salary> createState() => _SalaryState();
}

class _SalaryState extends State<Salary> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController salaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    'Enter your monthly salary',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            
                const SizedBox(
                  height: 50,
                ),
            
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Image.asset(
                    "assets/ss_red.png",
                  ),
                ),
            
                const SizedBox(
                  height: 50,
                ),
            
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      controller: salaryController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter salary/allowance';
                        } else if (double.tryParse(value) == null) {
                          return 'Enter a valid number';                       
                        } 

                        return null;                       
                      },
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter Salary'
                      ),
                    ),
                  ),
                ),
            
                const SizedBox(
                  height: 200,
                ),
            
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      elevation: 10.0,
                    ),
                    
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        UserMethods().updateUserSalary(UserMethods().getCurrentUserId(), double.parse(salaryController.text));

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: ((context) => SelectBills(bills: [],))),
                          (route) => false
                        );
                      }
                    }, 
            
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    )
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}
