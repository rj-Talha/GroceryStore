import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/products.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../services/ai_service.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/price.dart';
import '../widgets/product_placeholder.dart';
import 'saved_recipes_screen.dart';

class AIIngredientScreen extends StatefulWidget {
  const AIIngredientScreen({super.key});

  @override
  State<AIIngredientScreen> createState() => _AIIngredientScreenState();
}

class _Ingredient {
  final Product product;
  final String reqQty;
  final bool on;
  const _Ingredient(this.product, this.reqQty, this.on);
}

class _AIIngredientScreenState extends State<AIIngredientScreen> {
  final _aiService = AIService();
  final TextEditingController _controller = TextEditingController();

  int servings = 4;
  String _dish = 'Chicken karahi';
  bool _isLoading = false;

  List<_Ingredient> ingredients = [];

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchIngredients() async {
    if (_dish.isEmpty) return;
    setState(() => _isLoading = true);

    // We need access to the catalog
    final catalog = Provider.of<CatalogProvider>(context, listen: false);

    final results = await _aiService.getIngredientsForDish(
      '$_dish for $servings',
      catalog.allProducts,
    );

    if (mounted) {
      setState(() {
        ingredients = results
            .map((e) => _Ingredient(e.$1, e.$2, true))
            .toList();
        _isLoading = false;
      });
    }
  }

  void _onSearch(String val) {
    if (val.trim().isEmpty) return;
    setState(() {
      _dish = val.trim();
    });
    _fetchIngredients();
  }

