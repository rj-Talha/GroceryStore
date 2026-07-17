import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/tokens.dart';
import 'daana_icon.dart';

final activeAppTab = ValueNotifier<int>(0);

class AppFooter extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppFooter({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
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
      child: Container(
        decoration: BoxDecoration(
          color: Daana.bg,
          border: Border(top: BorderSide(color: Daana.hairlineSoft)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final isSelected = index == selectedIndex;
            final item = _items[index];
            return InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        DaanaIcon(
                          item.$1,
                          size: 20,
                          color: isSelected ? Daana.ink : Daana.ink50,
                        ),
                        if (index == 3 && productCount > 0)
                          Positioned(
                            top: -4,
                            right: -6,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 14),
                              height: 14,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: const BoxDecoration(
                                color: Daana.moss,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$productCount',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Daana.bg,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: Daana.sans(
                        size: 10.5,
                        color: isSelected ? Daana.ink : Daana.ink50,
                      ),
                    ),
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
