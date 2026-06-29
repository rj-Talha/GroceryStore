import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/eyebrow.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _paymentMethod = 'Cash on delivery';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Daana.bg,
      appBar: AppBar(
        backgroundColor: Daana.bg,
        elevation: 0,
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Delivery details'),
                const SizedBox(height: 12),
                Text(
                  'Please enter your details for a smooth delivery.',
                  style: Daana.sans(size: 14, color: Daana.ink70),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'First name',
                  controller: _firstNameController,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  label: 'Last name',
                  controller: _lastNameController,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  label: 'Phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.trim().length < 8
                      ? 'Required'
                      : null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  label: 'Email (optional)',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: null,
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  label: 'Address',
                  controller: _addressController,
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                Text(
                  'Payment method',
                  style: Daana.sans(size: 14, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Daana.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Daana.hairlineSoft),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash on delivery',
                              style: Daana.sans(
                                size: 14,
                                weight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Pay when your order arrives.',
                              style: Daana.sans(size: 12, color: Daana.ink50),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Btn(
                  'Place order',
                  full: true,
                  size: BtnSize.lg,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final cartProvider = context.read<CartProvider>();
                    if (cartProvider.items.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Your cart is empty.')),
                      );
                      return;
                    }

                    try {
                      await _firestoreService.addOrder({
                        'customerName':
                            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
                                .trim(),
                        'phone': _phoneController.text.trim(),
                        'email': _emailController.text.trim(),
                        'address': _addressController.text.trim(),
                        'paymentMethod': _paymentMethod,
                        'status': 'processing',
                        'subtotal': cartProvider.subtotal,
                        'deliveryFee': cartProvider.deliveryFee,
                        'serviceFee': cartProvider.serviceFee,
                        'total': cartProvider.total,
                        'createdAt': DateTime.now().toIso8601String(),
                        'items': cartProvider.items.map((item) {
                          return {
                            'productId': item.product.key,
                            'productName': item.product.name,
                            'unit': item.product.unit,
                            'quantity': item.quantity,
                            'unitPrice': item.product.price,
                            'lineTotal': item.product.price * item.quantity,
                          };
                        }).toList(),
                      });

                      if (!mounted) return;
                      cartProvider.clearCart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order placed successfully!'),
                        ),
                      );
                      Navigator.of(context).maybePop();
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to place order right now.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Daana.sans(size: 14, weight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Daana.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Daana.hairlineSoft),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Daana.hairlineSoft),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Daana.ink),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
