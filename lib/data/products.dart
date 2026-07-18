/// Sample product catalog mirroring screens-shared.jsx PRODUCTS.
class OrderItem {
  final String productId;
  final String productName;
  final String unit;
  final int quantity;
  final int unitPrice;
  final int lineTotal;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      unitPrice: json['unitPrice'] as int? ?? 0,
      lineTotal: json['lineTotal'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'unit': unit,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }
}

class StoreOrder {
  final String id;
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final int total;
  final String createdAt;
  final List<OrderItem> items;

  const StoreOrder({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory StoreOrder.fromJson(String id, Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    final paymentMethod =
        json['paymentMethod'] as String? ?? 'Cash on delivery';
    final status = json['status'] as String? ?? 'processing';
    final paymentStatus = json['paymentStatus'] as String? ??
        (paymentMethod == 'Online payment' || status == 'delivered'
            ? 'paid'
            : 'pending');

    return StoreOrder(
      id: id,
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status,
      subtotal: json['subtotal'] as int? ?? 0,
      deliveryFee: json['deliveryFee'] as int? ?? 0,
      serviceFee: json['serviceFee'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      items: itemsJson
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'phone': phone,
      'email': email,
      'address': address,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'total': total,
      'createdAt': createdAt,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class Product {
  final String key;
  final String name;
  final String unit;
  final int price;
  final int? old;
  final int? deal;
  final String label;
  final String tone; // 'a' | 'b' | 'c' | 'd' | 'e'
  final int salesCount;
  final int trendingScore;
  final String? imageUrl;
  final String? urduName;
  final String? description;
  final String? quantity;
  final String? whatYouCanMake;
  final List<String>? thumbnailImageUrls;
  final String? category;
  final int? availableStock;

  const Product({
    required this.key,
    required this.name,
    required this.unit,
    required this.price,
    this.old,
    this.deal,
    required this.label,
    required this.tone,
    this.salesCount = 0,
    this.trendingScore = 0,
    this.imageUrl,
    this.urduName,
    this.description,
    this.quantity,
    this.whatYouCanMake,
    this.thumbnailImageUrls,
    this.category,
    this.availableStock,
  });

  factory Product.fromJson(String key, Map<String, dynamic> json) {
    return Product(
      key: key,
      name: json['name'] as String? ?? '',
      unit: json['unit'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      old: json['old'] as int?,
      deal: json['deal'] as int?,
      label: json['label'] as String? ?? '',
      tone: json['tone'] as String? ?? 'd',
      salesCount: json['salesCount'] as int? ?? 0,
      trendingScore: json['trendingScore'] as int? ?? 0,
      imageUrl: (json['imageUrl'] ?? json['mainImageUrl']) as String?,
      urduName: json['urduName'] as String?,
      description: json['description'] as String?,
      quantity: json['quantity'] as String?,
      whatYouCanMake: json['whatYouCanMake'] as String?,
      thumbnailImageUrls: (json['thumbnailImageUrls'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      category: json['category'] as String?,
      availableStock: json['availableStock'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'price': price,
      if (old != null) 'old': old,
      if (deal != null) 'deal': deal,
      'label': label,
      'tone': tone,
      'salesCount': salesCount,
      'trendingScore': trendingScore,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (urduName != null) 'urduName': urduName,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (whatYouCanMake != null) 'whatYouCanMake': whatYouCanMake,
      if (thumbnailImageUrls != null) 'thumbnailImageUrls': thumbnailImageUrls,
      if (category != null) 'category': category,
      if (availableStock != null) 'availableStock': availableStock,
    };
  }
}

class Products {
  static const mangoesSindhri = Product(
    key: 'mangoesSindhri',
    name: 'Sindhri Mango',
    unit: '1 kg · seasonal',
    price: 320,
    label: 'mango',
    tone: 'c',
  );
  static const bananas = Product(
    key: 'bananas',
    name: 'Banana, ripe',
    unit: '6 pcs · ~750 g',
    price: 180,
    label: 'banana',
    tone: 'c',
  );
  static const tomatoes = Product(
    key: 'tomatoes',
    name: 'Tomato, vine',
    unit: '500 g',
    price: 95,
    label: 'tomato',
    tone: 'b',
  );
  static const onions = Product(
    key: 'onions',
    name: 'Onion, red',
    unit: '1 kg',
    price: 130,
    label: 'onion',
    tone: 'd',
  );
  static const potatoes = Product(
    key: 'potatoes',
    name: 'Potato, washed',
    unit: '1 kg',
    price: 110,
    label: 'potato',
    tone: 'd',
  );
  static const spinach = Product(
    key: 'spinach',
    name: 'Palak (spinach)',
    unit: '1 bunch · 250 g',
    price: 80,
    label: 'palak',
    tone: 'b',
  );
  static const coriander = Product(
    key: 'coriander',
    name: 'Hara Dhania',
    unit: '100 g',
    price: 30,
    label: 'dhania',
    tone: 'b',
  );
  static const ginger = Product(
    key: 'ginger',
    name: 'Ginger',
    unit: '250 g',
    price: 145,
    label: 'adrak',
    tone: 'd',
  );
  static const garlic = Product(
    key: 'garlic',
    name: 'Garlic, peeled',
    unit: '200 g',
    price: 220,
    label: 'lehsan',
    tone: 'd',
  );
  static const chickenBreast = Product(
    key: 'chickenBreast',
    name: 'Chicken Breast',
    unit: '500 g · zabiha',
    price: 720,
    old: 820,
    deal: 12,
    label: 'chicken',
    tone: 'a',
  );
  static const beefMince = Product(
    key: 'beefMince',
    name: 'Beef Qeema, lean',
    unit: '500 g',
    price: 990,
    label: 'qeema',
    tone: 'a',
  );
  static const eggs = Product(
    key: 'eggs',
    name: 'Eggs, brown',
    unit: 'dozen',
    price: 360,
    label: 'eggs',
    tone: 'd',
  );
  static const milk = Product(
    key: 'milk',
    name: "Olper's Milk",
    unit: '1 L · UHT',
    price: 290,
    label: 'milk',
    tone: 'd',
  );
  static const yogurt = Product(
    key: 'yogurt',
    name: 'Dahi, fresh',
    unit: '500 g',
    price: 210,
    label: 'dahi',
    tone: 'd',
  );
  static const butter = Product(
    key: 'butter',
    name: 'Salted Butter',
    unit: '227 g',
    price: 540,
    label: 'makhan',
    tone: 'c',
  );
  static const basmati = Product(
    key: 'basmati',
    name: 'Basmati Rice, aged',
    unit: '5 kg · super kernel',
    price: 2150,
    label: 'basmati',
    tone: 'c',
  );
  static const atta = Product(
    key: 'atta',
    name: 'Chakki Atta',
    unit: '10 kg',
    price: 1480,
    label: 'atta',
    tone: 'c',
  );
  static const lentils = Product(
    key: 'lentils',
    name: 'Daal Masoor',
    unit: '1 kg',
    price: 480,
    label: 'masoor',
    tone: 'c',
  );
  static const chickpeas = Product(
    key: 'chickpeas',
    name: 'Kabuli Chana',
    unit: '1 kg',
    price: 520,
    label: 'chana',
    tone: 'c',
  );
  static const oil = Product(
    key: 'oil',
    name: 'Sunflower Oil',
    unit: '3 L tin',
    price: 1690,
    label: 'oil',
    tone: 'b',
  );
  static const chai = Product(
    key: 'chai',
    name: 'Tapal Danedar',
    unit: '430 g',
    price: 1090,
    label: 'chai',
    tone: 'a',
  );
  static const sugar = Product(
    key: 'sugar',
    name: 'White Sugar',
    unit: '1 kg',
    price: 145,
    label: 'cheeni',
    tone: 'd',
  );
  static const bread = Product(
    key: 'bread',
    name: 'Sourdough Boule',
    unit: '500 g · daily',
    price: 420,
    label: 'bread',
    tone: 'c',
  );
  static const naan = Product(
    key: 'naan',
    name: 'Naan, tandoori',
    unit: '4 pcs',
    price: 160,
    label: 'naan',
    tone: 'c',
  );
  static const oranges = Product(
    key: 'oranges',
    name: 'Kinnow Orange',
    unit: '1 kg',
    price: 240,
    label: 'kinnow',
    tone: 'c',
  );
  static const apples = Product(
    key: 'apples',
    name: 'Kala Kulu Apple',
    unit: '1 kg',
    price: 380,
    label: 'apple',
    tone: 'c',
  );
  static const paneer = Product(
    key: 'paneer',
    name: 'Paneer, fresh',
    unit: '200 g',
    price: 320,
    label: 'paneer',
    tone: 'd',
  );
  static const greenChili = Product(
    key: 'greenChili',
    name: 'Hari Mirch',
    unit: '100 g',
    price: 25,
    label: 'mirch',
    tone: 'b',
  );

  static const Map<String, Product> all = {
    'mangoesSindhri': mangoesSindhri,
    'bananas': bananas,
    'tomatoes': tomatoes,
    'onions': onions,
    'potatoes': potatoes,
    'spinach': spinach,
    'coriander': coriander,
    'ginger': ginger,
    'garlic': garlic,
    'chickenBreast': chickenBreast,
    'beefMince': beefMince,
    'eggs': eggs,
    'milk': milk,
    'yogurt': yogurt,
    'butter': butter,
    'basmati': basmati,
    'atta': atta,
    'lentils': lentils,
    'chickpeas': chickpeas,
    'oil': oil,
    'chai': chai,
    'sugar': sugar,
    'bread': bread,
    'naan': naan,
    'oranges': oranges,
    'apples': apples,
    'paneer': paneer,
    'greenChili': greenChili,
  };

  /// Format an integer price with en-PK style grouping ("2,150").
  static String formatRs(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final left = s.length - i;
      buf.write(s[i]);
      if (left > 1 && left % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}
