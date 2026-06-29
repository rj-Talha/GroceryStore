import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daana/screens/checkout_screen.dart';

void main() {
  testWidgets('checkout screen shows all required fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CheckoutScreen()));

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Email (optional)'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Payment method'), findsOneWidget);
    expect(find.text('Cash on delivery'), findsOneWidget);
  });
}
