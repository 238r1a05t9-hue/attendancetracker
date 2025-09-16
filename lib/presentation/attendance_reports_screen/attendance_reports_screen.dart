import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/attendance_table_widget.dart';
import './widgets/date_range_picker_modal.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/export_buttons_widget.dart';

class AttendanceReportsScreen extends StatefulWidget {
  const AttendanceReportsScreen({super.key});

  @override
  State<AttendanceReportsScreen> createState() =>
      _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState extends State<AttendanceReportsScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _tableScrollController = ScrollController();

  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  );

  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = false;
  bool _isExporting = false;
  int _currentPage = 1;
  bool _hasMoreData = true;

  // Mock attendance data
  final List<Map<String, dynamic>> _mockAttendanceData = [
    {
      "id": 1,
      "date": "01/12/2024",
      "loginTime": "09:15 AM",
      "logoutTime": "06:30 PM",
      "totalHours": "8h 45m",
      "status": "Present",
      "breakTime": "1h 15m",
      "overtime": "0h 30m",
    },
    {
      "id": 2,
      "date": "02/12/2024",
      "loginTime": "09:00 AM",
      "logoutTime": "06:00 PM",
      "totalHours": "8h 30m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "0h 00m",
    },
    {
      "id": 3,
      "date": "03/12/2024",
      "loginTime": "09:30 AM",
      "logoutTime": "04:00 PM",
      "totalHours": "6h 00m",
      "status": "Partial",
      "breakTime": "0h 30m",
      "overtime": "0h 00m",
    },
    {
      "id": 4,
      "date": "04/12/2024",
      "loginTime": null,
      "logoutTime": null,
      "totalHours": "0h 00m",
      "status": "Absent",
      "breakTime": "0h 00m",
      "overtime": "0h 00m",
    },
    {
      "id": 5,
      "date": "05/12/2024",
      "loginTime": "08:45 AM",
      "logoutTime": "07:15 PM",
      "totalHours": "9h 45m",
      "status": "Present",
      "breakTime": "0h 45m",
      "overtime": "1h 30m",
    },
    {
      "id": 6,
      "date": "06/12/2024",
      "loginTime": "09:10 AM",
      "logoutTime": "06:10 PM",
      "totalHours": "8h 30m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "0h 00m",
    },
    {
      "id": 7,
      "date": "07/12/2024",
      "loginTime": "09:20 AM",
      "logoutTime": "05:45 PM",
      "totalHours": "7h 55m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "0h 00m",
    },
    {
      "id": 8,
      "date": "09/12/2024",
      "loginTime": "09:05 AM",
      "logoutTime": "06:20 PM",
      "totalHours": "8h 45m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "0h 15m",
    },
    {
      "id": 9,
      "date": "10/12/2024",
      "loginTime": "08:50 AM",
      "logoutTime": "06:50 PM",
      "totalHours": "9h 30m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "1h 00m",
    },
    {
      "id": 10,
      "date": "11/12/2024",
      "loginTime": "09:25 AM",
      "logoutTime": "03:30 PM",
      "totalHours": "5h 35m",
      "status": "Partial",
      "breakTime": "0h 30m",
      "overtime": "0h 00m",
    },
    {
      "id": 11,
      "date": "12/12/2024",
      "loginTime": "09:00 AM",
      "logoutTime": "06:00 PM",
      "totalHours": "8h 30m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "0h 00m",
    },
    {
      "id": 12,
      "date": "13/12/2024",
      "loginTime": "09:15 AM",
      "logoutTime": "06:45 PM",
      "totalHours": "9h 00m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "0h 30m",
    },
    {
      "id": 13,
      "date": "14/12/2024",
      "loginTime": null,
      "logoutTime": null,
      "totalHours": "0h 00m",
      "status": "Absent",
      "breakTime": "0h 00m",
      "overtime": "0h 00m",
    },
    {
      "id": 14,
      "date": "16/12/2024",
      "loginTime": "08:55 AM",
      "logoutTime": "06:25 PM",
      "totalHours": "9h 00m",
      "status": "Present",
      "breakTime": "1h 30m",
      "overtime": "0h 30m",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tableScrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _tableScrollController.addListener(() {
      if (_tableScrollController.position.pixels >=
          _tableScrollController.position.maxScrollExtent - 200) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadAttendanceData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Filter mock data based on selected date range
      final filteredData = _mockAttendanceData.where((record) {
        final dateParts = (record['date'] as String).split('/');
        final recordDate = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
        );

        return recordDate.isAfter(
                _selectedDateRange.start.subtract(const Duration(days: 1))) &&
            recordDate
                .isBefore(_selectedDateRange.end.add(const Duration(days: 1)));
      }).toList();

      setState(() {
        _attendanceData = List.from(filteredData);
        _currentPage = 1;
        _hasMoreData = filteredData.length >= 10;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load attendance data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Simulate loading more data (in real app, this would be an API call)
      final moreData =
          _mockAttendanceData.skip(_currentPage * 10).take(10).toList();

      if (moreData.isNotEmpty) {
        setState(() {
          _attendanceData.addAll(moreData);
          _currentPage++;
          _hasMoreData = moreData.length >= 10;
        });
      } else {
        setState(() => _hasMoreData = false);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load more data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadAttendanceData();
  }

  void _showDateRangePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangePickerModal(
        initialRange: _selectedDateRange,
        onRangeSelected: (range) {
          setState(() => _selectedDateRange = range);
          _loadAttendanceData();
        },
      ),
    );
  }

  Future<void> _exportToPDF() async {
    setState(() => _isExporting = true);

    try {
      final csvContent = _generateCSVContent();
      final pdfContent = _convertToPDFFormat(csvContent);

      await _downloadFile(pdfContent, 'attendance_report.pdf');
      _showSuccessSnackBar('PDF exported successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to export PDF');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);

    try {
      final csvContent = _generateCSVContent();
      await _downloadFile(csvContent, 'attendance_report.csv');
      _showSuccessSnackBar('Excel file exported successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to export Excel file');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  String _generateCSVContent() {
    final buffer = StringBuffer();

    // Add header
    buffer.writeln(
        'Date,Login Time,Logout Time,Total Hours,Status,Break Time,Overtime');

    // Add data rows
    for (final record in _attendanceData) {
      buffer.writeln(
          '${record['date']},${record['loginTime'] ?? 'N/A'},${record['logoutTime'] ?? 'N/A'},${record['totalHours']},${record['status']},${record['breakTime']},${record['overtime']}');
    }

    return buffer.toString();
  }

  String _convertToPDFFormat(String csvContent) {
    // In a real app, you would use a PDF generation library
    // For now, we'll return the CSV content as a simple text format
    return '''
ATTENDANCE REPORT
================
Date Range: ${_formatDateRange(_selectedDateRange)}
Generated: ${DateTime.now().toString().split('.')[0]}

$csvContent
    ''';
  }

  Future<void> _downloadFile(String content, String filename) async {
    try {
      if (kIsWeb) {
        final bytes = utf8.encode(content);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
      }
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDateRange(DateTimeRange range) {
    final startDate =
        '${range.start.day}/${range.start.month}/${range.start.year}';
    final endDate = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$startDate - $endDate';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Attendance Reports',
        variant: CustomAppBarVariant.withActions,
      ),
      drawer: _buildNavigationDrawer(theme),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: theme.colorScheme.primary,
          child: Column(
            children: [
              _buildStickyHeader(theme),
              Expanded(
                child: _isLoading && _attendanceData.isEmpty
                    ? _buildLoadingState(theme)
                    : _buildMainContent(theme),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 2,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  Widget _buildNavigationDrawer(ThemeData theme) {
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(
                  iconName: 'business',
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'AttendanceTracker',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Employee Portal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  theme: theme,
                  icon: 'dashboard',
                  title: 'Dashboard',
                  route: '/dashboard-screen',
                  isSelected: false,
                ),
                _buildDrawerItem(
                  theme: theme,
                  icon: 'qr_code_scanner',
                  title: 'QR Scanner',
                  route: '/qr-code-scanner-screen',
                  isSelected: false,
                ),
                _buildDrawerItem(
                  theme: theme,
                  icon: 'assessment',
                  title: 'Reports',
                  route: '/attendance-reports-screen',
                  isSelected: true,
                ),
                _buildDrawerItem(
                  theme: theme,
                  icon: 'event_note',
                  title: 'Leave Requests',
                  route: '/leave-request-screen',
                  isSelected: false,
                ),
                _buildDrawerItem(
                  theme: theme,
                  icon: 'settings',
                  title: 'Settings',
                  route: '/settings-screen',
                  isSelected: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required ThemeData theme,
    required String icon,
    required String title,
    required String route,
    required bool isSelected,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CustomIconWidget(
          iconName: icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!isSelected) {
            Navigator.pushNamed(context, route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildStickyHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DateRangeSelectorWidget(
        selectedRange: _formatDateRange(_selectedDateRange),
        onTap: _showDateRangePicker,
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading attendance data...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Expanded(
            child: AttendanceTableWidget(
              attendanceData: _attendanceData,
              scrollController: _tableScrollController,
            ),
          ),
          SizedBox(height: 2.h),
          ExportButtonsWidget(
            onExportPDF: _exportToPDF,
            onExportExcel: _exportToExcel,
            isExporting: _isExporting,
          ),
        ],
      ),
    );
  }
}
