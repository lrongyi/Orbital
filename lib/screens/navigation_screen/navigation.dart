import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ss/screens/authentication_screens/log_in.dart';
import 'package:ss/screens/navigation_screen/adding_entry.dart';
import 'package:ss/screens/main_screens/home_screens/home.dart';
import 'package:ss/screens/main_screens/expenses_screens/expenses.dart';
import 'package:ss/screens/main_screens/budgeting_screens/budgeting.dart';
import 'package:ss/screens/main_screens/settings_screeens/settings.dart';
import 'package:ss/screens/navigation_screen/edit_profile.dart';
import 'package:ss/services/auth.dart';
import 'package:ss/services/user_methods.dart';
import 'package:ss/shared/main_screens_deco.dart';

class Navigation extends StatefulWidget {
  final int? state;
  Navigation({Key? key, this.state}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  final currentUser = AuthMethods().getCurrentUser();
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.state ?? 0;
  }

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
      //set to false to prevent FAB from moving
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: false,
      drawer: Drawer(
        width: 250,
        backgroundColor: mainColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            // Drawer
            UserAccountsDrawerHeader(
              
              // username
              accountName: FutureBuilder<String>(
                future: UserMethods().getUserNameAsync(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Display error message if any
                  } else {
                    return Text(snapshot.data ?? ''); // Display the user name
                  }
                },
              ),

              // email
              accountEmail: FutureBuilder<String>(
                future: UserMethods().getEmailAsync(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}'); // Display error message if any
                  } else {
                    return Text(snapshot.data ?? ''); // Display the user email
                  }
                },
              ),

              // profile pic
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: mainColor,
                )
              ),
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),

            // Options within drawer 
            
            // Edit profile
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

            // Home
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

            // Expenses
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

            // Budget
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

            // Settings
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

            // Signout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                // Handle logout
                await AuthMethods().signOut(context);
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LogIn()), (route) => false);
              },
            ),
          ],
        ),
      ),

      // AppBar
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

      // Bottom Navigation Bar
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

      // Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _selectedIndex != 3
      ? FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddingEntry(isExpense: true,)),
            );
          },
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 3,
              color: Color.fromARGB(255, 88, 33, 33),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            CupertinoIcons.add,
            color: Color.fromARGB(255, 88, 33, 33),
          ),
        )
      : null,
    );
  }

  // helper method used to make the bottom nav bar items
  // if you want to use this method and add a new item,
  // take note to also change the screens List
  Widget _buildBottomNavigationBarItem(
      {required IconData icon, required String label, required int index}) {
    return MaterialButton(
      onPressed: () => _onTapped(index),
      // minWidth: 40,
      padding: index == 2 
      ? const EdgeInsets.only(left: 10) // to move budgeting icon away from the FAB
      : index == 1 
      ? const EdgeInsets.only(right: 5) // to move the expenses icon away from the FAB
      : EdgeInsets.zero, 
      // to hide the touch indication
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
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
