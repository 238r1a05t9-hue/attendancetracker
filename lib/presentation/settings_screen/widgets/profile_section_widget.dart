import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileSectionWidget extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final Function(String) onProfileUpdate;

  const ProfileSectionWidget({
    super.key,
    required this.userProfile,
    required this.onProfileUpdate,
  });

  @override
  State<ProfileSectionWidget> createState() => _ProfileSectionWidgetState();
}

class _ProfileSectionWidgetState extends State<ProfileSectionWidget> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _profileImagePath = widget.userProfile['profileImage'] as String?;
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Select Profile Photo',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Take Photo',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'Choose from Gallery',
                style: AppTheme.lightTheme.textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_profileImagePath != null)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
                title: Text(
                  'Remove Photo',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfileImage();
                },
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      bool hasPermission = await _requestPermission(source);
      if (!hasPermission) return;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
        widget.onProfileUpdate(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (kIsWeb) return true;

    Permission permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    PermissionStatus status = await permission.request();
    return status.isGranted;
  }

  void _removeProfileImage() {
    setState(() {
      _profileImagePath = null;
    });
    widget.onProfileUpdate('');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: _profileImagePath != null
                        ? ClipOval(
                            child: kIsWeb
                                ? CustomImageWidget(
                                    imageUrl: _profileImagePath!,
                                    width: 20.w,
                                    height: 20.w,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_profileImagePath!),
                                    width: 20.w,
                                    height: 20.w,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : CustomIconWidget(
                            iconName: 'person',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 32,
                          ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userProfile['name'] as String? ?? 'John Doe',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textHighEmphasisDark
                              : AppTheme.textHighEmphasisLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'ID: ${widget.userProfile['employeeId'] as String? ?? 'EMP001'}',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textMediumEmphasisDark
                              : AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.userProfile['department'] as String? ??
                            'Engineering',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textMediumEmphasisDark
                              : AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showEditProfileDialog();
                  },
                  icon: CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(
        text: widget.userProfile['name'] as String? ?? '');
    final departmentController = TextEditingController(
        text: widget.userProfile['department'] as String? ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update profile data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
