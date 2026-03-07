import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/features/Order/presentation/views/order_history_screen.dart';
import 'package:gamezone_flutter/core/utils/snackbar_utils.dart';
import 'package:gamezone_flutter/core/utils/image_picker_helper.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _tempImageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _tempImageFile = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profileNotifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              if (profileState.isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                )
              else
                _buildProfileHeader(profileState, profileNotifier),

              const SizedBox(height: 32),

              if (profileState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profileState.error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => profileNotifier.clearError(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                onTap: () => _showEditProfileDialog(
                  context,
                  profileNotifier,
                  profileState.profile,
                ),
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.history_rounded,
                title: 'Order History',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.settings_rounded,
                title: 'Settings',
                onTap: () {},
              ),
              const SizedBox(height: 12),

              if (profileState.profile?.profileImage != null &&
                  profileState.profile!.profileImage!.isNotEmpty) ...[
                _buildMenuItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Remove Profile Picture',
                  isDestructive: true,
                  onTap: () => _showDeleteImageDialog(context, profileNotifier),
                ),
                const SizedBox(height: 12),
              ],

              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context, profileNotifier),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileState state, ProfileNotifier notifier) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _pickAndUploadImage(notifier),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9D4EDD)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF1E293B),
                  backgroundImage: state.profile?.profileImage != null
                      ? NetworkImage(state.profile!.profileImage!)
                      : null,
                  child: _tempImageFile != null
                      ? ClipOval(
                          child: Image.file(
                            _tempImageFile!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        )
                      : state.profile?.profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white.withValues(alpha: 0.5),
                            )
                          : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F172A), width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              if (state.isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          state.profile?.fullName ?? 'Guest User',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          state.profile?.email ?? 'No email available',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        if (state.profile?.phone != null && state.profile!.phone!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            state.profile!.phone!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.2)
                    : const Color(0xFF6C63FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : const Color(0xFF6C63FF),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(ProfileNotifier profileNotifier) async {
    try {
      final File? imageFile = await ImagePickerHelper.pickFromGallery(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (imageFile != null) {
        setState(() {
          _tempImageFile = imageFile;
        });

        final success = await profileNotifier.uploadProfileImage(imageFile);

        setState(() {
          _tempImageFile = null;
        });

        if (mounted) {
          if (success) {
            SnackbarUtils.showSuccess(
              context,
              'Profile picture updated successfully!',
            );
          } else {
            SnackbarUtils.showError(context, 'Failed to upload image');
          }
        }
      }
    } catch (e) {
      setState(() {
        _tempImageFile = null;
      });

      if (mounted) {
        SnackbarUtils.showError(context, 'Error picking image: $e');
      }
    }
  }

  void _showEditProfileDialog(
    BuildContext context,
    ProfileNotifier notifier,
    profile,
  ) {
    final fullNameController = TextEditingController(text: profile?.fullName ?? '');
    final emailController = TextEditingController(text: profile?.email ?? '');
    final phoneController = TextEditingController(text: profile?.phone ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: fullNameController,
                label: 'Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: phoneController,
                label: 'Phone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
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
                  SnackbarUtils.showError(context, 'Failed to update profile');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }

  void _showDeleteImageDialog(BuildContext context, ProfileNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Remove Profile Picture',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to remove your profile picture?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await notifier.deleteProfileImage();

              if (mounted) {
                if (success) {
                  SnackbarUtils.showSuccess(context, 'Profile picture removed successfully!');
                } else {
                  SnackbarUtils.showError(context, 'Failed to remove picture');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to leave GameZone?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await notifier.logout();

              if (mounted) {
                SnackbarUtils.showSuccess(context, 'Logged out successfully');
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
