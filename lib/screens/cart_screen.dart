import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/checkout_screen.dart';
import '../services/firestore_service.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/price.dart';
import '../widgets/product_placeholder.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _firestoreService = FirestoreService();
  final Map<String, int> _stockShortages = {};
  bool _isCheckingStock = false;

  Future<void> _handleCheckout() async {
    final cart = context.read<CartProvider>();
    final items = cart.items;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty.')),
      );
      return;
    }

    setState(() {
      _isCheckingStock = true;
      _stockShortages.clear();
    });

    try {
      final shortages = await _findStockShortages(items);
      if (shortages.isEmpty) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _stockShortages
          ..clear()
          ..addAll(shortages);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Some items exceed available stock. Please update your cart.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCheckingStock = false);
      }
    }
  }

  Future<Map<String, int>> _findStockShortages(List<CartItem> items) async {
    final shortages = <String, int>{};

    for (final item in items) {
      final firebaseProduct = await _firestoreService.getProduct(item.product.key);
      final availableStock = firebaseProduct?.availableStock;
      if (availableStock != null && item.quantity > availableStock) {
        shortages[item.product.key] = availableStock;
      }
    }

    return shortages;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Container(
      color: Daana.bg,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Step 2 of 3 · Review'),
                    const SizedBox(height: 8),
                    Text('Your basket', style: Daana.serif(size: 40, height: 1.0)),
                    const SizedBox(height: 8),
                    Eyebrow('${items.length} items · Delivery today, 6 – 8 pm'),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: items.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Text(
                          'Your cart is empty',
                          style: Daana.sans(size: 16, color: Daana.ink50),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Daana.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Daana.hairlineSoft),
                        ),
                        child: Column(
                          children: [
                            ...List.generate(items.length, (i) {
                              final item = items[i];
                              final p = item.product;
                              final q = item.quantity;
                              final hasShortage = _stockShortages.containsKey(p.key);
                              final remainingStock = _stockShortages[p.key];
                              return Container(
                                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                                decoration: BoxDecoration(
                                  border: i < items.length - 1
                                      ? Border(
                                          bottom: BorderSide(
                                            color: hasShortage
                                                ? Colors.red.shade200
                                                : Daana.hairlineSoft,
                                          ),
                                        )
                                      : null,
                                  color: hasShortage
                                      ? Daana.bgAlt.withAlpha((0.8 * 255).round())
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: ProductPlaceholder(
                                        tone: p.tone,
                                        radius: 10,
                                        imageUrl: p.imageUrl,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: Daana.sans(
                                              size: 14,
                                              color: hasShortage ? Colors.red : Daana.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            p.unit,
                                            style: Daana.sans(
                                              size: 11.5,
                                              color: hasShortage ? Colors.red : Daana.ink50,
                                            ),
                                          ),
                                          if (hasShortage) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              'Remaining Stock in inventory is $remainingStock',
                                              style: Daana.sans(size: 11.5, color: Colors.red),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              _QtyControl(
                                                q: q,
                                                onDec: () => cart.updateQuantity(p.key, q - 1),
                                                onInc: () => cart.updateQuantity(p.key, q + 1),
                                              ),
                                              const Spacer(),
                                              PriceText(value: p.price * q, size: 14),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: DaanaIcon('close', size: 14, color: Daana.ink30),
                                      onPressed: () => cart.removeItem(p.key),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                              decoration: const BoxDecoration(
                                border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Delivery charges',
                                    style: Daana.sans(size: 14, weight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  PriceText(
                                    value: cart.deliveryFee + cart.serviceFee,
                                    size: 14,
                                    color: Daana.ink,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Daana.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Daana.hairlineSoft),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                      child: Row(
                        children: [
                          Text(
                            'Total',
                            style: Daana.sans(size: 16, weight: FontWeight.w600),
                          ),
                          const Spacer(),
                          PriceText(
                            value: cart.total,
                            size: 16,
                            color: Daana.ink,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (items.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Btn(
                    _isCheckingStock ? 'Checking stock...' : 'Checkout',
                    full: true,
                    size: BtnSize.lg,
                    iconRight: 'arrowR',
                    onPressed: _isCheckingStock ? null : _handleCheckout,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int q;
  final VoidCallback onDec;
  final VoidCallback onInc;

  const _QtyControl({required this.q, required this.onDec, required this.onInc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Daana.hairline),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onDec,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 32,
              height: 34,
              child: Center(child: DaanaIcon('minus', size: 13)),
            ),
          ),
          SizedBox(
            width: 24,
            child: Center(child: Text('$q', style: Daana.sans(size: 13))),
          ),
          InkWell(
            onTap: onInc,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: 32,
              height: 34,
              child: Center(child: DaanaIcon('plus', size: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
