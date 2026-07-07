import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../data/products.dart';

class RecipeOption {
  final String name;
  final String urdu;
  final String time;
  final int match;
  final int have;
  final int need;
  final String blurb;
  final String tag;

  RecipeOption({
    required this.name,
    required this.urdu,
    required this.time,
    required this.match,
    required this.have,
    required this.need,
    required this.blurb,
    required this.tag,
  });

  factory RecipeOption.fromJson(Map<String, dynamic> json) {
    return RecipeOption(
      name: json['name'] as String? ?? '',
      urdu: json['urdu'] as String? ?? '',
      time: json['time'] as String? ?? '',
      match: json['match'] as int? ?? 0,
      have: json['have'] as int? ?? 0,
      need: json['need'] as int? ?? 0,
      blurb: json['blurb'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
    );
  }
}

class AIService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey.isEmpty ? 'MOCK_KEY' : _apiKey,
    );
  }

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<List<RecipeOption>> generateRecipes(List<String> ingredients) async {
    if (!isConfigured) {
      await Future.delayed(const Duration(milliseconds: 1500));
      return [
        RecipeOption(
          name: 'Chicken Karahi',
          urdu: 'کڑاہی',
          time: '35 m',
          match: 92,
          have: ingredients.length,
          need: 3,
          blurb: 'Bright, tomato-forward karahi finished with ginger.',
          tag: 'Best match',
        ),
        RecipeOption(
          name: 'Murgh Cholay',
          urdu: 'مرغ چنے',
          time: '50 m',
          match: 84,
          have: ingredients.length,
          need: 2,
          blurb: 'Slow chickpea curry with shredded chicken.',
          tag: '',
        ),
        RecipeOption(
          name: 'Dahi Chicken',
          urdu: 'دہی مرغی',
          time: '25 m',
          match: 78,
          have: ingredients.length,
          need: 2,
          blurb: 'Yogurt-tenderized chicken, almost-sweet sauce.',
          tag: '',
        ),
      ];
    }

    final prompt =
        '''
You are a Pakistani culinary expert. I have the following ingredients: ${ingredients.join(', ')}.
Suggest 3 recipes I can make. 
Format the response strictly as a JSON array of objects with the following keys:
- "name": English name of the dish
- "urdu": Urdu name of the dish (in Urdu script)
- "time": Estimated cooking time (e.g. "35 m")
- "match": Integer percentage of how well my ingredients match (e.g. 92)
- "have": Integer number of main ingredients I already have
- "need": Integer number of additional main ingredients I need to buy
- "blurb": A short 1-sentence appetizing description
- "tag": A short tag for the top match like "Best match", empty string for others.

Output raw JSON array only, no markdown blocks.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '[]';

      final cleanText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> jsonList = jsonDecode(cleanText);
      return jsonList
          .map((j) => RecipeOption.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('AI Service Error: $e');
      return [];
    }
  }

  /// Parses a dish string into a list of required Products and quantities
  Future<List<(Product, String)>> getIngredientsForDish(
    String dish,
    List<Product> availableProducts,
  ) async {
    if (!isConfigured) {
      await Future.delayed(const Duration(milliseconds: 1500));
      return availableProducts.take(6).map((p) => (p, '1 item')).toList();
    }

    final availableKeys = availableProducts.map((p) => p.key).join(', ');
    final prompt =
        '''
I want to cook "$dish".
Map the required ingredients to the following available product keys: $availableKeys.
Format the response strictly as a JSON array of objects with keys:
- "key": The exact product key from the list above.
- "qty": A string representing the quantity needed (e.g. "500 g", "3 large").

Output raw JSON array only, no markdown blocks.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '[]';
      final cleanText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> jsonList = jsonDecode(cleanText);

      final results = <(Product, String)>[];
      for (var item in jsonList) {
        final key = item['key'] as String;
        final qty = item['qty'] as String;
        final matchingProduct = availableProducts
            .where((p) => p.key == key)
            .firstOrNull;
        if (matchingProduct != null) {
          results.add((matchingProduct, qty));
        }
      }
      return results;
    } catch (e) {
      print('AI Service Error: $e');
      return [];
    }
  }

  /// Parses transcribed voice text into cart items.
  Future<List<(Product, String)>> parseVoiceOrder(
    String transcription,
    List<Product> availableProducts,
  ) async {
    if (!isConfigured || transcription.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return availableProducts.take(3).map((p) => (p, '1 item')).toList();
    }

    final availableKeys = availableProducts.map((p) => p.key).join(', ');
    final prompt =
        '''
A user said: "$transcription" (It could be in English or Urdu).
Extract the grocery items they want to buy.
Map the required ingredients to the following available product keys: $availableKeys.
Format the response strictly as a JSON array of objects with keys:
- "key": The exact product key from the list above.
- "qty": A string representing the quantity needed.

Output raw JSON array only, no markdown blocks.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '[]';
      final cleanText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final List<dynamic> jsonList = jsonDecode(cleanText);

      final results = <(Product, String)>[];
      for (var item in jsonList) {
        final key = item['key'] as String;
        final qty = item['qty'] as String;
        final matchingProduct = availableProducts
            .where((p) => p.key == key)
            .firstOrNull;
        if (matchingProduct != null) {
          results.add((matchingProduct, qty));
        }
      }
      return results;
    } catch (e) {
      print('AI Service Voice Parse Error: $e');
      return [];
    }
  }

  Future<String> answerQuery(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return 'Please ask a question about this e-grocery store.';
    }

    if (!isConfigured) {
      await Future.delayed(const Duration(milliseconds: 900));
      return _mockQueryResponse(trimmedQuery);
    }

    final prompt =
        '''
You are an AI assistant for an e-grocery store app. Only answer questions related to this grocery store, its products, orders, delivery, freshness, checkout, payment, and customer service.
If the user's question is unrelated to e-grocery or this store, reply exactly:
I can not answer questions that are not related to this Store.

Question: "$trimmedQuery"
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final answer =
          response.text?.trim() ??
          'I can not answer questions that are not related to this Store.';
      return answer.isEmpty
          ? 'I can not answer questions that are not related to this Store.'
          : answer;
    } catch (e) {
      print('AI Service Chat Error: $e');
      return 'I can not answer questions that are not related to this Store.';
    }
  }

  String _mockQueryResponse(String query) {
    final lower = query.toLowerCase();
    final groceryKeywords = [
      'delivery',
      'order',
      'fresh',
      'fruits',
      'vegetable',
      'chicken',
      'checkout',
      'payment',
      'cart',
      'store',
      'availability',
      'slot',
      'delivery time',
      'return',
      'refund',
      'pickup',
      'address',
      'customer service',
    ];

    if (!groceryKeywords.any(lower.contains)) {
      return 'I can not answer questions that are not related to this Store.';
    }

    if (lower.contains('delivery')) {
      return 'Most orders are delivered within 6 to 8 hours, depending on your area and items in your cart.';
    }
    if (lower.contains('fresh') ||
        lower.contains('fruits') ||
        lower.contains('vegetable')) {
      return 'Fresh produce is kept in temperature-controlled storage and packed carefully to preserve freshness during delivery.';
    }
    if (lower.contains('chicken')) {
      return 'Chicken is chilled in sealed packaging and delivered quickly to maintain food safety and quality.';
    }
    if (lower.contains('checkout') || lower.contains('payment')) {
      return 'You can complete your order at checkout using the available payment options and then wait for a delivery confirmation.';
    }
    if (lower.contains('refund') || lower.contains('return')) {
      return 'For returns and refunds, please contact support through the app with your order details.';
    }

    return 'This grocery store supports delivery, fresh produce, checkout, and product questions. Please ask something related to those topics.';
  }
}
