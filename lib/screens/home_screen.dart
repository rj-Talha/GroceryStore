import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/products.dart';
import '../providers/catalog_provider.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/product_card.dart';
import '../widgets/product_placeholder.dart';
import 'product_detail_screen.dart';
import 'search_screen.dart';
import 'voice_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    
    if (catalog.isLoading) {
      return Container(
        color: Daana.bg,
        child: const Center(
          child: CircularProgressIndicator(color: Daana.moss),
        ),
      );
    }
    
    final trending = catalog.trendingProducts;
    final topTrending = trending.isNotEmpty ? trending.first : null;

    return Container(
      color: Daana.bg,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AddressBar(),
              const SizedBox(height: 12),
              const _SearchBar(),
              const SizedBox(height: 16),
              if (topTrending != null) _HeroCard(product: topTrending),
              const SizedBox(height: 24),
              const _CategoriesSection(),
              const SizedBox(height: 20),
              const _AITile(),
              const SizedBox(height: 24),
              const _RecommendationsSection(),
              const SizedBox(height: 24),
              const _MangoList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressBar extends StatelessWidget {
  const _AddressBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Delivering today, 6 – 8 pm', size: 9.5),
                const SizedBox(height: 4),
                Row(
                  children: [
                    DaanaIcon('pin', size: 15, color: Daana.moss),
                    const SizedBox(width: 6),
                    Text('DHA Phase VI', style: Daana.sans(size: 15)),
                    const SizedBox(width: 4),
                    DaanaIcon('chevD', size: 14, color: Daana.ink50),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Daana.card,
              shape: BoxShape.circle,
              border: Border.all(color: Daana.hairlineSoft),
            ),
            child: const Center(child: DaanaIcon('user', size: 17)),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Daana.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Daana.hairlineSoft),
                ),
                child: Row(
                  children: [
                    DaanaIcon('search', size: 16, color: Daana.ink50),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search "ٹماٹر" or "atta"',
                        style: Daana.sans(size: 14, color: Daana.ink50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => showVoiceModal(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Daana.ink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: DaanaIcon('mic', size: 18, color: Daana.bg),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final Product product;
  const _HeroCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Daana.ink,
          padding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                right: -28,
                top: 16,
                child: Opacity(
                  opacity: 0.9,
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: ClipOval(
                      child: ProductPlaceholder(
                        label: product.label,
                        tone: product.tone,
                        radius: 70,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(
                    'Trending this week',
                    color: Daana.bg.withOpacity(0.55),
                    size: 9.5,
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: RichText(
                      text: TextSpan(
                        style: Daana.serif(
                          size: 38,
                          color: Daana.bg,
                          height: 0.95,
                        ),
                        children: [
                          TextSpan(text: '${product.name.split(' ')[0]} are '),
                          TextSpan(
                            text: 'trending.',
                            style: Daana.serif(
                              size: 38,
                              color: Daana.goldHighlight,
                              style: FontStyle.italic,
                              height: 0.95,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      'Everyone is buying ${product.name.toLowerCase()} right now. Delivered today.',
                      style: Daana.sans(
                        size: 13,
                        color: Daana.bg.withOpacity(0.7),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Btn(
                    'Shop now',
                    variant: BtnVariant.light,
                    size: BtnSize.sm,
                    iconRight: 'arrowR',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  /// (English, Urdu, tone, IconData) — Material Icons are bundled with Flutter.
  static const cats = <(String, String, String, IconData)>[
    ('Fruits', 'پھل', 'c', Icons.apple),
    ('Veg', 'سبزی', 'b', Icons.eco),
    ('Meat', 'گوشت', 'a', Icons.set_meal),
    ('Dairy', 'دودھ', 'd', Icons.egg_alt),
    ('Bakery', 'بیکری', 'c', Icons.bakery_dining),
    ('Pantry', 'راشن', 'd', Icons.rice_bowl),
    ('Drinks', 'مشروبات', 'b', Icons.local_drink),
    ('Home', 'گھر', 'e', Icons.cleaning_services),
  ];

  static const _toneBg = {
    'a': Color(0xFFE8E2D2),
    'b': Color(0xFFDDE2D5),
    'c': Color(0xFFEBDFD0),
    'd': Color(0xFFE0DED7),
    'e': Color(0xFFD8DBD3),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: Daana.serif(size: 22, height: 1.0)),
              Text('See all', style: Daana.sans(size: 12, color: Daana.moss)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
            children: cats.map((c) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Daana.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Daana.hairlineSoft),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _toneBg[c.$3],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(c.$4, size: 26, color: Daana.mossInk),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.$1,
                      style: Daana.sans(size: 11.5, height: 1.1),
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(
                        c.$2,
                        style: Daana.urdu(
                          size: 11,
                          color: Daana.ink50,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AITile extends StatelessWidget {
  const _AITile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Daana.mossInk,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DaanaIcon(
                  'sparkle',
                  size: 13,
                  color: Daana.bg.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Eyebrow(
                  'Assistant',
                  color: Daana.bg.withOpacity(0.55),
                  size: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                "What's in your fridge tonight?",
                style: Daana.serif(size: 26, color: Daana.bg, height: 1.05),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll suggest three things to cook.",
              style: Daana.sans(
                size: 12.5,
                color: Daana.bg.withOpacity(0.7),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Daana.bg.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Daana.bg.withOpacity(0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Open assistant',
                    style: Daana.sans(size: 13, color: Daana.bg),
                  ),
                  const SizedBox(width: 6),
                  DaanaIcon('arrowR', size: 13, color: Daana.bg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsSection extends StatelessWidget {
  const _RecommendationsSection();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final recs = catalog.recommendations;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('For you', size: 9.5),
              const SizedBox(height: 2),
              Text(
                'Picked for your pantry',
                style: Daana.serif(size: 22, height: 1.0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 270,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: recs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final (p, reason) = recs[i];
              return SizedBox(
                width: 168,
                child: ProductCard(
                  product: p,
                  reason: reason,
                  compact: true,
                  onAdd: () {},
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: p),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MangoList extends StatelessWidget {
  const _MangoList();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final mangoes = catalog.seasonalMangoes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('In season · May', size: 9.5),
          const SizedBox(height: 2),
          Text('The mango list', style: Daana.serif(size: 22, height: 1.0)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.7,
            children: mangoes
                .map(
                  (p) => ProductCard(product: p, onAdd: () {}, compact: true),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
