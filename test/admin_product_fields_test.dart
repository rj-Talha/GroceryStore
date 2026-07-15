import 'package:flutter_test/flutter_test.dart';
import 'package:daana/data/products.dart';

void main() {
  group('product admin fields', () {
    test('round-trips category and available stock through JSON', () {
      final product = Product.fromJson('test-product', {
        'name': 'Test Product',
        'unit': '1 kg',
        'price': 120,
        'label': 'test',
        'tone': 'd',
        'category': 'Fruits',
        'availableStock': 42,
      });

      expect(product.category, 'Fruits');
      expect(product.availableStock, 42);

      final json = product.toJson();
      expect(json['category'], 'Fruits');
      expect(json['availableStock'], 42);
    });
  });
}
