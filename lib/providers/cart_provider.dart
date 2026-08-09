import 'package:flutter/foundation.dart';
import '../data/products.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  int get subtotal => _items.values.fold(
      0, (sum, item) => sum + (item.product.price * item.quantity));

  // Fixed delivery charges: Rs 149 delivery fee + Rs 49 service fee = Rs 198 total.
  int get deliveryFee => 149;
  int get serviceFee => 49;
  
  int get total => subtotal == 0 ? 0 : subtotal + deliveryFee + serviceFee;

  void addItem(Product product, [int quantity = 1]) {
    if (_items.containsKey(product.key)) {
      _items[product.key]!.quantity += quantity;
    } else {
      _items[product.key] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;
    
    if (newQuantity <= 0) {
      _items.remove(productId);
    } else {
      _items[productId]!.quantity = newQuantity;
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
