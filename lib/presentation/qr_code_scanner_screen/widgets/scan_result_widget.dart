import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ScanResultWidget extends StatefulWidget {
  final String? scannedData;
  final bool isSuccess;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const ScanResultWidget({
    super.key,
    this.scannedData,
    this.isSuccess = false,
    this.errorMessage,
    this.onRetry,
    this.onClose,
  });

  @override
  State<ScanResultWidget> createState() => _ScanResultWidgetState();
}

class _ScanResultWidgetState extends State<ScanResultWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Provide haptic feedback
    if (widget.isSuccess) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.all(5.w),
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Result icon
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: widget.isSuccess
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: widget.isSuccess ? 'check_circle' : 'error',
                        color: widget.isSuccess ? Colors.green : Colors.red,
                        size: 48,
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Title
                  Text(
                    widget.isSuccess ? 'Scan Successful!' : 'Scan Failed',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 2.h),

                  // Message or scanned data
                  if (widget.isSuccess && widget.scannedData != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Recorded',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Time: ${DateTime.now().toString().substring(11, 16)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Date: ${DateTime.now().toString().substring(0, 10)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (widget.scannedData!.isNotEmpty) ...[
                            SizedBox(height: 1.h),
                            Text(
                              'QR Data: ${widget.scannedData}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                                fontFamily: 'monospace',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                  if (!widget.isSuccess && widget.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Error Details',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            widget.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 4.h),

                  // Action buttons
                  Row(
                    children: [
                      if (!widget.isSuccess)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onRetry,
                            icon: CustomIconWidget(
                              iconName: 'refresh',
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                            label: Text(
                              'Try Again',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      if (!widget.isSuccess) SizedBox(width: 3.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onClose,
                          icon: CustomIconWidget(
                            iconName: widget.isSuccess ? 'check' : 'close',
                            color: theme.colorScheme.onPrimary,
                            size: 18,
                          ),
                          label: Text(
                            widget.isSuccess ? 'Done' : 'Close',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.isSuccess
                                ? Colors.green
                                : theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
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
