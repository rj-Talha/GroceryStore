import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/products.dart';
import '../providers/catalog_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String q = '';
  String sort = 'popular';
  
  final TextEditingController _searchController = TextEditingController();

  static const _filters = {
    'Category': [
      ('Leafy greens', 12, true),
      ('Herbs', 8, false),
      ('Frozen', 3, false),
      ('Tomato & pepper', 14, false),
      ('Onion & garlic', 9, false),
    ],
    'Sourcing': [
      ('Local · Sindh', 22, true),
      ('Local · Punjab', 31, false),
      ('Organic certified', 7, false),
    ],
    'Price': [
      ('Under Rs 100', 18, false),
      ('Rs 100 – 250', 24, false),
      ('Rs 250 +', 11, false),
    ],
  };
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final cart = context.read<CartProvider>();
    final results = catalog.search(q);
    final width = MediaQuery.of(context).size.width;
    
    final crossAxisCount = width >= 1200 ? 4 : (width >= 800 ? 3 : 2);
    
    final childAspectRatio = width >= 1200 ? 0.75 : (width >= 800 ? 0.80 : 0.68);

    return Scaffold(
      backgroundColor: Daana.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _AppBar(
                controller: _searchController,
                onBack: () => Navigator.pop(context),
                onChanged: (val) => setState(() => q = val),
              )
            ),
            if (q.isNotEmpty) SliverToBoxAdapter(child: _Breadcrumb(q: q)),
            SliverToBoxAdapter(child: _Header(q: q, count: results.length)),
            SliverToBoxAdapter(child: _SortRow(sort: sort, onChange: (v) => setState(() => sort = v))),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (q.toLowerCase() == 'palak') const SliverToBoxAdapter(child: _AISuggestion()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProductCard(
                    product: results[i],
                    onAdd: () => cart.addItem(results[i]),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: results[i]),
                      ),
                    ),
                  ),
                  childCount: results.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: _FiltersBlock(filters: _filters)),
          ],
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;
  
  const _AppBar({required this.controller, required this.onBack, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            icon: const DaanaIcon('chevL', size: 20),
            onPressed: onBack,
          ),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Daana.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Daana.hairline),
              ),
              child: Row(
                children: [
                  DaanaIcon('search', size: 15, color: Daana.ink50),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: Daana.sans(size: 14, color: Daana.ink30),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: Daana.sans(size: 14, color: Daana.ink),
                    ),
                  ),
                  DaanaIcon('mic', size: 15, color: Daana.ink50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  final String q;
  const _Breadcrumb({required this.q});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Text('Shop', style: Daana.sans(size: 12, color: Daana.ink50)),
          const SizedBox(width: 6),
          DaanaIcon('chevR', size: 12, color: Daana.ink30),
          const SizedBox(width: 6),
          Text('Search', style: Daana.sans(size: 12, color: Daana.ink50)),
          const SizedBox(width: 6),
          DaanaIcon('chevR', size: 12, color: Daana.ink30),
          const SizedBox(width: 6),
          Text('"$q"', style: Daana.sans(size: 12, color: Daana.ink)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String q;
  final int count;
  const _Header({required this.q, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Search results'),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: q.isEmpty ? 'All Products' : '"$q"', style: Daana.serif(size: 40, height: 1.0)),
                TextSpan(
                  text: '  · $count',
                  style: Daana.serif(size: 40, color: Daana.ink30, height: 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  final String sort;
  final ValueChanged<String> onChange;
  const _SortRow({required this.sort, required this.onChange});

  @override
  Widget build(BuildContext context) {
    Widget pill(String id, String label) {
      final active = sort == id;
      return GestureDetector(
        onTap: () => onChange(id),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Daana.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: Daana.sans(size: 13, color: active ? Daana.bg : Daana.ink70),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Eyebrow('Sort'),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Daana.card,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Daana.hairlineSoft),
            ),
            child: Row(
              children: [
                pill('popular', 'Popular'),
                pill('price', 'Price'),
                pill('fresh', 'Freshest'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AISuggestion extends StatelessWidget {
  const _AISuggestion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Daana.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Daana.moss, width: 1, style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Daana.moss,
                shape: BoxShape.circle,
              ),
              child: const Center(child: DaanaIcon('sparkle', size: 16, color: Daana.bg)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Daana.sans(size: 13.5, color: Daana.ink),
                      children: [
                        const TextSpan(text: 'Cooking '),
                        TextSpan(
                          text: 'palak paneer',
                          style: Daana.sans(size: 13.5, color: Daana.ink)
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                        const TextSpan(text: '? Add 6 ingredients in one tap.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'For 4 servings · Rs 1,180',
                    style: Daana.sans(size: 11.5, color: Daana.ink50),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Btn(
              'Add',
              variant: BtnVariant.moss,
              size: BtnSize.sm,
              iconRight: 'arrowR',
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersBlock extends StatelessWidget {
  final Map<String, List<(String, int, bool)>> filters;
  const _FiltersBlock({required this.filters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Filters'),
          const SizedBox(height: 12),
          ...filters.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(e.key),
                  const SizedBox(height: 10),
                  ...e.value.map((it) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: it.$3 ? Daana.ink : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: it.$3 ? Daana.ink : Daana.hairline,
                                width: 1.5,
                              ),
                            ),
                            child: it.$3
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              it.$1,
                              style: Daana.sans(size: 13.5, color: Daana.ink),
                            ),
                          ),
                          Text(
                            '${it.$2}',
                            style: Daana.mono(size: 10.5, color: Daana.ink30),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
