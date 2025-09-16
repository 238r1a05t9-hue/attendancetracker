import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ManualEntryDialogWidget extends StatefulWidget {
  final Function(String)? onSubmit;

  const ManualEntryDialogWidget({
    super.key,
    this.onSubmit,
  });

  @override
  State<ManualEntryDialogWidget> createState() =>
      _ManualEntryDialogWidgetState();
}

class _ManualEntryDialogWidgetState extends State<ManualEntryDialogWidget> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _attendanceTypes = [
    {'value': 'check_in', 'label': 'Check In', 'icon': 'login'},
    {'value': 'check_out', 'label': 'Check Out', 'icon': 'logout'},
    {'value': 'break_start', 'label': 'Break Start', 'icon': 'pause'},
    {'value': 'break_end', 'label': 'Break End', 'icon': 'play_arrow'},
  ];

  String _selectedType = 'check_in';

  @override
  void dispose() {
    _employeeIdController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    final manualData = {
      'employee_id': _employeeIdController.text.trim(),
      'location': _locationController.text.trim(),
      'type': _selectedType,
      'timestamp': DateTime.now().toIso8601String(),
      'method': 'manual_entry',
    };

    if (widget.onSubmit != null) {
      widget.onSubmit!(manualData.toString());
    }

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 90.w,
          maxHeight: 80.h,
        ),
        padding: EdgeInsets.all(6.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manual Entry',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Enter attendance details manually',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 20,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4.h),

              // Attendance Type Selection
              Text(
                'Attendance Type',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      }
                    },
                    items:
                        _attendanceTypes.map<DropdownMenuItem<String>>((type) {
                      return DropdownMenuItem<String>(
                        value: type['value'] as String,
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: type['icon'] as String,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              type['label'] as String,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Employee ID Field
              Text(
                'Employee ID',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: _employeeIdController,
                decoration: InputDecoration(
                  hintText: 'Enter your employee ID',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'badge',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Employee ID is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Employee ID must be at least 3 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              SizedBox(height: 3.h),

              // Location Field
              Text(
                'Location (Optional)',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter location or leave blank',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'location_on',
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleSubmit(),
              ),

              SizedBox(height: 4.h),

              // Current Time Display
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Time',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${DateTime.now().toString().substring(0, 10)} ${DateTime.now().toString().substring(11, 16)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
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
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Submit',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
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
  }
}
