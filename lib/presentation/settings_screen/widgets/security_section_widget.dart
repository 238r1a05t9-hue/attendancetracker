import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SecuritySectionWidget extends StatefulWidget {
  const SecuritySectionWidget({super.key});

  @override
  State<SecuritySectionWidget> createState() => _SecuritySectionWidgetState();
}

class _SecuritySectionWidgetState extends State<SecuritySectionWidget> {
  bool _biometricEnabled = false;
  String _sessionTimeout = '15 minutes';
  final List<String> _timeoutOptions = [
    '5 minutes',
    '15 minutes',
    '30 minutes',
    '1 hour',
    'Never'
  ];

  @override
  void initState() {
    super.initState();
    _loadSecurityPreferences();
  }

  Future<void> _loadSecurityPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _sessionTimeout = prefs.getString('session_timeout') ?? '15 minutes';
    });
  }

  Future<void> _saveSecurityPreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _showPasswordChangeDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    String passwordStrength = '';
    Color strengthColor = Colors.grey;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          void _checkPasswordStrength(String password) {
            if (password.isEmpty) {
              passwordStrength = '';
              strengthColor = Colors.grey;
            } else if (password.length < 6) {
              passwordStrength = 'Weak';
              strengthColor = AppTheme.lightTheme.colorScheme.error;
            } else if (password.length < 8 ||
                !password.contains(RegExp(r'[0-9]'))) {
              passwordStrength = 'Medium';
              strengthColor = AppTheme.warningLight;
            } else if (password.contains(RegExp(r'[A-Z]')) &&
                password.contains(RegExp(r'[a-z]')) &&
                password.contains(RegExp(r'[0-9]')) &&
                password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
              passwordStrength = 'Strong';
              strengthColor = AppTheme.successLight;
            } else {
              passwordStrength = 'Medium';
              strengthColor = AppTheme.warningLight;
            }
          }

          return AlertDialog(
            title: Text(
              'Change Password',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: CustomIconWidget(
                          iconName: obscureCurrentPassword
                              ? 'visibility'
                              : 'visibility_off',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword,
                    onChanged: (value) {
                      setDialogState(() {
                        _checkPasswordStrength(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: CustomIconWidget(
                          iconName: obscureNewPassword
                              ? 'visibility'
                              : 'visibility_off',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  if (passwordStrength.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Text(
                          'Password Strength: ',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        Text(
                          passwordStrength,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: strengthColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 2.h),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: CustomIconWidget(
                          iconName: obscureConfirmPassword
                              ? 'visibility'
                              : 'visibility_off',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 20,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (currentPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter current password')),
                    );
                    return;
                  }
                  if (newPasswordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('New passwords do not match')),
                    );
                    return;
                  }
                  if (newPasswordController.text.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Password must be at least 6 characters')),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Password changed successfully'),
                      backgroundColor: AppTheme.successLight,
                    ),
                  );
                },
                child: const Text('Change Password'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSessionTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Session Timeout',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _timeoutOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _sessionTimeout,
              onChanged: (value) {
                setState(() {
                  _sessionTimeout = value!;
                });
                _saveSecurityPreference('session_timeout', value!);
                Navigator.pop(context);
              },
              activeColor: AppTheme.lightTheme.colorScheme.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
              'Security',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSecurityOption(
              title: 'Change Password',
              subtitle: 'Update your account password',
              icon: 'lock',
              onTap: _showPasswordChangeDialog,
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildSecurityToggle(
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint or face recognition',
              icon: 'fingerprint',
              value: _biometricEnabled,
              onChanged: (value) async {
                setState(() {
                  _biometricEnabled = value;
                });
                await _saveSecurityPreference('biometric_enabled', value);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value
                          ? 'Biometric authentication enabled'
                          : 'Biometric authentication disabled'),
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  );
                }
              },
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildSecurityOption(
              title: 'Session Timeout',
              subtitle: 'Auto-logout after: $_sessionTimeout',
              icon: 'timer',
              onTap: _showSessionTimeoutDialog,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
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

  Widget _buildSecurityToggle({
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
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
