import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum LeaveStatus { pending, approved, rejected }

class LeaveHistoryItem {
  final String id;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final DateTime submittedDate;
  final String? approverName;
  final String? comments;

  LeaveHistoryItem({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.submittedDate,
    this.approverName,
    this.comments,
  });
}

class LeaveHistoryWidget extends StatefulWidget {
  final List<LeaveHistoryItem> leaveHistory;
  final VoidCallback? onRefresh;

  const LeaveHistoryWidget({
    super.key,
    required this.leaveHistory,
    this.onRefresh,
  });

  @override
  State<LeaveHistoryWidget> createState() => _LeaveHistoryWidgetState();
}

class _LeaveHistoryWidgetState extends State<LeaveHistoryWidget> {
  final Set<String> _expandedItems = {};

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedItems.contains(id)) {
        _expandedItems.remove(id);
      } else {
        _expandedItems.add(id);
      }
    });
  }

  Color _getStatusColor(LeaveStatus status, ThemeData theme) {
    switch (status) {
      case LeaveStatus.pending:
        return Colors.orange;
      case LeaveStatus.approved:
        return theme.colorScheme.primary;
      case LeaveStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.day}/${start.month}/${start.year}';
    }
    return '${start.day}/${start.month}/${start.year} - ${end.day}/${end.month}/${end.year}';
  }

  int _calculateDays(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.leaveHistory.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh?.call();
      },
      color: theme.colorScheme.primary,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.leaveHistory.length,
        separatorBuilder: (context, index) => SizedBox(height: 2.h),
        itemBuilder: (context, index) {
          final item = widget.leaveHistory[index];
          final isExpanded = _expandedItems.contains(item.id);

          return _buildHistoryCard(item, isExpanded, theme);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'event_note',
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Leave History',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your leave requests will appear here once submitted',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
      LeaveHistoryItem item, bool isExpanded, ThemeData theme) {
    final statusColor = _getStatusColor(item.status, theme);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
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
          // Main Card Content
          InkWell(
            onTap: () => _toggleExpanded(item.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getStatusText(item.status),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                item.leaveType,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomIconWidget(
                        iconName: isExpanded ? 'expand_less' : 'expand_more',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 24,
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Date and Duration
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          _formatDateRange(item.startDate, item.endDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_calculateDays(item.startDate, item.endDate)} day${_calculateDays(item.startDate, item.endDate) > 1 ? 's' : ''}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Reason Preview
                  Text(
                    item.reason,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? null : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Submitted Date
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Submitted: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${item.submittedDate.day}/${item.submittedDate.month}/${item.submittedDate.year}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Approver Info
                  if (item.approverName != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Reviewed by: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          item.approverName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Comments
                  if (item.comments != null && item.comments!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Comments:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        item.comments!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
