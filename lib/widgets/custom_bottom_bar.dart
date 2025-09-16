import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomBottomBarVariant {
  standard,
  withFab,
  minimal,
}

class CustomBottomBar extends StatefulWidget {
  final CustomBottomBarVariant variant;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    this.variant = CustomBottomBarVariant.standard,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (widget.onTap != null) {
      widget.onTap!(index);
    } else {
      _navigateToRoute(index);
    }
  }

  void _navigateToRoute(int index) {
    final routes = [
      '/dashboard-screen',
      '/qr-code-scanner-screen',
      '/attendance-reports-screen',
      '/leave-request-screen',
      '/settings-screen',
    ];

    if (index < routes.length) {
      Navigator.pushNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (widget.variant) {
      case CustomBottomBarVariant.standard:
        return _buildStandardBottomBar(theme, isDark);
      case CustomBottomBarVariant.withFab:
        return _buildBottomBarWithFab(theme, isDark);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(theme, isDark);
    }
  }

  Widget _buildStandardBottomBar(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: _handleTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor:
            widget.selectedItemColor ?? theme.colorScheme.primary,
        unselectedItemColor: widget.unselectedItemColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarWithFab(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Dashboard',
              index: 0,
              theme: theme,
            ),
            _buildNavItem(
              icon: Icons.assessment_outlined,
              activeIcon: Icons.assessment,
              label: 'Reports',
              index: 1,
              theme: theme,
            ),
            const SizedBox(width: 40), // Space for FAB
            _buildNavItem(
              icon: Icons.event_note_outlined,
              activeIcon: Icons.event_note,
              label: 'Leave',
              index: 2,
              theme: theme,
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: 'Settings',
              index: 3,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(ThemeData theme, bool isDark) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMinimalNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            index: 0,
            theme: theme,
          ),
          _buildMinimalNavItem(
            icon: Icons.qr_code_scanner_outlined,
            activeIcon: Icons.qr_code_scanner,
            index: 1,
            theme: theme,
          ),
          _buildMinimalNavItem(
            icon: Icons.assessment_outlined,
            activeIcon: Icons.assessment,
            index: 2,
            theme: theme,
          ),
          _buildMinimalNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            index: 3,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = widget.currentIndex == index;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected && _animationController.isAnimating
              ? _scaleAnimation.value
              : 1.0,
          child: InkWell(
            onTap: () => _handleTap(index),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected
                        ? (widget.selectedItemColor ??
                            theme.colorScheme.primary)
                        : (widget.unselectedItemColor ??
                            theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? (widget.selectedItemColor ??
                              theme.colorScheme.primary)
                          : (widget.unselectedItemColor ??
                              theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = widget.currentIndex == index;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected && _animationController.isAnimating
              ? _scaleAnimation.value
              : 1.0,
          child: InkWell(
            onTap: () => _handleTap(index),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: isSelected
                  ? BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
