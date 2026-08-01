import 'package:flutter/material.dart';
import '../data/products.dart';
import '../theme/tokens.dart';
import 'daana_icon.dart';
import 'price.dart';
import 'product_placeholder.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool compact;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;
  final String? reason;
  final String? subtitle;

  const ProductCard({
    super.key,
    required this.product,
    this.compact = false,
    this.onAdd,
    this.onTap,
    this.reason,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            gradient: Daana.cardGradient,
            color: Daana.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Daana.hairlineSoft),
            boxShadow: Daana.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: ProductPlaceholder(
                      label: product.label,
                      tone: product.tone,
                      radius: 18,
                      imageUrl: product.imageUrl,
                    ),
                  ),
                  if (product.deal != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Daana.mossDark,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          '−${product.deal}%',
                          style: Daana.sans(size: 11, color: Daana.white, weight: FontWeight.w700),
                        ),
                      ),
                    ),
                  if (onAdd != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: _AddButton(onTap: onAdd!),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: Daana.sans(
                  size: compact ? 13 : 15,
                  color: Daana.ink,
                  weight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle ?? product.unit,
                style: Daana.sans(size: 12, color: Daana.ink60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (reason != null) ...[
                const SizedBox(height: 10),
                Text(
                  reason!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Daana.sans(size: 12, color: Daana.mossDark, height: 1.35),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PriceText(value: product.price, size: compact ? 15 : 16, color: Daana.ink),
                      if (product.old != null)
                        Text(
                          'Rs ${Products.formatRs(product.old!)}',
                          style: Daana.sans(size: 11, color: Daana.ink40).copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (product.deal == null)
                    const SizedBox(width: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Material(
        color: Daana.ink,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 30,
            height: 30,
            child: Center(child: DaanaIcon('plus', size: 14, color: Daana.bg)),
          ),
        ),
      ),
    );
  }
}
