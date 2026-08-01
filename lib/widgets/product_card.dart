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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: Daana.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Daana.hairlineSoft, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductPlaceholder(label: product.label, tone: product.tone, radius: 12, imageUrl: product.imageUrl),
                if (product.deal != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Daana.ink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '−${product.deal}%',
                        style: Daana.mono(size: 9, color: Daana.bg, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                if (onAdd != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: _AddButton(onTap: onAdd!),
                  ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            Text(
              product.name,
              style: Daana.sans(
                size: compact ? 13 : 14,
                color: Daana.ink,
                height: 1.25,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if ((product.quantity ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Quantity: ${product.quantity!.trim()}',
                style: Daana.sans(size: 11.2, color: Daana.ink50),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 2),
            Text(
              subtitle ?? product.unit,
              style: Daana.sans(size: 11.5, color: Daana.ink50),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (reason != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Daana.hairlineSoft)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DaanaIcon('sparkle', size: 11, color: Daana.moss),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        reason!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Daana.sans(size: 11.5, color: Daana.moss, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: compact ? 8 : 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriceText(value: product.price, size: compact ? 14 : 15),
                if (product.old != null)
                  Text(
                    'Rs ${Products.formatRs(product.old!)}',
                    style: Daana.sans(size: 11, color: Daana.ink30).copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ],
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
