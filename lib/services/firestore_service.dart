import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/products.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return Product.fromJson(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('Firestore error: $e');
      return [];
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return Product.fromJson(doc.id, doc.data()!);
    } catch (e) {
      print('Firestore error: $e');
      return null;
    }
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection('products').doc(productId).set(
      data,
      SetOptions(merge: true),
    );
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _firestore.collection('products').add(data);
  }

  Future<List<StoreOrder>> getOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => StoreOrder.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Firestore error: $e');
      return [];
    }
  }

  Future<void> addOrder(Map<String, dynamic> data) async {
    await _firestore.collection('orders').add(data);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
    });
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

  // Uploads a massive list of products in chunks of 500
  Future<void> uploadMassiveCatalog(List<Product> products) async {
    final chunkSize = 500;

    for (int i = 0; i < products.length; i += chunkSize) {
      final chunk = products.skip(i).take(chunkSize).toList();
      final batch = _firestore.batch();

      for (final product in chunk) {
        final docRef = _firestore.collection('products').doc(product.key);
        batch.set(docRef, product.toJson());
      }

      await batch.commit();
      print('Uploaded chunk ${i ~/ chunkSize + 1}');
    }
  }
}

