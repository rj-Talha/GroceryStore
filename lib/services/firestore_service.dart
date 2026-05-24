import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/products.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      if (snapshot.docs.isEmpty) {
        return Products.all.values.toList();
      }

      return snapshot.docs.map((doc) {
        return Product.fromJson(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Firestore error: \$e');

      return Products.all.values.toList();
    }
  }

  Future<void> seedProducts() async {
    final batch = _firestore.batch();

    int i = 0;
    for (final product in Products.all.values) {
      final docRef = _firestore.collection('products').doc(product.key);
      final json = product.toJson();

      json['salesCount'] = 500 - (i * 10);
      json['trendingScore'] =
          (product.label == 'mango' || product.label == 'chaunsa')
          ? 100
          : (i % 5) * 10;

      batch.set(docRef, json);
      i++;
    }

    await batch.commit();
  }
}
