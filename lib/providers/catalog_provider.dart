import 'package:flutter/foundation.dart';
import '../data/products.dart';
import '../services/firestore_service.dart';

class CatalogProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Product> _allProducts = [];
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
    try {
      _allProducts = await _firestoreService.getProducts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Product> get allProducts => List.unmodifiable(_allProducts);

  List<Product> search(String query) {
    if (query.isEmpty) return _allProducts;
    
    final lowerQuery = query.toLowerCase();
    return _allProducts.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
             p.label.toLowerCase().contains(lowerQuery);
    }).toList();
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
