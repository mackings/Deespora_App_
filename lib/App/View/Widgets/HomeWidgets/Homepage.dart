import 'package:dspora/App/dashboard.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/NavBar.dart';
import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

    final List<Widget> pages = [
    const Dashboard(),
    const Dashboard(),              
    
  ];

  @override
  Widget build(BuildContext context) {
    final items = [
      BottomNavItem(
        label: 'Home',
        iconAsset: 'assets/svg/homeicon.svg',
        onTap: () => setState(() => selectedIndex = 0),
      ),
      BottomNavItem(
        label: 'My Interests',
        iconAsset: 'assets/svg/interests.svg',
        onTap: () => setState(() => selectedIndex = 1),
      ),
      BottomNavItem(
        label: 'Notifications',
        iconAsset: 'assets/svg/notifications.svg',
        onTap: () => setState(() => selectedIndex = 2),
      ),
      BottomNavItem(
        label: 'Profile',
        iconAsset: 'assets/svg/profile.svg',
        onTap: () => setState(() => selectedIndex = 3),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body:pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        items: items,
      ),
    );
  }
}
