import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/app_export.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/manual_entry_dialog_widget.dart';
import './widgets/scan_result_widget.dart';
import './widgets/scanner_overlay_widget.dart';

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera and Scanner Controllers
  CameraController? _cameraController;
  MobileScannerController? _mobileScannerController;
  List<CameraDescription> _cameras = [];

  // State Variables
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isScanning = true;
  bool _isOnline = true;
  bool _hasPermission = false;
  String? _scannedData;
  String? _errorMessage;
  bool _showResult = false;
  bool _scanSuccess = false;

  // Animation Controllers
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Mock offline storage
  final List<Map<String, dynamic>> _offlineScans = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _checkConnectivity();
    _requestPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _mobileScannerController?.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOnline = connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    });

    // Listen for connectivity changes
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final isConnected = result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi;
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });

        if (isConnected && _offlineScans.isNotEmpty) {
          _syncOfflineData();
        }
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      setState(() {
        _hasPermission = true;
      });
      _initializeScanner();
      return;
    }

    final cameraStatus = await Permission.camera.request();

    setState(() {
      _hasPermission = cameraStatus.isGranted;
    });

    if (_hasPermission) {
      _initializeCamera();
      _initializeScanner();
    } else {
      _showPermissionDialog();
    }
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) return;

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFocusMode(FocusMode.auto);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      setState(() {
        _errorMessage = 'Failed to initialize camera';
      });
    }
  }

  void _initializeScanner() {
    _mobileScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _showResult) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String? code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        _processScannedData(code);
      }
    }
  }

  void _processScannedData(String data) {
    setState(() {
      _isScanning = false;
      _scannedData = data;
    });

    // Validate QR code format (mock validation)
    if (_validateQRCode(data)) {
      _recordAttendance(data);
    } else {
      _showScanError('Invalid QR code format');
      _triggerShakeAnimation();
    }
  }

  bool _validateQRCode(String data) {
    // Mock QR code validation - should contain attendance info
    return data.contains('attendance') ||
        data.contains('employee') ||
        data.length >= 10;
  }

  void _recordAttendance(String qrData) {
    final attendanceRecord = {
      'qr_data': qrData,
      'timestamp': DateTime.now().toIso8601String(),
      'employee_id': 'EMP001', // Mock employee ID
      'location': 'Office Main Entrance',
      'type': 'check_in',
      'sync_status': _isOnline ? 'synced' : 'pending',
    };

    if (_isOnline) {
      _syncAttendanceRecord(attendanceRecord);
    } else {
      _storeOfflineRecord(attendanceRecord);
    }

    setState(() {
      _scanSuccess = true;
      _showResult = true;
    });

    // Auto-hide result after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _scanSuccess) {
        _closeScanner();
      }
    });
  }

  Future<void> _syncAttendanceRecord(Map<String, dynamic> record) async {
    // Mock API call to sync attendance
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('Attendance synced: $record');
  }

  void _storeOfflineRecord(Map<String, dynamic> record) {
    _offlineScans.add(record);
    debugPrint('Stored offline: $record');
  }

  Future<void> _syncOfflineData() async {
    if (_offlineScans.isEmpty) return;

    for (final record in _offlineScans) {
      await _syncAttendanceRecord(record);
    }

    _offlineScans.clear();
    debugPrint('All offline data synced');
  }

  void _showScanError(String message) {
    setState(() {
      _scanSuccess = false;
      _errorMessage = message;
      _showResult = true;
    });
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
    HapticFeedback.vibrate();
  }

  void _toggleFlash() {
    if (kIsWeb) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
    });

    _mobileScannerController?.toggleTorch();
  }

  void _retryScanning() {
    setState(() {
      _showResult = false;
      _isScanning = true;
      _scannedData = null;
      _errorMessage = null;
      _scanSuccess = false;
    });
  }

  void _closeScanner() {
    Navigator.of(context).pushReplacementNamed('/dashboard-screen');
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ManualEntryDialogWidget(
        onSubmit: (data) {
          _processScannedData(data);
        },
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Camera Permission Required',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Text(
          'This app needs camera access to scan QR codes for attendance tracking. Please grant camera permission in settings.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _closeScanner();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview or Scanner
          if (_hasPermission) _buildCameraView() else _buildPermissionView(),

          // Scanner Overlay
          if (_hasPermission && !_showResult)
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: ScannerOverlayWidget(
                    isScanning: _isScanning,
                    onManualEntry: _showManualEntryDialog,
                  ),
                );
              },
            ),

          // Camera Controls
          if (_hasPermission && !_showResult)
            CameraControlsWidget(
              isFlashOn: _isFlashOn,
              onFlashToggle: _toggleFlash,
              onClose: _closeScanner,
              isOnline: _isOnline,
            ),

          // Scan Result
          if (_showResult)
            Center(
              child: ScanResultWidget(
                scannedData: _scannedData,
                isSuccess: _scanSuccess,
                errorMessage: _errorMessage,
                onRetry: _retryScanning,
                onClose: _closeScanner,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (kIsWeb) {
      return MobileScanner(
        controller: _mobileScannerController,
        onDetect: _onDetect,
        errorBuilder: (context, error) {
          return Center(
            child: Text(
              'Camera Error: ${error.errorDetails?.message ?? 'Unknown error'}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } else {
      if (_isCameraInitialized && _cameraController != null) {
        return Stack(
          children: [
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            ),
            MobileScanner(
              controller: _mobileScannerController,
              onDetect: _onDetect,
            ),
          ],
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      }
    }
  }

  Widget _buildPermissionView() {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: EdgeInsets.all(8.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: theme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'Camera Access Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'To scan QR codes for attendance, please allow camera access in your device settings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _closeScanner,
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      openAppSettings();
                    },
                    child: const Text('Open Settings'),
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