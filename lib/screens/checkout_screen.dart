import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String _paymentMethod = 'Cash on delivery';

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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (value) {
                    final phone = (value ?? '').trim();
                    if (phone.isEmpty) {
                      return 'Required';
                    }
                    if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
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
                _buildPaymentOption(
                  title: 'Cash on delivery',
                  description: 'Pay when your order arrives.',
                  icon: Icons.local_shipping_outlined,
                ),
                const SizedBox(height: 10),
                _buildPaymentOption(
                  title: 'Online payment',
                  description: 'Pay securely online before delivery.',
                  icon: Icons.credit_card_outlined,
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

                    if (_paymentMethod == 'Online payment') {
                      final paymentCompleted =
                          await _showDummyStripePaymentSheet(
                            cartProvider.total,
                          );
                      if (!paymentCompleted || !mounted) return;
                    }

                    try {
                      final orderItems = cartProvider.items.map((item) {
                        return {
                          'productId': item.product.key,
                          'productName': item.product.name,
                          'unit': item.product.unit,
                          'quantity': item.quantity,
                          'unitPrice': item.product.price,
                          'lineTotal': item.product.price * item.quantity,
                        };
                      }).toList();

                      await _firestoreService.addOrder({
                        'customerName':
                            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
                                .trim(),
                        'phone': _phoneController.text.trim(),
                        'email': _emailController.text.trim(),
                        'address': _addressController.text.trim(),
                        'paymentMethod': _paymentMethod,
                        'paymentStatus': _paymentMethod == 'Online payment'
                            ? 'paid'
                            : 'pending',
                        'status': 'processing',
                        'subtotal': cartProvider.subtotal,
                        'deliveryFee': cartProvider.deliveryFee,
                        'serviceFee': cartProvider.serviceFee,
                        'total': cartProvider.total,
                        'createdAt': DateTime.now().toIso8601String(),
                        'items': orderItems,
                      });
                      await _firestoreService.updateStockAfterOrder(orderItems);

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

  Future<bool> _showDummyStripePaymentSheet(num total) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DummyStripePaymentSheet(total: total),
    );

    return result ?? false;
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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
              borderSide: BorderSide(color: Daana.ink),
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

  Widget _buildPaymentOption({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == title;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _paymentMethod = title),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Daana.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Daana.ink : Daana.hairlineSoft,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Daana.sans(size: 14, weight: FontWeight.w600),
                  ),
                  Text(
                    description,
                    style: Daana.sans(size: 12, color: Daana.ink50),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: title,
              groupValue: _paymentMethod,
              activeColor: Daana.ink,
              onChanged: (value) {
                if (value != null) setState(() => _paymentMethod = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = digits;

    if (digits.length > 2) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length == 2) {
      formatted = '$digits/';
    }

    if (formatted.length > 5) {
      formatted = formatted.substring(0, 5);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DummyStripePaymentSheet extends StatefulWidget {
  final num total;

  const _DummyStripePaymentSheet({required this.total});

  @override
  State<_DummyStripePaymentSheet> createState() =>
      _DummyStripePaymentSheetState();
}

class _DummyStripePaymentSheetState extends State<_DummyStripePaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardInset + 16),
      child: Material(
        color: Daana.card,
        borderRadius: BorderRadius.circular(22),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF635BFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.payment, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Stripe test payment',
                        style: Daana.sans(size: 17, weight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _isProcessing
                            ? null
                            : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Demo only — no money will be charged.',
                    style: Daana.sans(size: 12, color: Daana.ink50),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Card number'),
                    validator: (value) {
                      final digits = (value ?? '').replaceAll(
                        RegExp(r'\D'),
                        '',
                      );
                      return digits.length >= 16
                          ? null
                          : 'Enter a test card number';
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [_ExpiryDateInputFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'MM / YY',
                          ),
                          validator: (value) {
                            final raw = (value ?? '')
                                .replaceAll('/', '')
                                .trim();
                            if (raw.length != 4) {
                              return 'Required';
                            }

                            final month = int.tryParse(raw.substring(0, 2));
                            final year = int.tryParse(raw.substring(2));
                            if (month == null ||
                                year == null ||
                                month < 1 ||
                                month > 12) {
                              return 'Enter a valid month/year';
                            }

                            final currentYear = DateTime.now().year % 100;
                            final currentMonth = DateTime.now().month;
                            final expiryYear = year;
                            final expiryMonth = month;

                            if (expiryYear < currentYear ||
                                (expiryYear == currentYear &&
                                    expiryMonth < currentMonth)) {
                              return 'Enter a valid month/year';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'CVC'),
                          validator: (value) => (value ?? '').trim().length >= 3
                              ? null
                              : 'Required',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF635BFF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _isProcessing ? null : _pay,
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text('Pay Rs. ${widget.total.toStringAsFixed(0)}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
