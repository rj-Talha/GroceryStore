import 'package:flutter/material.dart';
import '../data/products.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/price.dart';
import '../widgets/product_placeholder.dart';

import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int qty = 1;
  String variant = '1kg';

  static const _variants = [
    ('500g', '500 g', 170, null),
    ('1kg', '1 kg', 320, 'Most picked'),
    ('5kg', '5 kg box', 1480, 'Save Rs 120'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Daana.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const DaanaIcon('chevL', size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(children: const [
                      _CircleBtn(icon: 'heart'),
                      SizedBox(width: 8),
                      _CircleBtn(icon: 'bag'),
                    ]),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: ProductPlaceholder(
                    label: '${p.name.toLowerCase()} — hero',
                    tone: p.tone,
                    radius: 20,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(child: _Thumbnails(tone: p.tone)),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(child: _Header(product: p)),
            SliverToBoxAdapter(child: _VariantPicker(
              variant: variant,
              variants: _variants,
              onChange: (v) => setState(() => variant = v),
            )),
            SliverToBoxAdapter(child: _CTA(
              qty: qty,
              price: p.price,
              onDec: () => setState(() => qty = (qty - 1).clamp(1, 99)),
              onInc: () => setState(() => qty++),
              onAdd: () {
                cart.addItem(p, qty);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${p.name} added to cart'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  )
                );
              },
            )),
            SliverToBoxAdapter(child: const _MetaStrip()),
            SliverToBoxAdapter(child: const _RecipeIdeas()),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final String icon;
  const _CircleBtn({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Daana.card,
        shape: BoxShape.circle,
        border: Border.all(color: Daana.hairlineSoft),
      ),
      child: Center(child: DaanaIcon(icon, size: 16)),
    );
  }
}

class _Thumbnails extends StatelessWidget {
  final String tone;
  const _Thumbnails({required this.tone});

  @override
  Widget build(BuildContext context) {
    const labels = ['detail', 'flesh', 'in crate', 'scale'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(labels.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < labels.length - 1 ? 10 : 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: i == 0 ? Daana.ink : Daana.hairlineSoft,
                    width: i == 0 ? 1.5 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ProductPlaceholder(label: labels[i], tone: tone, radius: 10),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Product product;
  const _Header({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Eyebrow('Seasonal · peaks now'),
              const SizedBox(width: 8),
              Container(width: 4, height: 4, decoration: BoxDecoration(
                color: Daana.ink30, shape: BoxShape.circle,
              )),
              const SizedBox(width: 8),
              Text('Mirpurkhas · Sindh',
                  style: Daana.mono(size: 10.5, color: Daana.moss, letterSpacing: 1.4)),
            ],
          ),
          const SizedBox(height: 10),
          Text(product.name, style: Daana.serif(size: 44, height: 1.0)),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text('سندھڑی آم', style: Daana.urdu(size: 22, color: Daana.ink70)),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PriceText(value: product.price, size: 28),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'per kg · ~6 fruits',
                  style: Daana.sans(size: 12, color: Daana.ink50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Picked yesterday at first light from a 40-year-old orchard outside '
            'Mirpurkhas. Fibrous, honey-sweet, with a clean finish. Best eaten within '
            'four days of arrival.',
            style: Daana.sans(size: 14, color: Daana.ink70, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _VariantPicker extends StatelessWidget {
  final String variant;
  final List<(String, String, int, String?)> variants;
  final ValueChanged<String> onChange;
  const _VariantPicker({
    required this.variant,
    required this.variants,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Quantity'),
          const SizedBox(height: 10),
          Row(
            children: variants.map((v) {
              final active = variant == v.$1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: v == variants.last ? 0 : 8),
                  child: GestureDetector(
                    onTap: () => onChange(v.$1),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: active ? Daana.card : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active ? Daana.ink : Daana.hairlineSoft,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(v.$2, style: Daana.sans(size: 13, weight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          PriceText(value: v.$3, size: 12, color: Daana.ink70),
                          if (v.$4 != null) ...[
                            const SizedBox(height: 4),
                            Text(v.$4!.toUpperCase(),
                                style: Daana.mono(size: 9, color: Daana.moss, letterSpacing: 1.0)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CTA extends StatelessWidget {
  final int qty;
  final int price;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onAdd;
  const _CTA({required this.qty, required this.price, required this.onDec, required this.onInc, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Daana.hairline),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const DaanaIcon('minus', size: 16),
                  onPressed: onDec,
                ),
                SizedBox(
                  width: 28,
                  child: Center(
                    child: Text('$qty', style: Daana.sans(size: 16)),
                  ),
                ),
                IconButton(
                  icon: const DaanaIcon('plus', size: 16),
                  onPressed: onInc,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Btn(
              'Add · Rs ${Products.formatRs(price * qty)}',
              size: BtnSize.lg,
              iconRight: 'arrowR',
              full: true,
              onPressed: onAdd,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaStrip extends StatelessWidget {
  const _MetaStrip();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('truck', 'Today, 6–8 pm', 'Free over Rs 1,500'),
      ('leaf', 'Picked 22 May', 'Cold-stored 4°C'),
      ('check', '7-day freshness', '100% refund if not'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Daana.hairlineSoft),
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final it = items[i];
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: i < items.length - 1
                      ? Border(right: BorderSide(color: Daana.hairlineSoft))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DaanaIcon(it.$1, size: 16, color: Daana.moss),
                    const SizedBox(height: 6),
                    Text(it.$2, style: Daana.sans(size: 12)),
                    const SizedBox(height: 2),
                    Text(it.$3, style: Daana.sans(size: 11, color: Daana.ink50)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _RecipeIdeas extends StatelessWidget {
  const _RecipeIdeas();

  @override
  Widget build(BuildContext context) {
    const recipes = [
      ('Aam ka achaar', '6 ingredients · 30 m'),
      ('Mango lassi', '4 ingredients · 5 m'),
      ('Mango kulfi', '5 ingredients · 4 h'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Daana.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Daana.hairlineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DaanaIcon('sparkle', size: 14, color: Daana.moss),
                const SizedBox(width: 8),
                const Eyebrow('What to make with Sindhri'),
              ],
            ),
            const SizedBox(height: 12),
            ...recipes.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Daana.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Daana.hairlineSoft),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36, height: 36,
                          child: ProductPlaceholder(tone: 'c', radius: 6),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.$1, style: Daana.sans(size: 13)),
                              const SizedBox(height: 2),
                              Text(r.$2, style: Daana.sans(size: 11, color: Daana.ink50)),
                            ],
                          ),
                        ),
                        DaanaIcon('chevR', size: 14, color: Daana.ink50),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
