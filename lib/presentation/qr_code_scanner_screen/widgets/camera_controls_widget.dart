import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CameraControlsWidget extends StatelessWidget {
  final bool isFlashOn;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onClose;
  final bool isOnline;

  const CameraControlsWidget({
    super.key,
    this.isFlashOn = false,
    this.onFlashToggle,
    this.onClose,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Top controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Connection status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Close button
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onClose,
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    tooltip: 'Close Scanner',
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Bottom flash control (only show on mobile)
            if (!kIsWeb)
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: onFlashToggle,
                  backgroundColor: isFlashOn
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  foregroundColor: isFlashOn
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  elevation: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      key: ValueKey(isFlashOn),
                      iconName: isFlashOn ? 'flash_on' : 'flash_off',
                      color: isFlashOn
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      size: 28,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
