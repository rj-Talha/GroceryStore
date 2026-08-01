import 'dart:math';
import 'package:flutter/material.dart';
import '../data/products.dart';
import '../providers/catalog_provider.dart';
import '../services/catalog_generator.dart';
import '../services/firestore_service.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/app_footer.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/price.dart';
import '../widgets/product_placeholder.dart';

import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'saved_recipes_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int qty = 1;
  Product? _resolvedProduct;
  List<Product> _recommendations = [];
  bool _hasInitialized = false;
  bool _isLoadingProduct = false;
  late String _mainImageUrl;
  late List<String> _thumbnailImageUrls;
  int _selectedThumbnailIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeGallery(widget.product);
  }

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.key != widget.product.key) {
      _initializeGallery(widget.product);
    }
  }

  void _initializeGallery(Product product) {
    final detail = _detailContent(product);
    _mainImageUrl = detail['imageUrl'] as String;
    _thumbnailImageUrls =
        List<String>.from(detail['thumbnailImageUrls'] as List<dynamic>);
    _selectedThumbnailIndex = 0;
  }

  void _swapMainImageWithThumbnail(int index) {
    if (index < 0 || index >= _thumbnailImageUrls.length) return;

    setState(() {
      final selectedImageUrl = _thumbnailImageUrls[index];
      _thumbnailImageUrls[index] = _mainImageUrl;
      _mainImageUrl = selectedImageUrl;
      _selectedThumbnailIndex = index;
    });
  }

  void _onFooterSelected(int index) {
    activeAppTab.value = index;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _setupRecommendations();
      _loadFirebaseProductIfNeeded();
    }
  }

  void _setupRecommendations() {
    final catalog = context.read<CatalogProvider>();
    final candidates = catalog.allProducts.where((p) => p.key != widget.product.key).toList();
    if (candidates.isEmpty) {
      _recommendations = [];
      return;
    }
    candidates.shuffle(Random(widget.product.key.hashCode ^ DateTime.now().millisecondsSinceEpoch));
    _recommendations = candidates.take(candidates.length > 4 ? 4 : candidates.length).toList();
  }

  bool _needsFirebaseRefresh(Product product) {
    return product.urduName == null ||
        product.description == null ||
        product.quantity == null ||
        product.whatYouCanMake == null ||
        product.thumbnailImageUrls == null ||
        product.thumbnailImageUrls!.isEmpty;
  }

  Future<void> _loadFirebaseProductIfNeeded() async {
    final initialProduct = widget.product;
    if (!_needsFirebaseRefresh(initialProduct)) return;

    setState(() {
      _isLoadingProduct = true;
    });

    try {
      final firebaseProduct = await FirestoreService().getProduct(initialProduct.key);
      if (firebaseProduct != null && mounted) {
        setState(() {
          _resolvedProduct = firebaseProduct;
          _initializeGallery(firebaseProduct);
        });
      }
    } catch (e) {
      // Ignore fetch failures; fallback content will still display.
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProduct = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _resolvedProduct ?? widget.product;
    final cart = context.watch<CartProvider>();
    final detail = _detailContent(p);
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: Daana.bg,
      bottomNavigationBar: AppFooter(
        selectedIndex: 0,
        onSelected: _onFooterSelected,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: isDesktop ? _desktopSlivers(p, detail, cart) : [
            const SliverToBoxAdapter(child: HomeAppBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
                    Row(
                      children: [
                        const _CircleBtn(icon: 'heart'),
                        const SizedBox(width: 8),
                        const _CircleBtn(icon: 'bag'),
                      ],
                    ),
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
                    imageUrl: _mainImageUrl,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Thumbnails(
                  tone: p.tone,
                  imageUrls: _thumbnailImageUrls,
                  selectedIndex: _selectedThumbnailIndex,
                  onTap: _swapMainImageWithThumbnail,
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            SliverToBoxAdapter(child: _Header(product: p, detail: detail)),
            SliverToBoxAdapter(child: _RecommendedItems(recommendations: _recommendations)),
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
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  List<Widget> _desktopSlivers(
    Product product,
    Map<String, dynamic> detail,
    CartProvider cart,
  ) {
    return [
      const SliverToBoxAdapter(child: HomeAppBar()),
      SliverToBoxAdapter(
        child: _DesktopContent(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
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
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 11,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ProductPlaceholder(
                        label: '${product.name.toLowerCase()} â€” hero',
                        tone: product.tone,
                        radius: 24,
                        imageUrl: _mainImageUrl,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                  Expanded(
                    flex: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(product: product, detail: detail, desktop: true),
                        const SizedBox(height: 22),
                        _CTA(
                          qty: qty,
                          price: product.price,
                          padding: EdgeInsets.zero,
                          onDec: () => setState(() => qty = (qty - 1).clamp(1, 99)),
                          onInc: () => setState(() => qty++),
                          onAdd: () {
                            cart.addItem(product, qty);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} added to cart'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Thumbnails(
                tone: product.tone,
                imageUrls: _thumbnailImageUrls,
                selectedIndex: _selectedThumbnailIndex,
                onTap: _swapMainImageWithThumbnail,
              ),
              _RecommendedItems(recommendations: _recommendations),
              const _MetaStrip(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    ];
  }
}

class _DesktopContent extends StatelessWidget {
  final Widget child;
  const _DesktopContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
          child: child,
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
  final List<String> imageUrls;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _Thumbnails({
    required this.tone,
    required this.imageUrls,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final images = imageUrls.isEmpty ? const <String>[] : imageUrls;
    final count = images.length.clamp(1, 4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(count, (i) {
          final imageUrl = images[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < count - 1 ? 10 : 0),
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: i == selectedIndex ? Daana.ink : Daana.hairlineSoft,
                      width: i == selectedIndex ? 1.5 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ProductPlaceholder(
                      label: 'detail ${i + 1}',
                      tone: tone,
                      radius: 10,
                      imageUrl: imageUrl,
                    ),
                  ),
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
  final Map<String, dynamic> detail;
  final bool desktop;
  const _Header({
    required this.product,
    required this.detail,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: desktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 20),
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
          Text(product.name, style: Daana.serif(size: desktop ? 42 : 44, height: 1.0)),
          const SizedBox(height: 4),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              detail['urduName'] as String,
              style: Daana.urdu(size: 22, color: Daana.ink70),
            ),
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
                  detail['quantity'] as String,
                  style: Daana.sans(size: 12, color: Daana.ink50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            detail['description'] as String,
            style: Daana.sans(size: 14, color: Daana.ink70, height: 1.55),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Daana.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Daana.hairlineSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What you can make',
                  style: Daana.sans(size: 13, weight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  detail['whatYouCanMake'] as String,
                  style: Daana.sans(size: 14, color: Daana.ink70, height: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on _ProductDetailScreenState {
  Map<String, dynamic> _detailContent(Product product) {
    final fallback = CatalogGenerator.buildProductDetailPayload(product);
    return {
      'imageUrl': product.imageUrl ?? fallback['imageUrl'],
      'thumbnailImageUrls': product.thumbnailImageUrls?.isNotEmpty == true
          ? product.thumbnailImageUrls!
          : List<String>.from(fallback['thumbnailImageUrls']),
      'urduName': (product.urduName ?? fallback['urduName']).toString(),
      'description': (product.description ?? fallback['description']).toString(),
      'quantity': (product.quantity ?? fallback['quantity']).toString(),
      'whatYouCanMake': (product.whatYouCanMake ?? fallback['whatYouCanMake']).toString(),
    };
  }
}

class _CTA extends StatelessWidget {
  final int qty;
  final int price;
  final VoidCallback onDec;
  final VoidCallback onInc;
  final VoidCallback onAdd;
  final EdgeInsetsGeometry padding;
  const _CTA({
    required this.qty,
    required this.price,
    required this.onDec,
    required this.onInc,
    required this.onAdd,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
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

class _RecommendedItems extends StatelessWidget {
  final List<Product> recommendations;
  const _RecommendedItems({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DaanaIcon('sparkle', size: 14, color: Daana.moss),
              const SizedBox(width: 8),
              const Eyebrow('Recommended for you'),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: recommendations.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Daana.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Daana.hairlineSoft),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: ProductPlaceholder(
                            label: product.label,
                            tone: product.tone,
                            radius: 12,
                            imageUrl: product.imageUrl,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product.name, style: Daana.sans(size: 14, weight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(product.unit, style: Daana.sans(size: 12, color: Daana.ink50)),
                              const SizedBox(height: 6),
                              PriceText(value: product.price, size: 14),
                            ],
                          ),
                        ),
                        DaanaIcon('chevR', size: 14, color: Daana.ink50),
                      ],
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
