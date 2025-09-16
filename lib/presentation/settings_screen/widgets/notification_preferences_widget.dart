import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationPreferencesWidget extends StatefulWidget {
  const NotificationPreferencesWidget({super.key});

  @override
  State<NotificationPreferencesWidget> createState() =>
      _NotificationPreferencesWidgetState();
}

class _NotificationPreferencesWidgetState
    extends State<NotificationPreferencesWidget> {
  bool _hrUpdates = true;
  bool _attendanceReminders = true;
  bool _leaveApprovals = true;
  bool _generalNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hrUpdates = prefs.getBool('notification_hr_updates') ?? true;
      _attendanceReminders =
          prefs.getBool('notification_attendance_reminders') ?? true;
      _leaveApprovals = prefs.getBool('notification_leave_approvals') ?? true;
      _generalNotifications = prefs.getBool('notification_general') ?? false;
    });
  }

  Future<void> _saveNotificationPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _handleNotificationToggle(String type, bool value) async {
    setState(() {
      switch (type) {
        case 'hr_updates':
          _hrUpdates = value;
          break;
        case 'attendance_reminders':
          _attendanceReminders = value;
          break;
        case 'leave_approvals':
          _leaveApprovals = value;
          break;
        case 'general':
          _generalNotifications = value;
          break;
      }
    });

    await _saveNotificationPreference('notification_$type', value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification preferences updated'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Preferences',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildNotificationToggle(
              title: 'HR Updates',
              subtitle: 'Company announcements and policy updates',
              icon: 'business',
              value: _hrUpdates,
              onChanged: (value) =>
                  _handleNotificationToggle('hr_updates', value),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildNotificationToggle(
              title: 'Attendance Reminders',
              subtitle: 'Daily check-in and check-out reminders',
              icon: 'schedule',
              value: _attendanceReminders,
              onChanged: (value) =>
                  _handleNotificationToggle('attendance_reminders', value),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildNotificationToggle(
              title: 'Leave Approvals',
              subtitle: 'Leave request status and approvals',
              icon: 'event_available',
              value: _leaveApprovals,
              onChanged: (value) =>
                  _handleNotificationToggle('leave_approvals', value),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildNotificationToggle(
              title: 'General Notifications',
              subtitle: 'App updates and general information',
              icon: 'notifications',
              value: _generalNotifications,
              onChanged: (value) => _handleNotificationToggle('general', value),
              isDark: isDark,
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.warningLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'You can manage notification permissions in your device settings',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.warningLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      decoration: BoxDecoration(
        color: value
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: value
                  ? AppTheme.lightTheme.colorScheme.primary
                  : (isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight),
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppTheme.textHighEmphasisDark
                        : AppTheme.textHighEmphasisLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textMediumEmphasisDark
                        : AppTheme.textMediumEmphasisLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            activeTrackColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.5),
            inactiveThumbColor: isDark
                ? AppTheme.textMediumEmphasisDark
                : AppTheme.textMediumEmphasisLight,
            inactiveTrackColor: (isDark
                    ? AppTheme.textMediumEmphasisDark
                    : AppTheme.textMediumEmphasisLight)
                .withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
