import 'package:daana/data/products.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Order.fromJson preserves status and totals', () {
    final order = Order.fromJson('order-1', {
      'customerName': 'Ayesha',
      'phone': '03001234567',
      'email': 'ayesha@example.com',
      'address': 'Block A',
      'paymentMethod': 'Cash on delivery',
      'status': 'processing',
      'subtotal': 640,
      'deliveryFee': 149,
      'serviceFee': 49,
      'total': 838,
      'createdAt': DateTime(2026, 6, 29, 12, 0, 0).toIso8601String(),
      'items': [
        {
          'productId': 'mangoesSindhri',
          'productName': 'Sindhri Mango',
          'unit': '1 kg',
          'quantity': 2,
          'unitPrice': 320,
          'lineTotal': 640,
        }
      ],
    });

    expect(order.customerName, 'Ayesha');
    expect(order.status, 'processing');
    expect(order.total, 838);
    expect(order.items.single.productName, 'Sindhri Mango');
  });
}
