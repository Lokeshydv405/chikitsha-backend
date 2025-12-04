import 'package:chikitsha_munshi/core/utils/user_prefs.dart';
import 'package:chikitsha_munshi/screens/HeathTools/HealthToolsPage.dart';
import 'package:chikitsha_munshi/screens/home/test_page.dart';
import 'package:chikitsha_munshi/screens/profile/profilePage.dart';
import 'package:flutter/material.dart';
import 'package:chikitsha_munshi/screens/home/HomePage.dart';
import 'package:chikitsha_munshi/screens/booking/BookingListPage.dart';

class MainAppPage extends StatefulWidget {
  final String userId; // ✅ take userId as input

  const MainAppPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MainAppPageState createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    print('User Id in MainAppPage is ${widget.userId}');
    _pages = [
      HomePage(),
      // BookingListPage(userId: widget.userId),
      BookingListPage(),
      HealthToolsApp(), // your health tools page
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() {
            _selectedIndex = index;
            print("Selected index: $_selectedIndex");
            print('User Id in MainAppPage is ${widget.userId}');
            print('User Id in MainAppPage is ${widget.userId}');

          }),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey.shade600,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              activeIcon: Icon(Icons.favorite),
              label: "Health Corner",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
