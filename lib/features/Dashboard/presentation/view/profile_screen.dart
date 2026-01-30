import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/utils/snackbar_utils.dart';
import '../../../../../core/utils/image_picker_helper.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _tempImageFile; // Temporary file for immediate display

  @override
  void initState() {
    super.initState();
    // Load profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _tempImageFile = null; // Clean up temporary file
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Loading indicator
              if (profileState.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                // Avatar + name + email section
                ProfileHeader(
                  username: profileState.profile?.fullName ?? 'Loading...',
                  email: profileState.profile?.email ?? 'Loading...',
                  avatarUrl: profileState.profile?.profileImage,
                  avatarPath: _tempImageFile?.path, // Show temporary image
                  isUploading: profileState.isUploading,
                  onAvatarTap: () => _pickAndUploadImage(profileNotifier),
                ),

              const SizedBox(height: 40),

              // Test button for debugging
              ElevatedButton(
                onPressed: () {
                  print('Current temp image: ${_tempImageFile?.path}');
                  print('Current profile image URL: ${profileState.profile?.profileImage}');
                },
                child: const Text('Debug: Print Image Info'),
              ),

              const SizedBox(height: 20),

              // Error message
              if (profileState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profileState.error!,
                          style: TextStyle(color: Colors.red.shade600, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => profileNotifier.clearError(),
                        color: Colors.red.shade600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Menu items
              ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                onTap: () => _showEditProfileDialog(context, profileNotifier, profileState.profile),
              ),
              const SizedBox(height: 12),

              ProfileMenuItem(
                icon: Icons.history_rounded,
                title: 'Order History / Purchases',
                onTap: () {
                  // TODO: navigate to orders screen
                },
              ),
              const SizedBox(height: 12),

              ProfileMenuItem(
                icon: Icons.settings_rounded,
                title: 'Settings',
                onTap: () {
                  // TODO: settings screen
                },
              ),
              const SizedBox(height: 12),

              // Delete profile image option (only if image exists)
              if (profileState.profile?.profileImage != null && profileState.profile!.profileImage!.isNotEmpty) ...[
                ProfileMenuItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Remove Profile Picture',
                  isDestructive: true,
                  onTap: () => _showDeleteImageDialog(context, profileNotifier),
                ),
                const SizedBox(height: 12),
              ],

              ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context, profileNotifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ProfileNotifier profileNotifier) async {
    try {
      print('Starting image pick process...'); // Debug log
      
      // First, let's try a direct gallery pick without the dialog
      final File? imageFile = await ImagePickerHelper.pickFromGallery(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      print('Image file picked: ${imageFile?.path}'); // Debug log

      if (imageFile != null) {
        print('Setting temporary image...'); // Debug log
        
        // Show the picked image immediately
        setState(() {
          _tempImageFile = imageFile;
        });

        print('Starting upload...'); // Debug log
        
        final success = await profileNotifier.uploadProfileImage(imageFile);
        
        print('Upload completed, success: $success'); // Debug log
        
        // Clear temporary image after upload completes
        setState(() {
          _tempImageFile = null;
        });
        
        if (mounted) {
          if (success) {
            SnackbarUtils.showSuccess(context, 'Profile picture updated successfully!');
          } else {
            SnackbarUtils.showError(context, profileNotifier.state.error ?? 'Failed to upload image');
          }
        }
      } else {
        print('No image file selected'); // Debug log
      }
    } catch (e) {
      print('Error in image pick/upload: $e'); // Debug log
      
      // Clear temporary image on error
      setState(() {
        _tempImageFile = null;
      });
      
      if (mounted) {
        SnackbarUtils.showError(context, 'Error picking image: $e');
      }
    }
  }

  void _showEditProfileDialog(BuildContext context, ProfileNotifier notifier, profile) {
    final fullNameController = TextEditingController(text: profile?.fullName ?? '');
    final emailController = TextEditingController(text: profile?.email ?? '');
    final phoneController = TextEditingController(text: profile?.phone ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              final success = await notifier.updateProfile(
                fullName: fullNameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
              );

              if (mounted) {
                if (success) {
                  SnackbarUtils.showSuccess(context, 'Profile updated successfully!');
                } else {
                  SnackbarUtils.showError(context, notifier.state.error ?? 'Failed to update profile');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteImageDialog(BuildContext context, ProfileNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Profile Picture', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              final success = await notifier.deleteProfileImage();

              if (mounted) {
                if (success) {
                  SnackbarUtils.showSuccess(context, 'Profile picture removed successfully!');
                } else {
                  SnackbarUtils.showError(context, notifier.state.error ?? 'Failed to remove picture');
                }
              }
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to leave GameZone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              await notifier.logout();
              
              if (mounted) {
                SnackbarUtils.showSuccess(context, 'Logged out successfully');
                
                // Navigate to login screen
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
