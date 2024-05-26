import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
import 'package:ss/screens/main_screens/budgeting_screens/budgeting.dart';
import 'package:ss/screens/main_screens/expenses_screens/expenses.dart';
import 'package:ss/screens/navigation_screen/adding_expense.dart';
import 'package:ss/screens/main_screens/home_screens/home.dart';
import 'package:ss/screens/main_screens/settings_screeens/settings.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [Home(), Expenses(), Budgeting(), Settings()];

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
            UserAccountsDrawerHeader(
              // TODO: need to change this to make it dynamic
              accountName: const Text('Username'),
              accountEmail: const Text('user@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                // TODO: need to change this as well to reflect what they put as their profile picture
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 40.0,
                    color: mainColor,
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'Home',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _onTapped(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'Expenses',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _onTapped(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.white),
              title: const Text(
                'Budgeting',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _onTapped(2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                'Settings',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _onTapped(3);
              },
            ),
            const Divider(color: Colors.white),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                AuthMethods().signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LogIn()),
                    (route) => false);
              },
            ),
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
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                )
                // child: Image.asset(
                //   'assets/ss_logo_tiny_red.png',
                //   fit: BoxFit.scaleDown,
                // ),
                ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Savings Squad',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       AuthMethods().signOut();
        //       Navigator.pushAndRemoveUntil(
        //           context,
        //           MaterialPageRoute(builder: (context) => LogIn()),
        //           (route) => false);
        //     },
        //     child: const Row(
        //       children: [
        //         Icon(IconData(0xe3b3, fontFamily: 'MaterialIcons'),
        //             color: Colors.white),
        //         // Text('Sign Out'),
        //       ],
        //     ),
        //   ),
        // ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amber,
        backgroundColor: mainColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.home,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.graph_square,
              color: Colors.white,
            ),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.money,
              color: Colors.white,
            ),
            label: 'Budgeting',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.settings,
              color: Colors.white,
            ),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddingExpense()),
          );
        },
        // shape: const CircleBorder(),
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
