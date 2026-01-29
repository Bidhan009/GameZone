import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/snackbar_utils.dart'; // create if needed
// import '../../../auth/presentation/providers/auth_provider.dart'; // ← later

import '../providers/profile_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Later: watch real auth state
    // final authState = ref.watch(authProvider);

    final username = ref.watch(profileUsernameProvider);
    final email = ref.watch(profileEmailProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Avatar + name + email section
              ProfileHeader(
                username: username,
                email: email,
                onAvatarTap: () {
                  // TODO: open image picker → upload (later phase)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Avatar change coming soon!')),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Menu items
              ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Edit Profile',
                onTap: () {
                  // TODO: navigate to edit profile page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit profile - not implemented yet'),
                    ),
                  );
                },
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

              ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                isDestructive: true,
                onTap: () => _showLogoutDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

              // TODO: real logout logic later
              // await ref.read(authProvider.notifier).logout();

              SnackbarUtils.showSuccess(context, 'Logged out successfully');

              // Navigate to login / onboarding
              // Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
