import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ScannerOverlayWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback? onManualEntry;

  const ScannerOverlayWidget({
    super.key,
    this.isScanning = false,
    this.onManualEntry,
  });

  @override
  State<ScannerOverlayWidget> createState() => _ScannerOverlayWidgetState();
}

class _ScannerOverlayWidgetState extends State<ScannerOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isScanning) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ScannerOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !oldWidget.isScanning) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isScanning && oldWidget.isScanning) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Dark overlay with transparent center
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.6),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Scanning frame
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isScanning ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          // Corner indicators
                          _buildCornerIndicator(
                            alignment: Alignment.topLeft,
                            theme: theme,
                          ),
                          _buildCornerIndicator(
                            alignment: Alignment.topRight,
                            theme: theme,
                          ),
                          _buildCornerIndicator(
                            alignment: Alignment.bottomLeft,
                            theme: theme,
                          ),
                          _buildCornerIndicator(
                            alignment: Alignment.bottomRight,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Transparent center for camera view
              Container(
                width: 70.w - 6,
                height: 70.w - 6,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ],
          ),
        ),

        // Top instruction section
        Positioned(
          top: 15.h,
          left: 5.w,
          right: 5.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Scan QR Code for Attendance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Position the QR code within the frame',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateTime.now().toString().substring(11, 16),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom controls section
        Positioned(
          bottom: 15.h,
          left: 5.w,
          right: 5.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Having trouble scanning?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 1.h),
                OutlinedButton.icon(
                  onPressed: widget.onManualEntry,
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Manual Entry',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scanning status indicator
        if (widget.isScanning)
          Positioned(
            bottom: 8.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Scanning...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCornerIndicator({
    required Alignment alignment,
    required ThemeData theme,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
