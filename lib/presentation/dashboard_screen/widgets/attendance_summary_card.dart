import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final Map<String, dynamic> summaryData;

  const AttendanceSummaryCard({
    super.key,
    required this.summaryData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final presentDays = summaryData['presentDays'] as int? ?? 0;
    final absentDays = summaryData['absentDays'] as int? ?? 0;
    final totalDays = summaryData['totalDays'] as int? ?? 0;
    final attendancePercentage =
        summaryData['attendancePercentage'] as double? ?? 0.0;

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
          Text(
            'This Month Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Present Days',
                  presentDays.toString(),
                  theme.colorScheme.tertiary,
                  'check_circle',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Absent Days',
                  absentDays.toString(),
                  theme.colorScheme.error,
                  'cancel',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Days',
                  totalDays.toString(),
                  theme.colorScheme.primary,
                  'calendar_month',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Attendance',
                  '${attendancePercentage.toStringAsFixed(1)}%',
                  _getAttendanceColor(attendancePercentage, theme),
                  'trending_up',
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildAttendanceProgress(context, attendancePercentage),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    String iconName,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceProgress(BuildContext context, double percentage) {
    final theme = Theme.of(context);
    final progressColor = _getAttendanceColor(percentage, theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendance Progress',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          _getAttendanceMessage(percentage),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Color _getAttendanceColor(double percentage, ThemeData theme) {
    if (percentage >= 90) {
      return theme.colorScheme.tertiary; // Green for excellent
    } else if (percentage >= 75) {
      return theme.colorScheme.primary; // Teal for good
    } else if (percentage >= 60) {
      return theme.colorScheme.tertiaryContainer; // Orange for warning
    } else {
      return theme.colorScheme.error; // Red for poor
    }
  }

  String _getAttendanceMessage(double percentage) {
    if (percentage >= 90) {
      return 'Excellent attendance! Keep it up.';
    } else if (percentage >= 75) {
      return 'Good attendance record.';
    } else if (percentage >= 60) {
      return 'Attendance needs improvement.';
    } else {
      return 'Poor attendance. Please improve.';
    }
  }
}
