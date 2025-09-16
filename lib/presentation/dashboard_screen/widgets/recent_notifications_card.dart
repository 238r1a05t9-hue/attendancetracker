import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentNotificationsCard extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;

  const RecentNotificationsCard({
    super.key,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                'Recent Notifications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (_getUnreadCount() > 0)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_getUnreadCount()}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          notifications.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: notifications
                      .take(3)
                      .map((notification) =>
                          _buildNotificationItem(context, notification))
                      .toList(),
                ),
          if (notifications.length > 3) ...[
            SizedBox(height: 1.h),
            GestureDetector(
              onTap: () {
                // Navigate to notifications screen
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'View All Notifications',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, Map<String, dynamic> notification) {
    final theme = Theme.of(context);
    final isUnread = notification['isUnread'] as bool? ?? false;
    final title = notification['title'] as String? ?? '';
    final message = notification['message'] as String? ?? '';
    final timestamp = notification['timestamp'] as String? ?? '';
    final type = notification['type'] as String? ?? 'info';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isUnread
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? theme.colorScheme.primary.withValues(alpha: 0.2)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _getNotificationColor(type, theme).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getNotificationIcon(type),
              color: _getNotificationColor(type, theme),
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  timestamp,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'notifications_none',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No notifications yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'You\'ll see important updates here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getUnreadCount() {
    return notifications
        .where((notification) => notification['isUnread'] as bool? ?? false)
        .length;
  }

  String _getNotificationIcon(String type) {
    switch (type) {
      case 'leave':
        return 'event_note';
      case 'attendance':
        return 'schedule';
      case 'approval':
        return 'check_circle';
      case 'warning':
        return 'warning';
      case 'info':
      default:
        return 'info';
    }
  }

  Color _getNotificationColor(String type, ThemeData theme) {
    switch (type) {
      case 'leave':
        return theme.colorScheme.secondary;
      case 'attendance':
        return theme.colorScheme.primary;
      case 'approval':
        return theme.colorScheme.tertiary;
      case 'warning':
        return theme.colorScheme.tertiaryContainer;
      case 'info':
      default:
        return theme.colorScheme.primary;
    }
  }
}
