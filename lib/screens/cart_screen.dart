import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/checkout_screen.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/price.dart';
import '../widgets/product_placeholder.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                              return Container(
                                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                                decoration: BoxDecoration(
                                  border: i < items.length - 1
                                      ? Border(bottom: BorderSide(color: Daana.hairlineSoft))
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
                                          Text(p.name, style: Daana.sans(size: 14)),
                                          const SizedBox(height: 2),
                                          Text(
                                            p.unit,
                                            style: Daana.sans(size: 11.5, color: Daana.ink50),
                                          ),
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
                    'Checkout',
                    full: true,
                    size: BtnSize.lg,
                    iconRight: 'arrowR',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      );
                    },
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
