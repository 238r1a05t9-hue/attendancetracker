import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class AboutSectionWidget extends StatelessWidget {
  const AboutSectionWidget({super.key});

  void _openUrl(String url) {
    if (kIsWeb) {
      html.window.open(url, '_blank');
    } else {
      // For mobile, you would typically use url_launcher package
      // Since it's not in our approved packages, we'll show a dialog
      // In a real app, you would use: launch(url);
    }
  }

  void _showUrlDialog(BuildContext context, String title, String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please visit the following URL in your browser:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
              child: SelectableText(
                url,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (kIsWeb)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _openUrl(url);
              },
              child: const Text('Open Link'),
            ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About AttendanceTracker',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'business',
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AttendanceTracker',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Version 1.0.0',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Enterprise Flutter mobile application for employee attendance management and HR operations.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            _buildInfoRow('Build Date', '2025-09-16'),
            _buildInfoRow('Platform', kIsWeb ? 'Web' : 'Mobile'),
            _buildInfoRow('Framework', 'Flutter 3.16.0'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Your data is encrypted and secure',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '$label:',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
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
              'About',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildAboutOption(
              title: 'App Version',
              subtitle: 'Version 1.0.0 (Build 1)',
              icon: 'info',
              onTap: () => _showAppInfoDialog(context),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildAboutOption(
              title: 'Privacy Policy',
              subtitle: 'How we handle your data',
              icon: 'privacy_tip',
              onTap: () => kIsWeb
                  ? _openUrl('https://example.com/privacy-policy')
                  : _showUrlDialog(context, 'Privacy Policy',
                      'https://example.com/privacy-policy'),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildAboutOption(
              title: 'Terms of Service',
              subtitle: 'Terms and conditions',
              icon: 'description',
              onTap: () => kIsWeb
                  ? _openUrl('https://example.com/terms-of-service')
                  : _showUrlDialog(context, 'Terms of Service',
                      'https://example.com/terms-of-service'),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildAboutOption(
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              icon: 'help',
              onTap: () => kIsWeb
                  ? _openUrl('https://example.com/support')
                  : _showUrlDialog(
                      context, 'Help & Support', 'https://example.com/support'),
              isDark: isDark,
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'business',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'AttendanceTracker',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Enterprise attendance management solution built with Flutter',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutOption({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
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
            CustomIconWidget(
              iconName: 'chevron_right',
              color: isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