  void _toggle(int i) {
    setState(() {
      final it = ingredients[i];
      ingredients[i] = _Ingredient(it.product, it.reqQty, !it.on);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = ingredients
        .where((i) => i.on)
        .fold<int>(0, (s, i) => s + i.product.price);
    final onCount = ingredients.where((i) => i.on).length;

    return Scaffold(
      backgroundColor: Daana.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HomeAppBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const DaanaIcon('chevL', size: 20),
                      onPressed: () => Navigator.maybePop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Daana.moss,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: DaanaIcon('book', size: 14, color: Daana.bg),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Eyebrow('Assistant · Ingredients'),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _SearchBox(controller: _controller, onSearch: _onSearch),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Eyebrow(
                            '${ingredients.length} matched · $onCount selected',
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  _dish,
                                  style: Daana.serif(size: 32, height: 1.0),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Eyebrow('Serves'),
                        const SizedBox(height: 6),
                        Container(
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Daana.hairline),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (servings > 1) {
                                    setState(() => servings--);
                                    _fetchIngredients();
                                  }
                                },
                                customBorder: const CircleBorder(),
                                child: const SizedBox(
                                  width: 32,
                                  height: 36,
                                  child: Center(
                                    child: DaanaIcon('minus', size: 14),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                child: Center(
                                  child: Text(
                                    '$servings',
                                    style: Daana.sans(size: 14),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() => servings++);
                                  _fetchIngredients();
                                },
                                customBorder: const CircleBorder(),
                                child: const SizedBox(
                                  width: 32,
                                  height: 36,
                                  child: Center(
                                    child: DaanaIcon('plus', size: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: Daana.moss),
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: _IngredientList(
                  ingredients: ingredients,
                  onToggle: _toggle,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _Summary(
                  subtotal: subtotal,
                  count: onCount,
                  onAddAll: () {
                    final cart = context.read<CartProvider>();
                    for (var item in ingredients.where((i) => i.on)) {
                      cart.addItem(item.product, 1);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$onCount items added to cart'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _Sized(servings: servings, dish: _dish),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  const _SearchBox({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        decoration: BoxDecoration(
          color: Daana.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Daana.hairlineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DaanaIcon('sparkle', size: 16, color: Daana.moss),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: onSearch,
                    decoration: InputDecoration(
                      hintText: 'e.g. "Chicken Karahi for 4"',
                      hintStyle: Daana.serif(
                        size: 22,
                        color: Daana.ink30,
                        height: 1.0,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: Daana.serif(size: 22, height: 1.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Btn(
                'Find ingredients',
                size: BtnSize.md,
                iconRight: 'arrowR',
                onPressed: () => onSearch(controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientList extends StatelessWidget {
  final List<_Ingredient> ingredients;
  final ValueChanged<int> onToggle;
  const _IngredientList({required this.ingredients, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Daana.card,
            border: Border.all(color: Daana.hairlineSoft),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                decoration: BoxDecoration(
                  color: Daana.bgAlt,
                  border: Border(bottom: BorderSide(color: Daana.hairlineSoft)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Daana.ink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: DaanaIcon(
                          'check',
                          size: 11,
                          color: Daana.bg,
                          stroke: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: Text(
                        'INGREDIENT',
                        style: Daana.mono(
                          size: 10,
                          letterSpacing: 1.4,
                          color: Daana.ink50,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'PRICE',
                        textAlign: TextAlign.right,
                        style: Daana.mono(
                          size: 10,
                          letterSpacing: 1.4,
                          color: Daana.ink50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (ingredients.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No ingredients found.',
                    style: Daana.sans(size: 13, color: Daana.ink50),
                  ),
                ),
              ...List.generate(ingredients.length, (i) {
                final it = ingredients[i];
                final p = it.product;
                return InkWell(
                  onTap: () => onToggle(i),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: it.on
                          ? Colors.transparent
                          : Daana.ink.withOpacity(0.02),
                      border: i < ingredients.length - 1
                          ? Border(
                              bottom: BorderSide(color: Daana.hairlineSoft),
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: it.on ? Daana.ink : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: it.on ? Daana.ink : Daana.hairline,
                              width: 1.5,
                            ),
                          ),
                          child: it.on
                              ? const Center(
                                  child: DaanaIcon(
                                    'check',
                                    size: 11,
                                    color: Daana.bg,
                                    stroke: 2,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: ProductPlaceholder(
                            tone: p.tone,
                            radius: 6,
                            imageUrl: p.imageUrl,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: Daana.sans(
                                  size: 13,
                                  color: it.on ? Daana.ink : Daana.ink50,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${it.reqQty} · sells: ${p.quantity?.trim().isNotEmpty == true ? p.quantity!.trim() : p.unit}',
                                style: Daana.sans(size: 11, color: Daana.ink50),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PriceText(
                          value: p.price,
                          size: 13,
                          color: it.on ? Daana.ink : Daana.ink50,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final int subtotal;
  final int count;
  final VoidCallback onAddAll;
  const _Summary({
    required this.subtotal,
    required this.count,
    required this.onAddAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Daana.ink,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Eyebrow('You add', color: Daana.bg.withOpacity(0.55)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs ${Products.formatRs(subtotal)}',
                  style: Daana.serif(size: 40, color: Daana.bg, height: 1.0),
                ),
                Text(
                  '$count items',
                  style: Daana.sans(size: 12, color: Daana.bg.withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Plus what's already in your pantry. Delivery today, 6 – 8 pm.",
              style: Daana.sans(
                size: 13,
                color: Daana.bg.withOpacity(0.7),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Btn(
              'Add all to cart',
              variant: BtnVariant.light,
              full: true,
              size: BtnSize.lg,
              iconRight: 'arrowR',
              onPressed: onAddAll,
            ),
          ],
        ),
      ),
    );
  }
}

class _Sized extends StatelessWidget {
  final int servings;
  final String dish;
  const _Sized({required this.servings, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            const Eyebrow('How Daana sized this'),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: Daana.sans(size: 13, color: Daana.ink70, height: 1.55),
                children: [
                  const TextSpan(text: 'Scaled for '),
                  TextSpan(
                    text: '$servings servings',
                    style: Daana.sans(
                      size: 13,
                      color: Daana.ink,
                      weight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' of $dish.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
