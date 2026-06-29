import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'package:daana/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    final auth = FirebaseAuth.instance;
    final userCredential = await auth.signInAnonymously();
    print('Auth user: ${userCredential.user?.uid}');

    final orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'customerName': 'Copilot Test Customer',
      'phone': '+92 300 0000000',
      'email': 'copilot@example.com',
      'address': 'Test address, Lahore',
      'paymentMethod': 'Cash on delivery',
      'status': 'processing',
      'subtotal': 250.0,
      'deliveryFee': 50.0,
      'serviceFee': 20.0,
      'total': 320.0,
      'createdAt': FieldValue.serverTimestamp(),
      'items': [
        {
          'productId': 'apple',
          'productName': 'Apple',
          'unit': 'kg',
          'quantity': 2,
          'unitPrice': 120.0,
          'lineTotal': 240.0,
        },
      ],
    });

    final snapshot = await FirebaseFirestore.instance.collection('orders').get();
    print('Created order with id: ${orderRef.id}');
    print('Current order count: ${snapshot.docs.length}');
  } catch (e, st) {
    print('Firestore write failed: $e');
    print(st);
  }
}
