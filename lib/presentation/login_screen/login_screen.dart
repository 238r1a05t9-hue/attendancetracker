import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberEmployeeId = true;
  String? _employeeIdError;
  String? _passwordError;

  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formOpacityAnimation;

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin': 'admin123',
    'john.doe': 'password123',
    'jane.smith': 'secure456',
    'mike.wilson': 'mypass789',
    'sarah.jones': 'login2024',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSavedEmployeeId();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _formOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _formAnimationController.forward();
    });
  }

  void _loadSavedEmployeeId() {
    // In a real app, this would load from SharedPreferences
    // For demo purposes, we'll simulate a saved employee ID
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _employeeIdController.text = 'john.doe';
        });
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmployeeId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Employee ID is required';
    }
    if (value.trim().length < 3) {
      return 'Employee ID must be at least 3 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  bool get _isFormValid {
    return _employeeIdController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _validateEmployeeId(_employeeIdController.text) == null &&
        _validatePassword(_passwordController.text) == null;
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _employeeIdError = null;
      _passwordError = null;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1500));

      final employeeId = _employeeIdController.text.trim();
      final password = _passwordController.text;

      // Check mock credentials
      if (_mockCredentials.containsKey(employeeId) &&
          _mockCredentials[employeeId] == password) {
        // Save employee ID if remember is checked
        if (_rememberEmployeeId) {
          // In a real app, save to SharedPreferences
        }

        // Success haptic feedback
        HapticFeedback.selectionClick();

        // Navigate to dashboard
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard-screen');
        }
      } else {
        // Handle authentication failure
        setState(() {
          if (!_mockCredentials.containsKey(employeeId)) {
            _employeeIdError = 'Employee ID not found';
          } else {
            _passwordError = 'Incorrect password';
          }
        });

        // Error haptic feedback
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Handle network or other errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed. Please check your connection and try again.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppTheme.lightTheme.colorScheme.onError,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    // In a real app, this would navigate to forgot password screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Password reset functionality will be available soon.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),

                // Animated Company Logo
                AnimatedBuilder(
                  animation: _logoScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'business',
                            color: theme.colorScheme.onPrimary,
                            size: 12.w,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 3.h),

                // App Title
                AnimatedBuilder(
                  animation: _logoScaleAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoScaleAnimation.value,
                      child: Text(
                        'AttendanceTracker',
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 1.h),

                // Subtitle
                AnimatedBuilder(
                  animation: _logoScaleAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoScaleAnimation.value * 0.7,
                      child: Text(
                        'Employee Portal',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 6.h),

                // Login Form
                SlideTransition(
                  position: _formSlideAnimation,
                  child: FadeTransition(
                    opacity: _formOpacityAnimation,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 90.w),
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                theme.colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Text
                            Text(
                              'Welcome Back',
                              style: GoogleFonts.inter(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),

                            SizedBox(height: 1.h),

                            Text(
                              'Sign in to your account',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),

                            SizedBox(height: 4.h),

                            // Employee ID Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Employee ID',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                TextFormField(
                                  controller: _employeeIdController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  enabled: !_isLoading,
                                  onChanged: (value) {
                                    setState(() {
                                      _employeeIdError = null;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter your employee ID',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(3.w),
                                      child: CustomIconWidget(
                                        iconName: 'person_outline',
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        size: 5.w,
                                      ),
                                    ),
                                    errorText: _employeeIdError,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.error,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.error,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 3.h),

                            // Password Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  enabled: !_isLoading,
                                  onChanged: (value) {
                                    setState(() {
                                      _passwordError = null;
                                    });
                                  },
                                  onFieldSubmitted: (_) {
                                    if (_isFormValid) {
                                      _handleLogin();
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(3.w),
                                      child: CustomIconWidget(
                                        iconName: 'lock_outline',
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        size: 5.w,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: _isLoading ? null : () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                      icon: CustomIconWidget(
                                        iconName: _isPasswordVisible
                                            ? 'visibility_off'
                                            : 'visibility',
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.6),
                                        size: 5.w,
                                      ),
                                    ),
                                    errorText: _passwordError,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline,
                                        width: 1.5,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.outline
                                            .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.error,
                                        width: 1.5,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: theme.colorScheme.error,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 2.h),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed:
                                    _isLoading ? null : _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 1.h),
                                ),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 4.h),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton(
                                onPressed: (_isFormValid && !_isLoading)
                                    ? _handleLogin
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  disabledBackgroundColor: theme
                                      .colorScheme.onSurface
                                      .withValues(alpha: 0.12),
                                  disabledForegroundColor: theme
                                      .colorScheme.onSurface
                                      .withValues(alpha: 0.38),
                                  elevation:
                                      _isFormValid && !_isLoading ? 2 : 0,
                                  shadowColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 5.w,
                                        height: 5.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Login',
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),

                // Demo Credentials Info
                SlideTransition(
                  position: _formSlideAnimation,
                  child: FadeTransition(
                    opacity: _formOpacityAnimation,
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 90.w),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info_outline',
                                color: theme.colorScheme.primary,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Demo Credentials',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Use any of these credentials to test the app:\n• admin / admin123\n• john.doe / password123\n• jane.smith / secure456',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}