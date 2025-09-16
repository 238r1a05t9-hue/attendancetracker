import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DataSectionWidget extends StatefulWidget {
  const DataSectionWidget({super.key});

  @override
  State<DataSectionWidget> createState() => _DataSectionWidgetState();
}

class _DataSectionWidgetState extends State<DataSectionWidget> {
  String _cacheSize = '0 MB';
  String _offlineStorageUsage = '0 MB';
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _calculateStorageUsage();
  }

  Future<void> _calculateStorageUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      int totalSize = 0;
      int offlineSize = 0;

      for (String key in keys) {
        final value = prefs.get(key);
        if (value != null) {
          String valueString = value.toString();
          int size = utf8.encode(valueString).length;
          totalSize += size;

          if (key.contains('offline') ||
              key.contains('cache') ||
              key.contains('attendance')) {
            offlineSize += size;
          }
        }
      }

      setState(() {
        _cacheSize = '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB';
        _offlineStorageUsage =
            '${(offlineSize / (1024 * 1024)).toStringAsFixed(2)} MB';
      });
    } catch (e) {
      setState(() {
        _cacheSize = 'Error calculating';
        _offlineStorageUsage = 'Error calculating';
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isClearing = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) =>
              key.contains('cache') ||
              key.contains('temp') ||
              key.contains('image_cache'))
          .toList();

      for (String key in keys) {
        await prefs.remove(key);
      }

      await _calculateStorageUsage();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cache cleared successfully'),
            backgroundColor: AppTheme.successLight,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to clear cache'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Text(
          'This will clear temporary files and cached data. Your personal settings and offline attendance data will be preserved.',
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
              _clearCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showOfflineDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Offline Data Management',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Offline Storage Usage: $_offlineStorageUsage',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Offline data includes:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            _buildDataItem('• Attendance records'),
            _buildDataItem('• User profile information'),
            _buildDataItem('• App preferences'),
            _buildDataItem('• Cached images'),
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
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Data syncs automatically when online',
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

  Widget _buildDataItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        text,
        style: AppTheme.lightTheme.textTheme.bodySmall,
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
              'Data Management',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildDataOption(
              title: 'Clear Cache',
              subtitle: 'Cache size: $_cacheSize',
              icon: 'delete_sweep',
              onTap: _showClearCacheDialog,
              isDark: isDark,
              isLoading: _isClearing,
            ),
            SizedBox(height: 1.h),
            _buildDataOption(
              title: 'Offline Storage',
              subtitle: 'Storage used: $_offlineStorageUsage',
              icon: 'storage',
              onTap: _showOfflineDataDialog,
              isDark: isDark,
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_sync',
                    color: AppTheme.successLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-sync enabled',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.successLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Data syncs automatically when connected to internet',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.successLight,
                          ),
                        ),
                      ],
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

  Widget _buildDataOption({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
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
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : CustomIconWidget(
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
            if (!isLoading)
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
