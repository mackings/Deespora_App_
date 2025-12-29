import 'package:dspora/App/View/Auth/View/onboarding2.dart';
import 'package:dspora/App/View/Profile/Api/ProfileService.dart';
import 'package:dspora/App/View/Profile/Widgets/profileWidgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileApi _profileApi = ProfileApi();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isGuest = false;
  String _fullName = "";
  String _phoneDisplay = "";

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
    _loadProfileData();
  }

  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');

    setState(() {
      _isGuest = userName == null || userName.isEmpty || userName == 'Guest';
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final result = await _profileApi.getProfile();

      if (result['success'] == true && result['data'] != null) {
        final user = result['data']['user'];
        
        setState(() {
          _firstNameController.text = user['firstName'] ?? '';
          _lastNameController.text = user['lastName'] ?? '';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['phoneNumber'] ?? '';
          
          _fullName = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
          _phoneDisplay = user['phoneNumber'] ?? '';
          _isLoading = false;
        });
      } else {
        // Load from SharedPreferences as fallback
        await _loadFromSharedPreferences();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to load profile'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      await _loadFromSharedPreferences();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _firstNameController.text = prefs.getString('userName') ?? '';
        _emailController.text = prefs.getString('userEmail') ?? '';
        _phoneController.text = prefs.getString('userPhone') ?? '';
        
        _fullName = prefs.getString('userName') ?? 'User';
        _phoneDisplay = prefs.getString('userPhone') ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleUpdateProfile() async {
    final result = await _profileApi.updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      // Update display
      setState(() {
        _fullName = '${_firstNameController.text} ${_lastNameController.text}'.trim();
        _phoneDisplay = _phoneController.text;
      });

      Navigator.pop(context); // Close modal
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleDeleteAccount(String password) async {
    final result = await _profileApi.deleteAccount(password: password);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context); // Close dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login or splash screen
      // Navigator.of(context).pushReplacementNamed('/login');
    } else {
      Navigator.pop(context); // Close dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to delete account'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

void _showDeleteDialog() {
  if (_isGuest) {
    _showGuestRestrictionDialog();
    return;
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DeleteAccountBottomSheet(
      onDeleteConfirmed: _handleDeleteAccount,
    ),
  );
}

  void _showEditProfileModal() {
    if (_isGuest) {
      _showGuestRestrictionDialog();
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModal(
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        emailController: _emailController,
        phoneController: _phoneController,
        onUpdate: _handleUpdateProfile,
      ),
    );
  }

  void _showGuestRestrictionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Required'),
        content: const Text(
          'This feature is only available for registered users. Please create an account or sign in to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Second_Onboarding()),
                (route) => false,
              );
            },
            child: const Text('Sign Up / Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete_outline, color: Colors.black),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: "Account Settings",
                        subtitle: "Manage your app preferences, privacy, and\nnotifications.",
                      ),
                      const SizedBox(height: 24),
                      
                      // Profile Card
                      ProfileCard(
                        name: _fullName,
                        phone: _phoneDisplay,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Menu Items
                      SettingsMenuItem(
                        icon: Icons.person_outline,
                        title: "Change profile information",
                        onTap: _showEditProfileModal,
                      ),
                      const SizedBox(height: 12),
SettingsMenuItem(
  icon: Icons.settings_outlined,
  title: "Terms of service",
  onTap: () async {
    final uri = Uri.parse('https://deespora.com/termsofservice');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  },
),
const SizedBox(height: 12),
SettingsMenuItem(
  icon: Icons.description_outlined,
  title: "Privacy policy",
  onTap: () async {
    final uri = Uri.parse('https://deespora.com/privacypolicy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  },
),

const SizedBox(height: 50),
SettingsMenuItem(
  icon: Icons.exit_to_app_sharp,
  title: "Log out",
  onTap: () {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Second_Onboarding()),
      (route) => false,
    );
  },
),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}