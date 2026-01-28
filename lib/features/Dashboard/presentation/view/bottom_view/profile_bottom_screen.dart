import 'package:flutter/material.dart';

class ProfileBottomScreen extends StatefulWidget {
  const ProfileBottomScreen({super.key});

  @override
  State<ProfileBottomScreen> createState() => _ProfileBottomScreenState();
}

class _ProfileBottomScreenState extends State<ProfileBottomScreen> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Center(child: Text("Welcome to the profile Screen")),
    );
  }
}
