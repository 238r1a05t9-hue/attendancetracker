import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TodayAttendanceCard extends StatelessWidget {
  final Map<String, dynamic> attendanceData;

  const TodayAttendanceCard({
    super.key,
    required this.attendanceData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final loginTime = attendanceData['loginTime'] as String?;
    final logoutTime = attendanceData['logoutTime'] as String?;
    final hoursWorked = attendanceData['hoursWorked'] as String?;
    final status = attendanceData['status'] as String?;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Attendance",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: status == 'Present'
                      ? theme.colorScheme.tertiary.withValues(alpha: 0.1)
                      : theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status ?? 'Absent',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: status == 'Present'
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeCard(
                  context,
                  'Login Time',
                  loginTime ?? '--:--',
                  CustomIconWidget(
                    iconName: 'login',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTimeCard(
                  context,
                  'Logout Time',
                  logoutTime ?? '--:--',
                  CustomIconWidget(
                    iconName: 'logout',
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Hours Worked',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  hoursWorked ?? '0h 0m',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(
      BuildContext context, String label, String time, Widget icon) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 1.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            time,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
