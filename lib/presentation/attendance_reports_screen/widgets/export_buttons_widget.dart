import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ExportButtonsWidget extends StatefulWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onExportExcel;
  final bool isExporting;

  const ExportButtonsWidget({
    super.key,
    required this.onExportPDF,
    required this.onExportExcel,
    this.isExporting = false,
  });

  @override
  State<ExportButtonsWidget> createState() => _ExportButtonsWidgetState();
}

class _ExportButtonsWidgetState extends State<ExportButtonsWidget> {
  bool _isPDFExporting = false;
  bool _isExcelExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Options',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;

              return isSmallScreen
                  ? _buildVerticalLayout(theme)
                  : _buildHorizontalLayout(theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(ThemeData theme) {
    return Column(
      children: [
        _buildExportButton(
          theme: theme,
          label: 'Export as PDF',
          icon: 'picture_as_pdf',
          color: theme.colorScheme.error,
          isLoading: _isPDFExporting,
          onPressed: _handlePDFExport,
        ),
        SizedBox(height: 2.h),
        _buildExportButton(
          theme: theme,
          label: 'Export as Excel',
          icon: 'table_chart',
          color: const Color(0xFF4CAF50),
          isLoading: _isExcelExporting,
          onPressed: _handleExcelExport,
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildExportButton(
            theme: theme,
            label: 'Export as PDF',
            icon: 'picture_as_pdf',
            color: theme.colorScheme.error,
            isLoading: _isPDFExporting,
            onPressed: _handlePDFExport,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildExportButton(
            theme: theme,
            label: 'Export as Excel',
            icon: 'table_chart',
            color: const Color(0xFF4CAF50),
            isLoading: _isExcelExporting,
            onPressed: _handleExcelExport,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton({
    required ThemeData theme,
    required String label,
    required String icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: isLoading || widget.isExporting ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }

  void _handlePDFExport() async {
    setState(() => _isPDFExporting = true);

    try {
      await Future.delayed(
          const Duration(seconds: 2)); // Simulate export process
      widget.onExportPDF();
    } finally {
      if (mounted) {
        setState(() => _isPDFExporting = false);
      }
    }
  }

  void _handleExcelExport() async {
    setState(() => _isExcelExporting = true);

    try {
      await Future.delayed(
          const Duration(seconds: 2)); // Simulate export process
      widget.onExportExcel();
    } finally {
      if (mounted) {
        setState(() => _isExcelExporting = false);
      }
    }
  }
}
