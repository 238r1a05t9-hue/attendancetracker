import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/attendance_summary_card.dart';
import './widgets/dashboard_drawer.dart';
import './widgets/quick_action_card.dart';
import './widgets/recent_notifications_card.dart';
import './widgets/today_attendance_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  DateTime _lastSyncTime = DateTime.now();

  // Mock data
  final Map<String, dynamic> _userProfile = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@techcorp.com",
    "employeeId": "EMP2024001",
    "avatar":
        "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
    "department": "Software Development",
    "position": "Senior Developer"
  };

  final Map<String, dynamic> _todayAttendance = {
    "loginTime": "09:15 AM",
    "logoutTime": null,
    "hoursWorked": "6h 45m",
    "status": "Present",
    "location": "Office - Floor 3"
  };

  final List<Map<String, dynamic>> _notifications = [
    {
      "id": 1,
      "title": "Leave Request Approved",
      "message": "Your leave request for Dec 25-26 has been approved by HR.",
      "timestamp": "2 hours ago",
      "type": "approval",
      "isUnread": true
    },
    {
      "id": 2,
      "title": "Attendance Reminder",
      "message": "Don't forget to check out before leaving the office today.",
      "timestamp": "4 hours ago",
      "type": "attendance",
      "isUnread": true
    },
    {
      "id": 3,
      "title": "Monthly Report Available",
      "message": "Your November attendance report is ready for download.",
      "timestamp": "1 day ago",
      "type": "info",
      "isUnread": false
    },
    {
      "id": 4,
      "title": "System Maintenance",
      "message": "QR scanner will be offline for maintenance on Sunday 2-4 AM.",
      "timestamp": "2 days ago",
      "type": "warning",
      "isUnread": false
    }
  ];

  final Map<String, dynamic> _attendanceSummary = {
    "presentDays": 18,
    "absentDays": 2,
    "totalDays": 20,
    "attendancePercentage": 90.0,
    "averageHours": "8h 15m",
    "overtimeHours": "12h 30m"
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
      _lastSyncTime = DateTime.now();
    });
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dashboard refreshed successfully',
            style: Theme.of(context).snackBarTheme.contentTextStyle,
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentDate = DateTime.now();
    final formattedDate =
        "${_getMonthName(currentDate.month)} ${currentDate.day}, ${currentDate.year}";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      drawer: DashboardDrawer(
        currentRoute: '/dashboard-screen',
        userProfile: _userProfile,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        color: theme.colorScheme.primary,
        child: _isLoading
            ? _buildLoadingState(context)
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, formattedDate),
                    TodayAttendanceCard(attendanceData: _todayAttendance),
                    _buildQuickActions(context),
                    RecentNotificationsCard(notifications: _notifications),
                    AttendanceSummaryCard(summaryData: _attendanceSummary),
                    _buildLastSyncInfo(context),
                    SizedBox(height: 10.h), // Space for FAB
                  ],
                ),
              ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: 0,
      leading: IconButton(
        icon: CustomIconWidget(
          iconName: 'menu',
          color:
              theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface,
          size: 24,
        ),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Text(
        'Dashboard',
        style: theme.appBarTheme.titleTextStyle,
      ),
      actions: [
        IconButton(
          icon: CustomIconWidget(
            iconName: 'notifications_outlined',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            // Navigate to notifications
          },
        ),
        IconButton(
          icon: CustomIconWidget(
            iconName: 'refresh',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            _refreshIndicatorKey.currentState?.show();
          },
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String formattedDate) {
    final theme = Theme.of(context);
    final userName = _userProfile['name'] as String? ?? 'User';
    final userAvatar = _userProfile['avatar'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: userAvatar.isNotEmpty
                  ? CustomImageWidget(
                      imageUrl: userAvatar,
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: CustomIconWidget(
                        iconName: 'person',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 2.h),
          QuickActionCard(
            title: 'View Reports',
            subtitle: 'Check your attendance history and analytics',
            iconName: 'assessment',
            onTap: () {
              Navigator.pushNamed(context, '/attendance-reports-screen');
            },
          ),
          SizedBox(height: 1.h),
          QuickActionCard(
            title: 'Request Leave',
            subtitle: 'Submit a new leave request for approval',
            iconName: 'event_note',
            iconColor: Theme.of(context).colorScheme.secondary,
            onTap: () {
              Navigator.pushNamed(context, '/leave-request-screen');
            },
          ),
          SizedBox(height: 1.h),
          QuickActionCard(
            title: 'Settings',
            subtitle: 'Manage your profile and app preferences',
            iconName: 'settings',
            iconColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            onTap: () {
              Navigator.pushNamed(context, '/settings-screen');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/qr-code-scanner-screen');
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: CustomIconWidget(
          iconName: 'qr_code_scanner',
          color: theme.colorScheme.onPrimary,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildLastSyncInfo(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(_lastSyncTime);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'sync',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            'Last synced $timeAgo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: 80.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Loading dashboard...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
