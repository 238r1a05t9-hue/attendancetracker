import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LeaveBalanceCard extends StatelessWidget {
  final String leaveType;
  final int availableDays;
  final int totalDays;
  final Color accentColor;

  const LeaveBalanceCard({
    super.key,
    required this.leaveType,
    required this.availableDays,
    required this.totalDays,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 28.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
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
            leaveType,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$availableDays',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 1.w),
              Padding(
                padding: EdgeInsets.only(bottom: 0.5.h),
                child: Text(
                  '/$totalDays',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'days left',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
