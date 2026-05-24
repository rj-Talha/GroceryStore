import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'screens/ai_ingredient_screen.dart';
import 'screens/ai_recipe_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'theme/tokens.dart';
import 'widgets/daana_icon.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: '',
      appId: '1:692030613513:web:8306467ac528001d7070d8',
      messagingSenderId: '692030613513',
      projectId: 'grocerystore-32f0d',
      storageBucket: 'grocerystore-32f0d.firebasestorage.app',
    ),
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  GoogleFonts.config.allowRuntimeFetching = true;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: const DaanaApp(),
    ),
  );
}

class DaanaApp extends StatelessWidget {
  const DaanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'daana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Daana.bg,
        colorScheme: const ColorScheme.light(
          primary: Daana.ink,
          secondary: Daana.moss,
          surface: Daana.bg,
          onPrimary: Daana.bg,
          onSurface: Daana.ink,
        ),
        textTheme: GoogleFonts.interTextTheme().apply(bodyColor: Daana.ink),
        splashColor: Daana.ink08,
        highlightColor: Daana.ink08,
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  static const _pages = [
    HomeScreen(),
    AIRecipeScreen(),
    AIIngredientScreen(),
    CartScreen(),
  ];

  static const _items = [
    ('home', 'Home'),
    ('sparkle', 'Recipes'),
    ('book', 'Cook'),
    ('bag', 'Cart'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Daana.bg,
            border: Border(top: BorderSide(color: Daana.hairlineSoft)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final on = i == _tab;
              final item = _items[i];
              return InkWell(
                onTap: () => setState(() => _tab = i),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          DaanaIcon(
                            item.$1,
                            size: 20,
                            color: on ? Daana.ink : Daana.ink50,
                          ),
                          if (i == 3)
                            Positioned(
                              top: -4,
                              right: -6,
                              child: Container(
                                width: 14,
                                height: 14,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Daana.moss,
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '4',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Daana.bg,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: Daana.sans(
                          size: 10.5,
                          color: on ? Daana.ink : Daana.ink50,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
