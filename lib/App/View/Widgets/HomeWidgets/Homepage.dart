import 'package:dspora/App/View/Interests/Views/home.dart';
import 'package:dspora/App/View/Notifications/View/Nothome.dart';
import 'package:dspora/App/View/Profile/View/profile.dart';
import 'package:dspora/App/dashboard.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  bool _isGuest = false;

  final List<Widget> _allPages = [
    const Dashboard(),
    const InterestHome(),
    const Notification_home(),
    const ProfileView()
  ];

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
  }

  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');

    setState(() {
      _isGuest = userName == null || userName.isEmpty || userName == 'Guest';
    });
  }

  List<Widget> get pages {
    if (_isGuest) {
      // Only Dashboard and Profile for guests
      return [_allPages[0], _allPages[3]];
    }
    return _allPages;
  }


  @override
  Widget build(BuildContext context) {
    final items = _isGuest
        ? [
            // Guest mode: Only Home and Profile
            BottomNavItem(
              label: 'Home',
              iconAsset: 'assets/svg/homeicon.svg',
              onTap: () => setState(() => selectedIndex = 0),
            ),
            BottomNavItem(
              label: 'Profile',
              iconAsset: 'assets/svg/profile.svg',
              onTap: () => setState(() => selectedIndex = 1),
            ),
          ]
        : [
            // Registered users: All navigation items
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
      body: pages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        items: items,
      ),
    );
  }
}
