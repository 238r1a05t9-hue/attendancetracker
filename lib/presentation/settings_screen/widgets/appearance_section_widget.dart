import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AppearanceSectionWidget extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode currentTheme;

  const AppearanceSectionWidget({
    super.key,
    required this.onThemeChanged,
    required this.currentTheme,
  });

  @override
  State<AppearanceSectionWidget> createState() =>
      _AppearanceSectionWidgetState();
}

class _AppearanceSectionWidgetState extends State<AppearanceSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveThemePreference(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString = theme == ThemeMode.dark
        ? 'dark'
        : theme == ThemeMode.light
            ? 'light'
            : 'system';
    await prefs.setString('theme_mode', themeString);
  }

  void _handleThemeChange(ThemeMode theme) async {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    await _saveThemePreference(theme);
    widget.onThemeChanged(theme);
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
              'Appearance',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            _buildThemeOption(
              title: 'Light Theme',
              subtitle: 'Use light theme',
              icon: 'light_mode',
              isSelected: widget.currentTheme == ThemeMode.light,
              onTap: () => _handleThemeChange(ThemeMode.light),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildThemeOption(
              title: 'Dark Theme',
              subtitle: 'Use dark theme',
              icon: 'dark_mode',
              isSelected: widget.currentTheme == ThemeMode.dark,
              onTap: () => _handleThemeChange(ThemeMode.dark),
              isDark: isDark,
            ),
            SizedBox(height: 1.h),
            _buildThemeOption(
              title: 'System Theme',
              subtitle: 'Follow system settings',
              icon: 'settings_brightness',
              isSelected: widget.currentTheme == ThemeMode.system,
              onTap: () => _handleThemeChange(ThemeMode.system),
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
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Theme changes apply instantly with smooth transitions',
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
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected && _animationController.isAnimating
              ? _scaleAnimation.value
              : 1.0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 3.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : (isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.surfaceLight),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: icon,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.onPrimary
                          : AppTheme.lightTheme.colorScheme.primary,
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
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppTheme.textHighEmphasisDark
                                : AppTheme.textHighEmphasisLight,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          subtitle,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppTheme.textMediumEmphasisDark
                                : AppTheme.textMediumEmphasisLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
