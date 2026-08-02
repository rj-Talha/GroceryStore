import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/tokens.dart';
import 'daana_icon.dart';

final activeAppTab = ValueNotifier<int>(0);

class AppFooter extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final LinearGradient? backgroundGradient;

  const AppFooter({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.backgroundGradient,
  });

  static const _items = [
    ('home', 'Home'),
    ('sparkle', 'Recipes'),
    ('book', 'Cook'),
    ('bag', 'Cart'),
  ];

  @override
  Widget build(BuildContext context) {
    final productCount = context.watch<CartProvider>().items.length;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: backgroundGradient ?? const LinearGradient(
              colors: [Daana.bgAlt, Daana.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Daana.hairlineSoft),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (index) {
              final isSelected = index == selectedIndex;
              final item = _items[index];
              return Expanded(
                child: AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: GestureDetector(
                    onTap: () => onSelected(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: isSelected ? Daana.moss : Daana.glass,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? Daana.mossDark.withAlpha(80) : Daana.hairlineSoft),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Daana.moss.withAlpha(24),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              DaanaIcon(
                                item.$1,
                                size: 20,
                                color: isSelected ? Daana.white : Daana.ink60,
                              ),
                              if (index == 3 && productCount > 0)
                                Positioned(
                                  top: 4,
                                  right: 6,
                                  child: Container(
                                    constraints: const BoxConstraints(minWidth: 16),
                                    height: 16,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: const BoxDecoration(
                                      color: Daana.moss,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$productCount',
                                      style: Daana.sans(size: 10, color: Daana.white, weight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          style: Daana.sans(
                            size: 11,
                            color: isSelected ? Daana.mossDark : Daana.ink60,
                            weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
