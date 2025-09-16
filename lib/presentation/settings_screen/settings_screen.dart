import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/about_section_widget.dart';
import './widgets/appearance_section_widget.dart';
import './widgets/data_section_widget.dart';
import './widgets/notification_preferences_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/security_section_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeMode _currentTheme = ThemeMode.system;
  int _currentBottomNavIndex = 4; // Settings tab

  // Mock user profile data
  final Map<String, dynamic> _userProfile = {
    "id": 1,
    "name": "John Doe",
    "employeeId": "EMP001",
    "department": "Engineering",
    "email": "john.doe@company.com",
    "phone": "+1 (555) 123-4567",
    "profileImage":
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80",
    "joinDate": "2023-01-15",
    "position": "Senior Software Engineer",
  };

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      _currentTheme = themeString == 'dark'
          ? ThemeMode.dark
          : themeString == 'light'
              ? ThemeMode.light
              : ThemeMode.system;
    });
  }

  void _handleThemeChange(ThemeMode theme) {
    setState(() {
      _currentTheme = theme;
    });
    // In a real app, this would update the app's theme
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to ${theme.name}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _handleProfileUpdate(String imagePath) {
    setState(() {
      _userProfile['profileImage'] = imagePath;
    });
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    // Navigate to different screens based on index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard-screen');
        break;
      case 1:
        Navigator.pushNamed(context, '/qr-code-scanner-screen');
        break;
      case 2:
        Navigator.pushNamed(context, '/attendance-reports-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/leave-request-screen');
        break;
      case 4:
        // Already on settings screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: const CustomAppBar(
        title: 'Settings',
        variant: CustomAppBarVariant.standard,
        centerTitle: true,
      ),
      drawer: _buildNavigationDrawer(isDark),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 1.h),
              ProfileSectionWidget(
                userProfile: _userProfile,
                onProfileUpdate: _handleProfileUpdate,
              ),
              AppearanceSectionWidget(
                currentTheme: _currentTheme,
                onThemeChanged: _handleThemeChange,
              ),
              const NotificationPreferencesWidget(),
              const SecuritySectionWidget(),
              const DataSectionWidget(),
              const AboutSectionWidget(),
              SizedBox(height: 2.h),
              _buildLogoutSection(isDark),
              SizedBox(height: 10.h), // Extra space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        variant: CustomBottomBarVariant.standard,
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildNavigationDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 8.w,
                    backgroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                    child: CustomIconWidget(
                      iconName: 'business',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'AttendanceTracker',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _userProfile['name'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                children: [
                  _buildDrawerItem(
                    icon: 'dashboard',
                    title: 'Dashboard',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/dashboard-screen');
                    },
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    icon: 'qr_code_scanner',
                    title: 'QR Scanner',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/qr-code-scanner-screen');
                    },
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    icon: 'assessment',
                    title: 'Reports',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, '/attendance-reports-screen');
                    },
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    icon: 'event_note',
                    title: 'Leave Requests',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/leave-request-screen');
                    },
                    isDark: isDark,
                  ),
                  _buildDrawerItem(
                    icon: 'settings',
                    title: 'Settings',
                    isSelected: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required String icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: icon,
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : (isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight),
          size: 24,
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : (isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        selected: isSelected,
        selectedTileColor:
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutSection(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.error
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'logout',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logout',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Sign out of your account',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.textMediumEmphasisDark
                              : AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout() async {
    // Clear user preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_logged_in');
    await prefs.remove('user_id');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out successfully'),
          backgroundColor: AppTheme.successLight,
        ),
      );

      // Navigate to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login-screen',
        (route) => false,
      );
    }
  }
}
