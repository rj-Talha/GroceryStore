import 'dart:math';
import '../data/products.dart';

class CatalogGenerator {
  static final _rnd = Random();

  static Map<String, dynamic> buildProductDetailPayload(Product product) {
    final normalizedLabel = product.label.toLowerCase();
    final unit = product.unit.isNotEmpty ? product.unit : '1 pack';
    final seed = product.key.isNotEmpty ? product.key : product.name.toLowerCase();
    final mainImageUrl = 'https://picsum.photos/seed/${seed.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')}/900/900';
    final thumbnailImageUrls = [
      'https://picsum.photos/seed/${seed.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')}-1/300/300',
      'https://picsum.photos/seed/${seed.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')}-2/300/300',
      'https://picsum.photos/seed/${seed.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')}-3/300/300',
      'https://picsum.photos/seed/${seed.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '-')}-4/300/300',
    ];

    final urduName = _urduNameFor(product.name, normalizedLabel);
    final description = _descriptionFor(product.name, normalizedLabel, unit);
    final quantity = _quantityFor(unit);
    final whatYouCanMake = _makeSuggestionsFor(normalizedLabel, product.name);

    return {
      'imageUrl': product.imageUrl ?? mainImageUrl,
      'thumbnailImageUrls': thumbnailImageUrls,
      'name': product.name,
      'urduName': urduName,
      'price': product.price,
      'description': description,
      'quantity': quantity,
      'whatYouCanMake': whatYouCanMake,
    };
  }

  static String _urduNameFor(String productName, String label) {
    final lowered = productName.toLowerCase();
    if (label.contains('mango') || lowered.contains('mango')) {
      return 'سندھری آم';
    }
    if (label.contains('banana') || lowered.contains('banana')) {
      return 'کیلے';
    }
    if (label.contains('tomato') || lowered.contains('tomato')) {
      return 'ٹماٹر';
    }
    if (label.contains('onion') || lowered.contains('onion')) {
      return 'پیاز';
    }
    if (label.contains('potato') || lowered.contains('potato')) {
      return 'آلو';
    }
    if (label.contains('spinach') || lowered.contains('spinach')) {
      return 'پالک';
    }
    if (label.contains('coriander') || lowered.contains('coriander')) {
      return 'دھنیا';
    }
    if (label.contains('garlic') || lowered.contains('garlic')) {
      return 'لہسن';
    }
    if (label.contains('ginger') || lowered.contains('ginger')) {
      return 'ادرک';
    }
    if (label.contains('chicken') || lowered.contains('chicken')) {
      return 'مرغ';
    }
    if (label.contains('beef') || lowered.contains('beef')) {
      return 'گائے کا گوشت';
    }
    if (label.contains('mutton') || lowered.contains('mutton')) {
      return 'بکری کا گوشت';
    }
    return productName;
  }

  static String _descriptionFor(String productName, String label, String unit) {
    final lowerName = productName.toLowerCase();
    if (label.contains('mango') || lowerName.contains('mango')) {
      return '$productName is hand-picked for sweetness and aroma. It is ideal for fresh eating, smoothies, and seasonal desserts.';
    }
    if (label.contains('banana') || lowerName.contains('banana')) {
      return '$productName is ripe, soft, and ready for breakfast bowls, smoothies, or quick snacking.';
    }
    if (label.contains('tomato') || lowerName.contains('tomato')) {
      return '$productName is juicy and rich in flavor, making it perfect for curries, salads, and homemade sauces.';
    }
    if (label.contains('chicken') || lowerName.contains('chicken')) {
      return '$productName is fresh, tender, and packed for quick curries, grilling, or stir-fry meals.';
    }
    if (label.contains('beef') || lowerName.contains('beef')) {
      return '$productName is finely prepared for kebabs, qeema, and hearty family dishes.';
    }
    if (label.contains('milk') || lowerName.contains('milk')) {
      return '$productName is fresh and wholesome, great for chai, tea, baking, and breakfast.';
    }
    return '$productName is carefully selected and packed for daily kitchen use. Each pack is prepared for freshness and convenience in a $unit portion.';
  }

  static String _quantityFor(String unit) {
    return unit.isNotEmpty ? 'Quantity: $unit' : 'Quantity: 1 pack';
  }

  static String _makeSuggestionsFor(String label, String productName) {
    final lowerName = productName.toLowerCase();
    if (label.contains('mango') || lowerName.contains('mango')) {
      return 'Make a mango lassi, mango chutney, or a chilled smoothie with this fruit.';
    }
    if (label.contains('banana') || lowerName.contains('banana')) {
      return 'Use it for banana bread, smoothies, or a quick breakfast bowl.';
    }
    if (label.contains('tomato') || lowerName.contains('tomato')) {
      return 'Cook a rich tomato curry, make fresh salad, or blend it into a sauce.';
    }
    if (label.contains('chicken') || lowerName.contains('chicken')) {
      return 'Prepare a spicy curry, grill it with masala, or stir-fry it with vegetables.';
    }
    if (label.contains('beef') || lowerName.contains('beef')) {
      return 'Use it for qeema, kebabs, or a slow-cooked beef curry.';
    }
    return 'Use $productName in a quick family meal, a fresh salad, or a comforting homemade dish.';
  }

  static List<Product> generate(int count) {
    final products = <Product>[];
    final generatedKeys = <String>{};

    final categories = [
      _generatePantry,
      _generateDairy,
      _generateProduce,
      _generateMeat,
      _generateSnacks,
      _generateBeverages,
    ];

    int attempts = 0;
    while (products.length < count && attempts < count * 3) {
      attempts++;
      final generator = categories[_rnd.nextInt(categories.length)];
      final product = generator();
      
      if (!generatedKeys.contains(product.key)) {
        generatedKeys.add(product.key);
        products.add(product);
      }
    }

    return products;
  }

  static String _randKey(String prefix) {
    return '${prefix}_${_rnd.nextInt(999999)}';
  }

  static Product _generatePantry() {
    final brands = ['National', 'Shan', 'Habib', 'Mezan', 'Dalda', 'Tapal', 'Lipton', 'Mughal', 'Bake Parlor'];
    final items = [
      ('Basmati Rice', '1 kg', 400, 600, 'rice', 'rice'),
      ('Basmati Rice', '5 kg', 1900, 2500, 'rice', 'rice'),
      ('Chakki Atta', '5 kg', 700, 900, 'atta', 'flour'),
      ('Chakki Atta', '10 kg', 1400, 1600, 'atta', 'flour'),
      ('Cooking Oil', '1 L', 500, 650, 'oil', 'oil'),
      ('Cooking Oil', '5 L', 2400, 2800, 'oil', 'oil'),
      ('Danedar Tea', '430 g', 900, 1100, 'chai', 'tea'),
      ('Red Chili Powder', '100 g', 150, 250, 'spice', 'spices'),
      ('Turmeric Powder', '100 g', 120, 200, 'spice', 'spices'),
      ('Coriander Powder', '100 g', 130, 220, 'spice', 'spices'),
      ('Garam Masala', '50 g', 180, 280, 'spice', 'spices'),
      ('Daal Chana', '1 kg', 300, 450, 'daal', 'lentils'),
      ('Daal Masoor', '1 kg', 350, 500, 'daal', 'lentils'),
      ('White Sugar', '1 kg', 130, 160, 'sugar', 'sugar'),
      ('Iodized Salt', '800 g', 60, 100, 'salt', 'salt'),
      ('Tomato Ketchup', '800 g', 350, 500, 'ketchup', 'ketchup'),
    ];

    final brand = brands[_rnd.nextInt(brands.length)];
    final item = items[_rnd.nextInt(items.length)];
    final price = item.$3 + _rnd.nextInt(item.$4 - item.$3);
    
    // 20% chance of a discount
    final old = _rnd.nextDouble() > 0.8 ? price + 50 + _rnd.nextInt(200) : null;
    
    // ~25% chance to assign an image URL
    final bool hasImage = _rnd.nextDouble() < 0.25;
    final imgUrl = hasImage ? 'https://loremflickr.com/400/400/${item.$6}?random=${_rnd.nextInt(1000)}' : null;

    return Product(
      key: _randKey('pntry'),
      name: '$brand ${item.$1}',
      unit: item.$2,
      price: price,
      old: old,
      label: item.$5,
      tone: ['b', 'c', 'd'][_rnd.nextInt(3)],
      salesCount: _rnd.nextInt(1500),
      trendingScore: _rnd.nextInt(100),
      imageUrl: imgUrl,
    );
  }

  static Product _generateDairy() {
    final brands = ["Olper's", 'Milk Pak', 'Prema', 'Nurpur', 'Adams', 'Dayfresh'];
    final items = [
      ('UHT Milk', '1 L', 260, 300, 'milk', 'milk'),
      ('UHT Milk', '250 ml', 70, 90, 'milk', 'milk'),
      ('Fresh Milk', '1 L', 220, 250, 'milk', 'milk'),
      ('Yogurt', '500 g', 180, 220, 'yogurt', 'yogurt'),
      ('Yogurt', '1 kg', 350, 400, 'yogurt', 'yogurt'),
      ('Butter', '200 g', 400, 550, 'butter', 'butter'),
      ('Cheddar Cheese', '200 g', 600, 800, 'cheese', 'cheese'),
      ('Mozzarella', '200 g', 600, 850, 'cheese', 'cheese'),
      ('Cream', '200 ml', 180, 220, 'cream', 'cream'),
    ];

    final brand = brands[_rnd.nextInt(brands.length)];
    final item = items[_rnd.nextInt(items.length)];
    final price = item.$3 + _rnd.nextInt(item.$4 - item.$3);
    final old = _rnd.nextDouble() > 0.9 ? price + 30 + _rnd.nextInt(100) : null;
    
    final bool hasImage = _rnd.nextDouble() < 0.25;
    final imgUrl = hasImage ? 'https://loremflickr.com/400/400/${item.$6}?random=${_rnd.nextInt(1000)}' : null;

    return Product(
      key: _randKey('dairy'),
      name: '$brand ${item.$1}',
      unit: item.$2,
      price: price,
      old: old,
      label: item.$5,
      tone: 'd',
      salesCount: _rnd.nextInt(2000),
      trendingScore: _rnd.nextInt(100),
      imageUrl: imgUrl,
    );
  }

  static Product _generateProduce() {
    final adjs = ['Fresh', 'Organic', 'Local', 'Premium', 'Export Quality'];
    final items = [
      ('Tomatoes', '1 kg', 100, 200, 'tomato', 'b', 'tomato'),
      ('Onions', '1 kg', 80, 150, 'onion', 'd', 'onion'),
      ('Potatoes', '1 kg', 60, 120, 'potato', 'd', 'potato'),
      ('Garlic', '250 g', 150, 250, 'garlic', 'd', 'garlic'),
      ('Ginger', '250 g', 180, 300, 'ginger', 'd', 'ginger'),
      ('Green Chilies', '100 g', 30, 80, 'chili', 'b', 'chili'),
      ('Coriander', '1 bunch', 20, 50, 'coriander', 'b', 'coriander'),
      ('Spinach', '1 kg', 80, 150, 'spinach', 'b', 'spinach'),
      ('Sindhri Mango', '1 kg', 250, 400, 'mango', 'c', 'mango'),
      ('Chaunsa Mango', '1 kg', 300, 450, 'chaunsa', 'c', 'mango'),
      ('Bananas', '1 Dozen', 150, 250, 'banana', 'c', 'banana'),
      ('Apples', '1 kg', 250, 400, 'apple', 'c', 'apple'),
      ('Oranges', '1 Dozen', 200, 350, 'orange', 'c', 'orange'),
      ('Lemons', '250 g', 80, 150, 'lemon', 'c', 'lemon'),
      ('Carrots', '1 kg', 100, 180, 'carrot', 'a', 'carrot'),
    ];

    final adj = _rnd.nextDouble() > 0.5 ? '${adjs[_rnd.nextInt(adjs.length)]} ' : '';
    final item = items[_rnd.nextInt(items.length)];
    final price = item.$3 + _rnd.nextInt(item.$4 - item.$3);
    
    final bool hasImage = _rnd.nextDouble() < 0.25;
    final imgUrl = hasImage ? 'https://loremflickr.com/400/400/${item.$7}?random=${_rnd.nextInt(1000)}' : null;

    return Product(
      key: _randKey('prod'),
      name: '$adj${item.$1}',
      unit: item.$2,
      price: price,
      label: item.$5,
      tone: item.$6,
      salesCount: _rnd.nextInt(2500),
      trendingScore: _rnd.nextInt(100),
      imageUrl: imgUrl,
    );
  }

  static Product _generateMeat() {
    final adjs = ['Fresh', 'Premium', 'Zabiha Halal', 'Prime'];
    final items = [
      ('Chicken Breast', '1 kg', 1100, 1400, 'chicken', 'chicken'),
      ('Chicken Boneless', '1 kg', 1200, 1500, 'chicken', 'chicken'),
      ('Chicken Karahi Cut', '1 kg', 900, 1200, 'chicken', 'chicken'),
      ('Beef Mince (Qeema)', '1 kg', 1600, 2200, 'beef', 'beef'),
      ('Beef Boti', '1 kg', 1500, 2000, 'beef', 'beef'),
      ('Mutton Mix', '1 kg', 2200, 2800, 'mutton', 'mutton'),
      ('Mutton Chops', '1 kg', 2500, 3000, 'mutton', 'mutton'),
    ];

    final adj = _rnd.nextDouble() > 0.3 ? '${adjs[_rnd.nextInt(adjs.length)]} ' : '';
    final item = items[_rnd.nextInt(items.length)];
    final price = item.$3 + _rnd.nextInt(item.$4 - item.$3);
    final old = _rnd.nextDouble() > 0.8 ? price + 100 + _rnd.nextInt(300) : null;
    
    final bool hasImage = _rnd.nextDouble() < 0.25;
    final imgUrl = hasImage ? 'https://loremflickr.com/400/400/${item.$6}?random=${_rnd.nextInt(1000)}' : null;

    return Product(
      key: _randKey('meat'),
      name: '$adj${item.$1}',
      unit: item.$2,
      price: price,
      old: old,
      label: item.$5,
      tone: 'a',
      salesCount: _rnd.nextInt(800),
      trendingScore: _rnd.nextInt(100),
      imageUrl: imgUrl,
    );
  }

  static Product _generateSnacks() {
    final brands = ['Peak Freans', 'LU', 'Lays', 'Kurkure', 'Cadbury', 'Novita', 'Oye Hoye', 'Slanty'];
    final items = [
      ('Potato Chips', '40 g', 50, 70, 'chips', 'c', 'chips'),
      ('Spicy Sticks', '45 g', 50, 60, 'snacks', 'a', 'snacks'),
      ('Chocolate Bar', '25 g', 80, 120, 'chocolate', 'a', 'chocolate'),
      ('Chocolate Bar', '80 g', 250, 350, 'chocolate', 'a', 'chocolate'),
      ('Digestive Biscuits', '110 g', 80, 110, 'biscuits', 'd', 'biscuits'),
      ('Chocolate Chip Cookies', '90 g', 70, 100, 'biscuits', 'c', 'cookies'),
      ('Peanuts', '50 g', 100, 150, 'nuts', 'c', 'peanuts'),
    ];

    final brand = brands[_rnd.nextInt(brands.length)];
    final item = items[_rnd.nextInt(items.length)];
    final price = item.$3 + _rnd.nextInt(item.$4 - item.$3);
    
    final bool hasImage = _rnd.nextDouble() < 0.25;
    final imgUrl = hasImage ? 'https://loremflickr.com/400/400/${item.$7}?random=${_rnd.nextInt(1000)}' : null;

    return Product(
      key: _randKey('snck'),
      name: '$brand ${item.$1}',
      unit: item.$2,
      price: price,
      label: item.$5,
      tone: item.$6,
      salesCount: _rnd.nextInt(3000),
      trendingScore: _rnd.nextInt(100),
      imageUrl: imgUrl,
    );
  }

  static Product _generateBeverages() {
    final brands = ['Coca Cola', 'Pepsi', 'Sprite', '7UP', 'Nestle', "Mitchell's", 'Aquafina', 'Dasani'];
    final items = [
      ('Cola', '1.5 L', 150, 180, 'soda', 'soda'),
      ('Lemon Lime Soda', '1.5 L', 150, 180, 'soda', 'soda'),
      ('Cola Can', '250 ml', 70, 90, 'soda', 'soda'),
      ('Mango Juice', '1 L', 250, 350, 'juice', 'juice'),
      ('Apple Juice', '1 L', 250, 350, 'juice', 'juice'),
      ('Mineral Water', '1.5 L', 80, 120, 'water', 'water'),
      ('Mineral Water', '5 L', 250, 350, 'water', 'water'),
    ];

    final brand = brands[_rnd.nextInt(brands.length)];
    final item = items[_rnd.nextInt(items.length)];
    final price = item.$3 + _rnd.nextInt(item.$4 - item.$3);
    
    final bool hasImage = _rnd.nextDouble() < 0.25;
    final imgUrl = hasImage ? 'https://loremflickr.com/400/400/${item.$6}?random=${_rnd.nextInt(1000)}' : null;

    return Product(
      key: _randKey('bev'),
      name: '$brand ${item.$1}',
      unit: item.$2,
      price: price,
      label: item.$5,
      tone: ['b', 'c', 'd'][_rnd.nextInt(3)],
      salesCount: _rnd.nextInt(4000),
      trendingScore: _rnd.nextInt(100),
      imageUrl: imgUrl,
    );
  }
}