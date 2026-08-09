import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/products.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../theme/tokens.dart';
import '../widgets/app_footer.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  const CategoryScreen({super.key, required this.category});

  static const Map<String, List<String>> _categoryKeywords = {
    'Fruits': ['mango', 'banana', 'apple', 'orange', 'kinnow', 'fruit'],
    'Veg': ['palak', 'onion', 'potato', 'tomato', 'spinach', 'vegetable', 'veg', 'dhania'],
    'Meat': ['chicken', 'beef', 'mutton', 'qeema', 'boti', 'boneless', 'karahi', 'mince', 'chops'],
    'Dairy': ['milk', 'dahi', 'paneer', 'butter', 'yogurt', 'cheese', 'eggs'],
    'Bakery': ['bread', 'naan', 'bakery', 'bun'],
    'Pantry': ['rice', 'atta', 'masoor', 'chana', 'oil', 'sugar', 'tea', 'pantry'],
    'Drinks': ['chai', 'tea', 'coffee', 'juice', 'drink', 'milk'],
    'Home': ['clean', 'home', 'detergent', 'cleaning'],
  };

  bool _matches(Product product) {
    return product.category?.trim().toLowerCase() == category.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final products = catalog.allProducts.where(_matches).toList();

    return ValueListenableBuilder<int>(
      valueListenable: activeAppTab,
      builder: (context, tab, _) {
        final width = MediaQuery.of(context).size.width;
        final crossAxisCount = width >= 1200 ? 4 : (width >= 800 ? 3 : 2);
        final childAspectRatio = width >= 1200
            ? 0.72
            : width >= 800
                ? 0.76
                : 0.64;

        return Scaffold(
          backgroundColor: Daana.bg,
          appBar: AppBar(
            backgroundColor: Daana.bg,
            elevation: 0,
            iconTheme: const IconThemeData(color: Daana.ink),
            title: Text(category, style: Daana.serif(size: 20)),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: products.isEmpty
                ? Center(
                    child: Text(
                      'No products found for $category',
                      style: Daana.sans(size: 14, color: Daana.ink50),
                    ),
                  )
                : GridView.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: childAspectRatio,
                    children: products
                        .map(
                          (product) => ProductCard(
                            product: product,
                            compact: true,
                            subtitle: product.quantity?.trim().isNotEmpty == true
                                ? product.quantity!.trim()
                                : product.unit,
                            onAdd: () {
                              context.read<CartProvider>().addItem(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          bottomNavigationBar: AppFooter(
            selectedIndex: tab,
            onSelected: (index) {
              Navigator.of(context).popUntil((route) => route.isFirst);
              activeAppTab.value = index;
            },
          ),
        );
      },
    );
  }
}
