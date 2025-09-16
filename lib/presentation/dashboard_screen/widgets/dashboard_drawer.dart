import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DashboardDrawer extends StatelessWidget {
  final String currentRoute;
  final Map<String, dynamic> userProfile;

  const DashboardDrawer({
    super.key,
    required this.currentRoute,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    'Dashboard',
                    'dashboard',
                    '/dashboard-screen',
                  ),
                  _buildDrawerItem(
                    context,
                    'QR Scanner',
                    'qr_code_scanner',
                    '/qr-code-scanner-screen',
                  ),
                  _buildDrawerItem(
                    context,
                    'Reports',
                    'assessment',
                    '/attendance-reports-screen',
                  ),
                  _buildDrawerItem(
                    context,
                    'Leave Requests',
                    'event_note',
                    '/leave-request-screen',
                  ),
                  Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    height: 1,
                    indent: 4.w,
                    endIndent: 4.w,
                  ),
                  _buildDrawerItem(
                    context,
                    'Settings',
                    'settings',
                    '/settings-screen',
                  ),
                ],
              ),
            ),
            _buildDrawerFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final theme = Theme.of(context);
    final userName = userProfile['name'] as String? ?? 'John Doe';
    final userEmail = userProfile['email'] as String? ?? 'john.doe@company.com';
    final userAvatar = userProfile['avatar'] as String? ?? '';
    final employeeId = userProfile['employeeId'] as String? ?? 'EMP001';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.onPrimary,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: userAvatar.isNotEmpty
                      ? CustomImageWidget(
                          imageUrl: userAvatar,
                          width: 16.w,
                          height: 16.w,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.2),
                          child: CustomIconWidget(
                            iconName: 'person',
                            color: theme.colorScheme.onPrimary,
                            size: 32,
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
                      userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'ID: $employeeId',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      userEmail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    String iconName,
    String route,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentRoute == route;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: iconName,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: isSelected
            ? CustomIconWidget(
                iconName: 'circle',
                color: theme.colorScheme.primary,
                size: 8,
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          if (currentRoute != route) {
            Navigator.pushNamed(context, route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CustomIconWidget(
              iconName: 'logout',
              color: theme.colorScheme.error,
              size: 24,
            ),
            title: Text(
              'Logout',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'AttendanceTracker v1.0.0',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login-screen',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: Text(
                'Logout',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
