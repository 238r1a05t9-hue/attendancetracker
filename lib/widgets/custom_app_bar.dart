import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  withActions,
  withSearch,
  minimal,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onSearchTap;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onSearchTap,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? theme.appBarTheme.foregroundColor,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? 2.0,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: _buildActions(context, theme, isDark),
      iconTheme: IconThemeData(
        color: foregroundColor ?? theme.appBarTheme.foregroundColor,
      ),
    );
  }

  List<Widget>? _buildActions(
      BuildContext context, ThemeData theme, bool isDark) {
    switch (variant) {
      case CustomAppBarVariant.standard:
        return actions;

      case CustomAppBarVariant.withActions:
        return [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings-screen');
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ];

      case CustomAppBarVariant.withSearch:
        return [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: onSearchTap ??
                () {
                  // Default search action
                },
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreOptions(context);
            },
            tooltip: 'More options',
          ),
          const SizedBox(width: 8),
        ];

      case CustomAppBarVariant.minimal:
        return null;
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(
                'Refresh',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle refresh
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(
                'Help',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Handle help
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(
                'Settings',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings-screen');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
