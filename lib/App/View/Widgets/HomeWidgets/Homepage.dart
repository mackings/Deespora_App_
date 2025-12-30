import 'package:dspora/App/View/Auth/View/Signin.dart';
import 'package:dspora/App/View/Auth/View/signup.dart';
import 'package:dspora/App/View/Interests/Views/home.dart';
import 'package:dspora/App/View/Notifications/View/Nothome.dart';
import 'package:dspora/App/View/Profile/View/profile.dart';
import 'package:dspora/App/dashboard.dart';
import 'package:dspora/App/View/Widgets/HomeWidgets/GuestSignupAlert.dart';
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

  void _handleNavTap(int index) {
    // For guests, show dialog when trying to access Interests (1) or Notifications (2)
    if (_isGuest && (index == 1 || index == 2)) {
      _showGuestSignupDialog();
      return;
    }

    setState(() {
      selectedIndex = index;
    });
  }

  void _showGuestSignupDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GuestSignupDialog(
          title: 'Account Required',
          onCreateAccount: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUp()),
            );
          },
          onLogin: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignIn()),
            );
          },
          onClose: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // All users see all 4 navigation items
    final items = [
      BottomNavItem(
        label: 'Home',
        iconAsset: 'assets/svg/homeicon.svg',
        onTap: () => _handleNavTap(0),
      ),
      BottomNavItem(
        label: 'My Interests',
        iconAsset: 'assets/svg/interests.svg',
        onTap: () => _handleNavTap(1),
      ),
      BottomNavItem(
        label: 'Notifications',
        iconAsset: 'assets/svg/notifications.svg',
        onTap: () => _handleNavTap(2),
      ),
      BottomNavItem(
        label: 'Profile',
        iconAsset: 'assets/svg/profile.svg',
        onTap: () => _handleNavTap(3),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: _allPages[selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedIndex,
        items: items,
      ),
    );
  }
}
