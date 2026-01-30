import 'package:flutter/material.dart';

import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String? avatarPath;
  final bool isLoading;
  final VoidCallback onAvatarTap;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.email,
    this.avatarPath,
    this.isLoading = false,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileAvatar(
          avatarPath: avatarPath,
          isLoading: isLoading,
          onTap: onAvatarTap,
        ),
        const SizedBox(height: 16),
        Text(
          username,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          email,
          style: const TextStyle(fontSize: 15, color: Colors.white70),
        ),
      ],
    );
  }
}
