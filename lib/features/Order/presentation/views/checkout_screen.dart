import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/app/app.dart';
import 'package:gamezone_flutter/features/Cart/presentation/providers/cart_provider.dart';
import 'package:gamezone_flutter/features/Dashboard/domain/entities/profile_entity.dart';
import 'package:gamezone_flutter/features/Dashboard/presentation/providers/profile_provider.dart';
import 'package:gamezone_flutter/features/Order/data/models/order_model.dart';
import 'package:gamezone_flutter/features/Order/presentation/providers/order_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamezone_flutter/core/service/sensor_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isObjectNear = false;
  StreamSubscription<bool>? _proximitySubscription;

  @override
  void initState() {
    super.initState();
    _startProximitySensor();
    // Load user profile to auto-fill contact information
    Future.microtask(() {
      final profileState = ref.read(profileProvider);
      if (profileState.profile != null) {
        _prefillContactInfo(profileState.profile!);
      } else {
        ref.read(profileProvider.notifier).loadProfile();
      }
    });
  }

  void _startProximitySensor() {
    final sensorService = ref.read(sensorServiceProvider);
    sensorService.startProximitySensor();
    _proximitySubscription = sensorService.proximityStream.listen((isNear) {
      if (mounted) {
        setState(() {
          _isObjectNear = isNear;
        });
      }
    });
  }

  void _prefillContactInfo(ProfileEntity profile) {
    setState(() {
      if (profile.email.isNotEmpty) {
        _emailController.text = profile.email;
      }
      if (profile.phone != null && profile.phone!.isNotEmpty) {
        _phoneController.text = profile.phone ?? '';
      }
    });
  }

  @override
  void dispose() {
    _proximitySubscription?.cancel();
    ref.read(sensorServiceProvider).stopProximitySensor();
    _streetController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _proceedToCheckout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cartState = ref.read(cartProvider);

      // Debug: Print cart state
      print(
        'Cart State: items=${cartState.items.length}, totalPrice=${cartState.totalPrice}',
      );

      // Convert cart items to OrderItemModel
      final orderItems = cartState.items.map((cartItem) {
        print(
          'Cart Item: id=${cartItem.productId}, quantity=${cartItem.quantity}, price=${cartItem.product?.price}',
        );
        return OrderItemModel(
          productId: cartItem.productId,
          quantity: cartItem.quantity,
          price: cartItem.product?.price ?? 0.0,
          product: cartItem.product,
        );
      }).toList();

      // Calculate total amount from items
      final calculatedTotal = orderItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      print(
        'Order Items: ${orderItems.length}, Calculated Total: $calculatedTotal, Cart Total: ${cartState.totalPrice}',
      );

      final shippingAddress = ShippingAddressModel(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
      );

      final contactInfo = ContactInfoModel(
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      final orderData = CreateOrderRequestModel(
        items: orderItems,
        totalAmount:
            calculatedTotal, // Use calculated total instead of cart total
        shippingAddress: shippingAddress,
        contactInfo: contactInfo,
        paymentMethod: 'COD',
      );

      // Debug: Print the request data
      print('Order Request Data: ${orderData.toJson()}');

      await ref.read(orderProvider.notifier).createOrder(orderData);

      // Clear the cart after successful order
      await ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to order history or home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final profileState = ref.watch(profileProvider);

    // Auto-fill contact info when profile is loaded
    if (profileState.profile != null && _emailController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefillContactInfo(profileState.profile!);
      });
    }

    if (cartState.items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Checkout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 70,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Your cart is empty",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...cartState.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.product?.name ?? 'Product'}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${(item.product?.price ?? 0) * item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${cartState.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shipping Address
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.local_shipping,
                                color: Color(0xFFEC4899),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Shipping Address',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _streetController,
                          label: 'Street Address',
                          icon: Icons.home_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _zipCodeController,
                          label: 'Zip Code',
                          icon: Icons.pin_drop_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Information
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.contact_phone,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Contact Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Method
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.payment,
                                color: Color(0xFFF59E0B),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.money, color: Color(0xFF10B981)),
                              SizedBox(width: 12),
                              Text(
                                'Cash on Delivery (COD)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading || _isObjectNear
                          ? null
                          : _proceedToCheckout,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: _isObjectNear 
                            ? Colors.grey 
                            : const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _isObjectNear ? 0 : 8,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _isObjectNear ? 'Checkout Disabled' : 'Place Order',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Disable entire page when object is near
          if (_isObjectNear)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(32),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sensors_off,
                          size: 48,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Proximity Sensor Active',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Move object away from phone to continue checkout',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: !_isObjectNear,
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
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF6C63FF),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
