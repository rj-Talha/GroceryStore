import 'package:daana/data/products.dart';
import 'package:daana/providers/cart_provider.dart';
import 'package:daana/providers/catalog_provider.dart';
import 'package:daana/screens/checkout_screen.dart';
import 'package:daana/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

  testWidgets('home screen shows AI chatbot FAQ button', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(
            create: (_) => CatalogProvider(
              initialProducts: [
                const Product(
                  key: 'apple',
                  name: 'Apples',
                  unit: '1 kg',
                  price: 120,
                  label: 'apple',
                  tone: 'a',
                  salesCount: 10,
                  trendingScore: 10,
                  imageUrl: '',
                ),
              ],
              initialIsLoading: false,
            ),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('AI Chatbot'), findsOneWidget);

    await tester.tap(find.text('AI Chatbot'));
    await tester.pumpAndSettle();

    expect(find.text('Frequently asked questions'), findsOneWidget);
  });
}
