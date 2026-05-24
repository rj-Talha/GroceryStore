import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/products.dart';
import '../providers/cart_provider.dart';
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
  int _selectedPay = 2; // card

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
                    Eyebrow(
                        '${items.length} items · Delivery today, 6 – 8 pm'),
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
                    child: Text('Your cart is empty', style: Daana.sans(size: 16, color: Daana.ink50)),
                  )
                : Container(
                  decoration: BoxDecoration(
                    color: Daana.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Daana.hairlineSoft),
                  ),
                  child: Column(
                    children: List.generate(items.length, (i) {
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
                              width: 56, height: 56,
                              child: ProductPlaceholder(tone: p.tone, radius: 10),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: Daana.sans(size: 14)),
                                  const SizedBox(height: 2),
                                  Text(p.unit,
                                      style: Daana.sans(size: 11.5, color: Daana.ink50)),
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
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (items.isNotEmpty)
              SliverToBoxAdapter(child: _Summary(
                subtotal: cart.subtotal,
                delivery: cart.deliveryFee,
                service: cart.serviceFee,
                total: cart.total,
                selectedPay: _selectedPay,
                onPay: (i) => setState(() => _selectedPay = i),
              )),
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
              width: 32, height: 34,
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
              width: 32, height: 34,
              child: Center(child: DaanaIcon('plus', size: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int subtotal;
  final int delivery;
  final int service;
  final int total;
  final int selectedPay;
  final ValueChanged<int> onPay;
  const _Summary({
    required this.subtotal,
    required this.delivery,
    required this.service,
    required this.total,
    required this.selectedPay,
    required this.onPay,
  });

  static const _payments = [
    ('Cash on delivery', 'Pay the rider'),
    ('JazzCash', '0300 ••• ••12'),
    ('Debit / credit card', 'Visa •• 4421'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Daana.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Daana.hairlineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Eyebrow('Order summary'),
            const SizedBox(height: 14),
            _row('Subtotal', 'Rs ${Products.formatRs(subtotal)}'),
            _row('Delivery', delivery == 0 ? 'Free' : 'Rs $delivery',
                accent: delivery == 0 ? Daana.moss : null),
            _row('Service fee', 'Rs $service'),
            const SizedBox(height: 6),
            Container(height: 1, color: Daana.hairlineSoft),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: Daana.sans(size: 14)),
                PriceText(value: total, size: 22),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: Daana.hairlineSoft),
            const SizedBox(height: 16),
            const Eyebrow('Delivering to'),
            const SizedBox(height: 6),
            Text(
              'House 47-C, Khayaban-e-Bukhari\nDHA Phase VI, Karachi',
              style: Daana.sans(size: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: Daana.hairlineSoft),
            const SizedBox(height: 16),
            const Eyebrow('Payment'),
            const SizedBox(height: 8),
            ...List.generate(_payments.length, (i) {
              final m = _payments[i];
              final sel = selectedPay == i;
              return InkWell(
                onTap: () => onPay(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: sel ? Daana.ink : Daana.hairline,
                            width: 1.5,
                          ),
                        ),
                        child: sel
                            ? Center(
                                child: Container(
                                  width: 7, height: 7,
                                  decoration: const BoxDecoration(
                                    color: Daana.ink, shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.$1, style: Daana.sans(size: 13)),
                            Text(m.$2,
                                style: Daana.sans(size: 11, color: Daana.ink50)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Btn(
              'Place order',
              full: true, size: BtnSize.lg, iconRight: 'arrowR',
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            Text(
              "Free re-delivery for any item that doesn't meet our freshness bar.",
              textAlign: TextAlign.center,
              style: Daana.sans(size: 11, color: Daana.ink50, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v, {Color? accent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: Daana.sans(size: 14, color: Daana.ink70)),
          Text(v, style: Daana.sans(size: 14, color: accent ?? Daana.ink)),
        ],
      ),
    );
  }
}
