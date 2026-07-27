import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/products.dart';
import '../providers/catalog_provider.dart';
import '../theme/tokens.dart';
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
    final keywords = _categoryKeywords[category] ?? [category.toLowerCase()];
    final name = product.name.toLowerCase();
    final label = product.label.toLowerCase();
    final key = product.key.toLowerCase();
    final categoryLower = category.toLowerCase();

    if (name.contains(categoryLower) || label.contains(categoryLower) || key.contains(categoryLower)) {
      return true;
    }

    return keywords.any((keyword) {
      final lowerKeyword = keyword.toLowerCase();
      return name.contains(lowerKeyword) || label.contains(lowerKeyword) || key.contains(lowerKeyword);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final products = catalog.allProducts.where(_matches).toList();

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
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
                children: products
                    .map(
                      (product) => ProductCard(
                        product: product,
                        compact: true,
                        onAdd: () {},
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
    );
  }
}
