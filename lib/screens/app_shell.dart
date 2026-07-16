import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/tokens.dart';
import '../widgets/daana_icon.dart';
import 'ai_ingredient_screen.dart';
import 'ai_recipe_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  static const _pages = [
    HomeScreen(),
    AIRecipeScreen(),
    AIIngredientScreen(),
    CartScreen(),
  ];

  static const _items = [
    ('home', 'Home'),
    ('sparkle', 'Recipes'),
    ('book', 'Cook'),
    ('bag', 'Cart'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Daana.bg,
            border: Border(top: BorderSide(color: Daana.hairlineSoft)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final on = i == _tab;
              final item = _items[i];
              return InkWell(
                onTap: () => setState(() => _tab = i),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          DaanaIcon(
                            item.$1,
                            size: 20,
                            color: on ? Daana.ink : Daana.ink50,
                          ),
                          if (i == 3)
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                width: 14,
                                height: 14,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Daana.moss,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '4',
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
                          color: on ? Daana.ink : Daana.ink50,
                        ),
                      ),
                    ],
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
