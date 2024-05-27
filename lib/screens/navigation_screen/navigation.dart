import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/navigation_screen/adding_expense.dart';
import 'package:ss/screens/main_screens/home_screens/home.dart';
import 'package:ss/screens/main_screens/expenses_screens/expenses.dart';
import 'package:ss/screens/main_screens/budgeting_screens/budgeting.dart';
import 'package:ss/screens/main_screens/settings_screeens/settings.dart';
import 'package:ss/screens/navigation_screen/edit_profile.dart';
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
  final appBarTitles = ['Home', 'Expenses', 'Budgeting', 'Settings'];

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
              accountName: const Text('Username'),
              accountEmail: const Text('user@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
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
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
              // TODO: Edit Profile
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile()));
              },
            ),
            const Divider(color: Colors.white),
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
              leading: const Icon(Icons.graphic_eq, color: Colors.white),
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
                // Handle logout
                AuthMethods().signOut();
              },
            ),
          ],
        ),
      ),
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
                )),
          ),
        ),
        centerTitle: true,
        title: Text(
          appBarTitles[_selectedIndex],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: mainColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBottomNavigationBarItem(
                icon: CupertinoIcons.home, label: 'Home', index: 0),
            _buildBottomNavigationBarItem(
                icon: CupertinoIcons.graph_square, label: 'Expenses', index: 1),
            const Spacer(), // The dummy child for the notch
            _buildBottomNavigationBarItem(
                icon: Icons.money, label: 'Budgeting', index: 2),
            _buildBottomNavigationBarItem(
                icon: CupertinoIcons.settings, label: 'Settings', index: 3),
          ],
        ),
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
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 3,
            color: Colors.brown,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Icon(
          CupertinoIcons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  // helper method used to make the bottom nav bar items
  // if you want to use this method and add a new item,
  // take note to also change the screens List
  Widget _buildBottomNavigationBarItem(
      {required IconData icon, required String label, required int index}) {
    return MaterialButton(
      onPressed: () => _onTapped(index),
      minWidth: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.amber : Colors.white,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.amber : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
