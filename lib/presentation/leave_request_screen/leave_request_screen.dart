import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/leave_balance_card.dart';
import './widgets/leave_form_widget.dart';
import './widgets/leave_history_widget.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  bool _isSubmitting = false;
  bool _isLoading = true;

  // Mock leave balance data
  final List<Map<String, dynamic>> _leaveBalanceData = [
    {
      "type": "Vacation",
      "available": 15,
      "total": 20,
      "color": const Color(0xFF009688),
    },
    {
      "type": "Sick",
      "available": 8,
      "total": 10,
      "color": const Color(0xFF4CAF50),
    },
    {
      "type": "Personal",
      "available": 3,
      "total": 5,
      "color": const Color(0xFFFF9800),
    },
  ];

  // Mock leave history data
  List<LeaveHistoryItem> _leaveHistory = [];

  @override
  void initState() {
    super.initState();
    _loadLeaveHistory();
  }

  void _loadLeaveHistory() {
    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _leaveHistory = [
            LeaveHistoryItem(
              id: "1",
              leaveType: "Vacation",
              startDate: DateTime(2025, 8, 15),
              endDate: DateTime(2025, 8, 18),
              reason:
                  "Family vacation to the mountains. Planning to spend quality time with family and recharge for upcoming projects.",
              status: LeaveStatus.approved,
              submittedDate: DateTime(2025, 7, 20),
              approverName: "Sarah Johnson",
              comments: "Approved. Enjoy your vacation!",
            ),
            LeaveHistoryItem(
              id: "2",
              leaveType: "Sick",
              startDate: DateTime(2025, 7, 10),
              endDate: DateTime(2025, 7, 11),
              reason: "Flu symptoms and need rest to recover properly.",
              status: LeaveStatus.approved,
              submittedDate: DateTime(2025, 7, 9),
              approverName: "Michael Chen",
            ),
            LeaveHistoryItem(
              id: "3",
              leaveType: "Personal",
              startDate: DateTime(2025, 6, 25),
              endDate: DateTime(2025, 6, 25),
              reason:
                  "Attending important family event - cousin's wedding ceremony.",
              status: LeaveStatus.pending,
              submittedDate: DateTime(2025, 6, 20),
            ),
            LeaveHistoryItem(
              id: "4",
              leaveType: "Emergency",
              startDate: DateTime(2025, 5, 12),
              endDate: DateTime(2025, 5, 13),
              reason:
                  "Medical emergency in family requiring immediate attention.",
              status: LeaveStatus.rejected,
              submittedDate: DateTime(2025, 5, 11),
              approverName: "David Wilson",
              comments:
                  "Please provide medical documentation for emergency leave requests.",
            ),
          ];
          _isLoading = false;
        });
      }
    });
  }

  void _handleLeaveSubmission(String leaveType, DateTime startDate,
      DateTime endDate, String reason) async {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // Show success dialog
      _showSuccessDialog(leaveType, startDate, endDate, reason);
    }
  }

  void _showSuccessDialog(
      String leaveType, DateTime startDate, DateTime endDate, String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Request Submitted',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your leave request has been submitted successfully and is pending approval.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Details:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 1.h),
                  Text('Type: $leaveType',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    'Dates: ${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Duration: ${endDate.difference(startDate).inDays + 1} day${endDate.difference(startDate).inDays + 1 > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard-screen');
            },
            child: Text(
              'Go to Dashboard',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add new request to history
              setState(() {
                _leaveHistory.insert(
                    0,
                    LeaveHistoryItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      leaveType: leaveType,
                      startDate: startDate,
                      endDate: endDate,
                      reason: reason,
                      status: LeaveStatus.pending,
                      submittedDate: DateTime.now(),
                    ));
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _refreshLeaveData() {
    setState(() {
      _isLoading = true;
    });
    _loadLeaveHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Leave Request',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshLeaveData,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Refresh',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refreshLeaveData();
          },
          color: theme.colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave Balance Section
                Text(
                  'Leave Balance',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: (_leaveBalanceData as List).map((balance) {
                    return LeaveBalanceCard(
                      leaveType: balance["type"] as String,
                      availableDays: balance["available"] as int,
                      totalDays: balance["total"] as int,
                      accentColor: balance["color"] as Color,
                    );
                  }).toList(),
                ),

                SizedBox(height: 4.h),

                // Leave Request Form Section
                Text(
                  'New Leave Request',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: LeaveFormWidget(
                    onSubmit: _handleLeaveSubmission,
                    isLoading: _isSubmitting,
                  ),
                ),

                SizedBox(height: 4.h),

                // Leave History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Leave History',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_leaveHistory.isNotEmpty)
                      Text(
                        '${_leaveHistory.length} request${_leaveHistory.length > 1 ? 's' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),

                if (_isLoading)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Loading leave history...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  LeaveHistoryWidget(
                    leaveHistory: _leaveHistory,
                    onRefresh: _refreshLeaveData,
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
