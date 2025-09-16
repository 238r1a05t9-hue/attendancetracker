import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LeaveFormWidget extends StatefulWidget {
  final Function(
          String leaveType, DateTime startDate, DateTime endDate, String reason)
      onSubmit;
  final bool isLoading;

  const LeaveFormWidget({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<LeaveFormWidget> createState() => _LeaveFormWidgetState();
}

class _LeaveFormWidgetState extends State<LeaveFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  String _selectedLeaveType = 'Vacation';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _leaveTypes = [
    'Vacation',
    'Sick',
    'Personal',
    'Emergency'
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _startDate != null &&
        _endDate != null &&
        _reasonController.text.trim().isNotEmpty;
  }

  void _selectStartDate() async {
    final DateTime? picked = await _showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      title: 'Select Start Date',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  void _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date first')),
      );
      return;
    }

    final DateTime? picked = await _showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!,
      firstDate: _startDate!,
      title: 'Select End Date',
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<DateTime?> _showDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    required String title,
  }) async {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => _CalendarDialog(
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime.now(),
        title: title,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _isFormValid) {
      widget.onSubmit(
        _selectedLeaveType,
        _startDate!,
        _endDate!,
        _reasonController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leave Type Dropdown
          Text(
            'Leave Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _selectedLeaveType,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            items: _leaveTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLeaveType = value;
                });
              }
            },
          ),

          SizedBox(height: 3.h),

          // Date Selection Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    InkWell(
                      onTap: _selectStartDate,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Select Date',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _startDate != null
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Date',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    InkWell(
                      onTap: _selectEndDate,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Select Date',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _endDate != null
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Reason Text Area
          Text(
            'Reason',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _reasonController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Please provide a reason for your leave request...',
              contentPadding: EdgeInsets.all(4.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
              counterStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a reason for your leave';
              }
              if (value.trim().length < 10) {
                return 'Reason must be at least 10 characters';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {});
            },
          ),

          SizedBox(height: 4.h),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  (_isFormValid && !widget.isLoading) ? _submitForm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: widget.isLoading
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
                      'Submit Request',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final String title;

  const _CalendarDialog({
    required this.initialDate,
    required this.firstDate,
    required this.title,
  });

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedDate = widget.initialDate;
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 90.w,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Calendar
            TableCalendar<DateTime>(
              firstDay: widget.firstDate,
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              enabledDayPredicate: (day) {
                return !day.isBefore(widget.firstDate) && !_isWeekend(day);
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                disabledTextStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                defaultDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(),
                leftChevronIcon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                rightChevronIcon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                if (!_isWeekend(selectedDay) &&
                    !selectedDay.isBefore(widget.firstDate)) {
                  setState(() {
                    _selectedDate = selectedDay;
                    _focusedDate = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDate = focusedDay;
              },
            ),

            SizedBox(height: 3.h),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(
                    'Select',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
