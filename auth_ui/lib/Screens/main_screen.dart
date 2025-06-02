import 'package:flutter/material.dart';
import 'meals_screen.dart';
import 'profile_screen.dart';

/// الشاشة الرئيسية مع شريط التنقل السفلي
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // قائمة الشاشات التي سيتم التنقل بينها
  final List<Widget> _screens = [
    const MealsScreen(),
    const ProfileScreen(),
  ];

  // دالة تغيير الشاشة الحالية
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const mainColor = Color(0xFF7c7be6);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'الوجبات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'الملف الشخصي',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: mainColor,
          unselectedItemColor: theme.brightness == Brightness.dark
              ? Colors.white70
              : Colors.grey[600],
          backgroundColor: theme.brightness == Brightness.dark
              ? const Color(0xFF181818)
              : Colors.white,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
