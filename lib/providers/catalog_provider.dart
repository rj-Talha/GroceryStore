import 'package:flutter/foundation.dart';
import '../data/products.dart';
import '../services/firestore_service.dart';

class CatalogProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Product> _allProducts = [];
  List<(Product, String)> _suggestions = [];
  bool _isLoading = true;
  String? _error;

  CatalogProvider({List<Product>? initialProducts, bool initialIsLoading = true}) {
    _allProducts = initialProducts ?? [];
    _isLoading = initialIsLoading;

    if (initialProducts != null) {
      notifyListeners();
      return;
    }

    _init();
  }

  Future<void> _init() async {
    await refreshProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    try {
      _allProducts = await _firestoreService.getProducts();
      await _refreshSuggestedProducts();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _suggestions = _buildFallbackSuggestions();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _refreshSuggestedProducts() async {
    try {
      final orders = await _firestoreService.getOrders();
      _suggestions = _buildSuggestionsFromOrders(orders);
      if (_suggestions.isEmpty) {
        _suggestions = _buildFallbackSuggestions();
      }
    } catch (e) {
      print('Suggestion refresh error: $e');
      _suggestions = _buildFallbackSuggestions();
    }
  }

  List<(Product, String)> _buildSuggestionsFromOrders(List<StoreOrder> orders) {
    final productQuantities = <String, int>{};

    for (final order in orders) {
      for (final item in order.items) {
        if (item.productId.isEmpty) continue;
        productQuantities[item.productId] =
            (productQuantities[item.productId] ?? 0) + item.quantity;
      }
    }

    final sortedProductIds = productQuantities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final suggestions = <(Product, String)>[];
    for (final entry in sortedProductIds) {
      final product = _allProducts.firstWhere(
        (p) => p.key == entry.key,
        orElse: () => Product(
          key: entry.key,
          name: itemNameForMissingProduct(entry.key),
          unit: '',
          price: 0,
          old: null,
          deal: null,
          label: '',
          tone: 'd',
          imageUrl: '',
          salesCount: 0,
          trendingScore: 0,
        ),
      );

      if (product.key.isEmpty) {
        continue;
      }

      if (suggestions.length >= 5) break;
      if (_allProducts.any((p) => p.key == entry.key)) {
        suggestions.add((product, 'Top ordered'));
      }
    }

    if (suggestions.length < 5) {
      final fallback = _buildFallbackSuggestions();
      for (final item in fallback) {
        if (suggestions.length >= 5) break;
        if (!suggestions.any((entry) => entry.$1.key == item.$1.key)) {
          suggestions.add(item);
        }
      }
    }

    return suggestions;
  }

  List<(Product, String)> _buildFallbackSuggestions() {
    return mostSoldProducts
        .take(5)
        .map((p) => (p, 'Most sold this week'))
        .toList();
  }

  String itemNameForMissingProduct(String productId) {
    final matchingProduct = Products.all.values.firstWhere(
      (product) => product.key == productId,
      orElse: () => Product(
        key: productId,
        name: '',
        unit: '',
        price: 0,
        old: null,
        deal: null,
        label: '',
        tone: 'd',
        imageUrl: '',
        salesCount: 0,
        trendingScore: 0,
      ),
    );
    return matchingProduct.name;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get allProducts => List.unmodifiable(_allProducts);
  List<(Product, String)> get suggestions => List.unmodifiable(_suggestions);

  List<Product> search(String query, {String sort = 'popular'}) {
    List<Product> results;
    if (query.isEmpty) {
      results = List<Product>.from(_allProducts);
    } else {
      final lowerQuery = query.toLowerCase();
      results = _allProducts.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.label.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Apply sorting
    switch (sort) {
      case 'price_asc':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'popular':
      default:
        results.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
    }

    return results;
  }

  // Returns top 5 most sold products
  List<Product> get mostSoldProducts {
    if (_allProducts.isEmpty) return [];
    final sorted = List<Product>.from(_allProducts)
      ..sort((a, b) => b.salesCount.compareTo(a.salesCount));
    return sorted.take(5).toList();
  }

  // Returns trending products this week
  List<Product> get trendingProducts {
    if (_allProducts.isEmpty) return [];
    final sorted = List<Product>.from(_allProducts)
      ..sort((a, b) => b.trendingScore.compareTo(a.trendingScore));
    return sorted.take(5).toList();
  }

  // Helper to fetch seasonal mangoes for the home screen
  List<Product> get seasonalMangoes {
    return _allProducts.where((p) => 
      p.label == 'mango' || p.label == 'chaunsa' || p.label == 'ratol' || p.label == 'langra'
    ).toList();
  }

  // Fallback for home screen recommendations to adapt to the new API if needed by existing UI
  List<(Product, String)> get recommendations {
    final topSold = mostSoldProducts;
    return topSold.map((p) => (p, 'Most sold this week')).toList();
  }
}
