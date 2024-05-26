import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
import 'package:ss/screens/main_screens/budgeting.dart';
import 'package:ss/screens/main_screens/expenses_screens/expenses.dart';
import 'package:ss/screens/main_screens/home.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 1;
  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [Expenses(), Home(), Budgeting()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: false,
      drawer: Drawer(
        backgroundColor: mainColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text(
                'Username',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text(
                'Item 1',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    (route) => false);
              },
            ),
            ListTile(
              title: const Text(
                'Item 2',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    (route) => false);
              },
            )
          ],
        ),
      ),
      // add sign out here
      appBar: AppBar(
        backgroundColor: mainColor,
        leading: Center(
            child: Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Image.asset(
              'assets/ss_logo_tiny_red.png',
              fit: BoxFit.scaleDown,
            ),
          ),
        )),
        centerTitle: true,
        title: const Text(
          'Savings Squad',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AuthMethods().signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                  (route) => false);
            },
            child: const Row(
              children: [
                Icon(IconData(0xe3b3, fontFamily: 'MaterialIcons'),
                    color: Colors.white),
                // Text('Sign Out'),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: ClipRRect(
          // borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BottomNavigationBar(
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.amber,
            backgroundColor: mainColor,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(
                  CupertinoIcons.money_dollar,
                  color: Colors.white,
                ),
                label: 'Expenses',
              ),
              BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.home,
                    color: Colors.white,
                  ),
                  label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(
                    CupertinoIcons.money_dollar,
                    color: Colors.white,
                  ),
                  label: 'Budgeting'),       
            ],
            currentIndex: _selectedIndex,
            onTap: _onTapped,
          )),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Color.fromARGB(255, 88, 33, 33),
      //   onPressed: () {},
      //   shape: const CircleBorder(),
      //   child: const Icon(CupertinoIcons.add, color: Colors.amberAccent),
      // ),
    );
  }
}
