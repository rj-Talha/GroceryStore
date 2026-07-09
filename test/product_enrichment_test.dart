import 'package:flutter_test/flutter_test.dart';
import 'package:daana/data/products.dart';
import 'package:daana/services/catalog_generator.dart';

void main() {
  group('CatalogGenerator product detail enrichment', () {
    test('creates unique detail data for each product', () {
      final mango = Product(
        key: 'mango-1',
        name: 'Sindhri Mango',
        unit: '1 kg',
        price: 320,
        label: 'mango',
        tone: 'c',
      );

      final payload = CatalogGenerator.buildProductDetailPayload(mango);

      expect(payload['urduName'], isNotEmpty);
      expect(payload['description'], contains('Sindhri'));
      expect(payload['quantity'], contains('1 kg'));
      expect(payload['whatYouCanMake'], isNotEmpty);
      expect(payload['thumbnailImageUrls'], hasLength(4));
      expect(payload['imageUrl'], isNotEmpty);
    });

    test('uses the provided product name and label for a different product', () {
      final chicken = Product(
        key: 'chicken-1',
        name: 'Chicken Breast',
        unit: '500 g',
        price: 720,
        label: 'chicken',
        tone: 'a',
      );

      final payload = CatalogGenerator.buildProductDetailPayload(chicken);

      expect(payload['urduName'], contains('مرغ'));
      expect(payload['description'], contains('Chicken Breast'));
      expect(payload['quantity'], contains('500 g'));
      expect(payload['whatYouCanMake'], contains('curry'));
    });
  });
}
