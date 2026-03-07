import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarPath;
  final String? avatarUrl;
  final bool isLoading;
  final bool isUploading;
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    this.avatarPath,
    this.avatarUrl,
    this.isLoading = false,
    this.isUploading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF1E293B),
            child: _buildAvatarImage(),
          ),
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          if (isLoading)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          if (!isUploading && !isLoading)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    // Priority: Local file > Network URL > Default
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      print('Avatar Path: $avatarPath'); // Debug log
      return ClipOval(
        child: Image.file(
          File(avatarPath!),
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading local image: $error'); // Debug log
            return const Icon(Icons.person, size: 60, color: Colors.white70);
          },
        ),
      );
    }
    
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      print('Avatar URL: $avatarUrl'); // Debug log
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) {
            print('Error loading network image: $error'); // Debug log
            return const Icon(Icons.person, size: 60, color: Colors.white70);
          },
        ),
      );
    }
    
    print('No avatar image found, showing default icon'); // Debug log
    return const Icon(Icons.person, size: 60, color: Colors.white70);
  }
}
