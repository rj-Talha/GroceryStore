import 'package:daana/data/products.dart';
import 'package:daana/firebase_options.dart';
import 'package:daana/providers/cart_provider.dart';
import 'package:daana/providers/catalog_provider.dart';
import 'package:daana/screens/checkout_screen.dart';
import 'package:daana/screens/home_screen.dart';
import 'package:daana/services/ai_service.dart';
import 'package:daana/widgets/product_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('checkout screen shows all required fields', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CheckoutScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('First name'), findsOneWidget);
    expect(find.text('Last name'), findsOneWidget);
    expect(find.text('Phone number'), findsOneWidget);
    expect(find.text('Email (optional)'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(find.text('Payment method'), findsOneWidget);
    expect(find.text('Cash on delivery'), findsOneWidget);
  });

  testWidgets('checkout shows phone validation error for invalid number', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CheckoutScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Ali');
    await tester.enterText(find.byType(TextFormField).at(1), 'Khan');
    await tester.enterText(find.byType(TextFormField).at(2), '123456');
    await tester.enterText(find.byType(TextFormField).at(4), 'House 1');
    await tester.tap(find.text('Place order'));
    await tester.pump();

    expect(find.text('Enter a valid phone number'), findsOneWidget);
  });

  testWidgets(
    'checkout shows expiry validation error for invalid month or year',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CheckoutScreen()));

      await tester.tap(find.text('Online payment'));
      await tester.tap(find.text('Place order'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).at(0),
        '4242424242424242',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '13/99');
      await tester.enterText(find.byType(TextFormField).at(2), '123');
      await tester.tap(find.text('Pay Rs. 0'));
      await tester.pump();

      expect(find.text('Enter a valid month/year'), findsOneWidget);
    },
  );

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

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('tapping the home product add button adds the item to cart', (
    tester,
  ) async {
    final cart = CartProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cart),
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

    await tester.tap(
      find.descendant(
        of: find.byType(ProductCard).first,
        matching: find.byType(InkWell),
      ),
    );
    await tester.pump();

    expect(cart.itemCount, 1);
  });

  test('AI service blocks unrelated questions', () async {
    final aiService = AIService();

    final response = await aiService.answerQuery('What is the weather today?');

    expect(
      response,
      'I can not answer questions that are not related to this Store.',
    );
  });
}
