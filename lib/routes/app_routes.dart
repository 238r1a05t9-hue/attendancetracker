import 'package:flutter/material.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/leave_request_screen/leave_request_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/attendance_reports_screen/attendance_reports_screen.dart';
import '../presentation/qr_code_scanner_screen/qr_code_scanner_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String settings = '/settings-screen';
  static const String leaveRequest = '/leave-request-screen';
  static const String login = '/login-screen';
  static const String attendanceReports = '/attendance-reports-screen';
  static const String qrCodeScanner = '/qr-code-scanner-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    settings: (context) => const SettingsScreen(),
    leaveRequest: (context) => const LeaveRequestScreen(),
    login: (context) => const LoginScreen(),
    attendanceReports: (context) => const AttendanceReportsScreen(),
    qrCodeScanner: (context) => const QrCodeScannerScreen(),
    // TODO: Add your other routes here
  };
}
