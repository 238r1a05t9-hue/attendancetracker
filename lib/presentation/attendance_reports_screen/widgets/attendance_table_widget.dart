import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AttendanceTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> attendanceData;
  final ScrollController scrollController;

  const AttendanceTableWidget({
    super.key,
    required this.attendanceData,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (attendanceData.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTableHeader(theme),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: EdgeInsets.zero,
              itemCount: attendanceData.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final record = attendanceData[index];
                return _buildTableRow(theme, record, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Date',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Login',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Logout',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Hours',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Status',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
      ThemeData theme, Map<String, dynamic> record, int index) {
    final status = record['status'] as String;
    final statusColor = _getStatusColor(status, theme);

    return InkWell(
      onLongPress: () => _showRowDetails(record),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                record['date'] as String,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                record['loginTime'] as String? ?? '--',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: record['loginTime'] != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                record['logoutTime'] as String? ?? '--',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: record['logoutTime'] != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                record['totalHours'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'assessment',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 64,
          ),
          SizedBox(height: 3.h),
          Text(
            'No Attendance Data',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'No attendance records found for the selected date range. Try selecting a different period.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'present':
        return theme.colorScheme.primary;
      case 'absent':
        return theme.colorScheme.error;
      case 'partial':
        return const Color(0xFFFF9800);
      default:
        return theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }

  void _showRowDetails(Map<String, dynamic> record) {
    // Context menu implementation would go here
    // For now, this is a placeholder for the long-press functionality
  }
}
