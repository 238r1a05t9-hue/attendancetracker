import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum DateRangePreset {
  thisWeek,
  thisMonth,
  lastMonth,
  custom,
}

class DateRangePickerModal extends StatefulWidget {
  final DateTimeRange? initialRange;
  final Function(DateTimeRange) onRangeSelected;

  const DateRangePickerModal({
    super.key,
    this.initialRange,
    required this.onRangeSelected,
  });

  @override
  State<DateRangePickerModal> createState() => _DateRangePickerModalState();
}

class _DateRangePickerModalState extends State<DateRangePickerModal> {
  DateRangePreset _selectedPreset = DateRangePreset.thisMonth;
  DateTimeRange? _customRange;
  late DateTimeRange _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = widget.initialRange ?? _getThisMonthRange();
    _determineInitialPreset();
  }

  void _determineInitialPreset() {
    final now = DateTime.now();
    final thisWeek = _getThisWeekRange();
    final thisMonth = _getThisMonthRange();
    final lastMonth = _getLastMonthRange();

    if (widget.initialRange != null) {
      if (_rangesEqual(widget.initialRange!, thisWeek)) {
        _selectedPreset = DateRangePreset.thisWeek;
      } else if (_rangesEqual(widget.initialRange!, thisMonth)) {
        _selectedPreset = DateRangePreset.thisMonth;
      } else if (_rangesEqual(widget.initialRange!, lastMonth)) {
        _selectedPreset = DateRangePreset.lastMonth;
      } else {
        _selectedPreset = DateRangePreset.custom;
        _customRange = widget.initialRange;
      }
    }
  }

  bool _rangesEqual(DateTimeRange range1, DateTimeRange range2) {
    return range1.start.day == range2.start.day &&
        range1.start.month == range2.start.month &&
        range1.start.year == range2.start.year &&
        range1.end.day == range2.end.day &&
        range1.end.month == range2.end.month &&
        range1.end.year == range2.end.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(theme),
          _buildHeader(theme),
          _buildPresetOptions(theme),
          if (_selectedPreset == DateRangePreset.custom)
            _buildCustomDatePicker(theme),
          _buildActionButtons(theme),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      width: 12.w,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'date_range',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Text(
            'Select Date Range',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetOptions(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          _buildPresetOption(
            theme: theme,
            preset: DateRangePreset.thisWeek,
            title: 'This Week',
            subtitle: _formatDateRange(_getThisWeekRange()),
          ),
          _buildPresetOption(
            theme: theme,
            preset: DateRangePreset.thisMonth,
            title: 'This Month',
            subtitle: _formatDateRange(_getThisMonthRange()),
          ),
          _buildPresetOption(
            theme: theme,
            preset: DateRangePreset.lastMonth,
            title: 'Last Month',
            subtitle: _formatDateRange(_getLastMonthRange()),
          ),
          _buildPresetOption(
            theme: theme,
            preset: DateRangePreset.custom,
            title: 'Custom Range',
            subtitle: _customRange != null
                ? _formatDateRange(_customRange!)
                : 'Select custom dates',
          ),
        ],
      ),
    );
  }

  Widget _buildPresetOption({
    required ThemeData theme,
    required DateRangePreset preset,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedPreset == preset;

    return InkWell(
      onTap: () => _selectPreset(preset),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<DateRangePreset>(
              value: preset,
              groupValue: _selectedPreset,
              onChanged: (value) => _selectPreset(value!),
              activeColor: theme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildCustomDatePicker(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: ElevatedButton(
        onPressed: _showDateRangePicker,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          foregroundColor: theme.colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'calendar_month',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Select Custom Dates',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: _applySelection,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectPreset(DateRangePreset preset) {
    setState(() {
      _selectedPreset = preset;

      switch (preset) {
        case DateRangePreset.thisWeek:
          _currentRange = _getThisWeekRange();
          break;
        case DateRangePreset.thisMonth:
          _currentRange = _getThisMonthRange();
          break;
        case DateRangePreset.lastMonth:
          _currentRange = _getLastMonthRange();
          break;
        case DateRangePreset.custom:
          if (_customRange != null) {
            _currentRange = _customRange!;
          }
          break;
      }
    });
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _customRange ?? _getThisMonthRange(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customRange = picked;
        _currentRange = picked;
      });
    }
  }

  void _applySelection() {
    widget.onRangeSelected(_currentRange);
    Navigator.of(context).pop();
  }

  DateTimeRange _getThisWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return DateTimeRange(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
    );
  }

  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return DateTimeRange(start: startOfMonth, end: endOfMonth);
  }

  DateTimeRange _getLastMonthRange() {
    final now = DateTime.now();
    final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
    final endOfLastMonth = DateTime(now.year, now.month, 0);

    return DateTimeRange(start: startOfLastMonth, end: endOfLastMonth);
  }

  String _formatDateRange(DateTimeRange range) {
    final startDate =
        '${range.start.day}/${range.start.month}/${range.start.year}';
    final endDate = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$startDate - $endDate';
  }
}
