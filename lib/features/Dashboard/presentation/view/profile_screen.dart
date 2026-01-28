import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFF1E293B),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),

          const SizedBox(height: 12),

          const Text(
            "Guest User",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            "guest@gamezone.com",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 30),

          _profileItem(Icons.settings, "Settings"),
          _profileItem(Icons.history, "Order History"),
          _profileItem(Icons.logout, "Logout"),
        ],
      ),
    );
  }

  Widget _profileItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
