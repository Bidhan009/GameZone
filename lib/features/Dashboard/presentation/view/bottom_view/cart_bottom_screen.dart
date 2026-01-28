import 'package:flutter/material.dart';

class CartBottomScreen extends StatefulWidget {
  const CartBottomScreen({super.key});

  @override
  State<CartBottomScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartBottomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Welcome to the cart screen")));
  }
}
