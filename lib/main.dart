import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'screens/admin_portal_screen.dart';
import 'screens/ai_ingredient_screen.dart';
import 'screens/ai_recipe_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'theme/tokens.dart';
import 'widgets/app_footer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      title: 'SmartGroceryStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Daana.bg,
        colorScheme: const ColorScheme.light(
          primary: Daana.moss,
          secondary: Daana.sage,
          surface: Daana.bgAlt,
          onPrimary: Daana.white,
          onSurface: Daana.ink,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(bodyColor: Daana.ink),
        splashColor: Daana.mint.withAlpha(90),
        highlightColor: Daana.mint.withAlpha(90),
        iconTheme: const IconThemeData(color: Daana.ink),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Daana.ink),
          titleTextStyle: Daana.serif(size: 20, color: Daana.ink),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSignIn = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Daana.bg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null && isAdminCredential(user.email, null)) {
          return const AdminPortalScreen();
        }

        return Stack(
          children: [
            const Shell(),
            if (!snapshot.hasData && _showSignIn)
              SignInScreen(onClose: () => setState(() => _showSignIn = false)),
          ],
        );
      },
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _pages = [
    HomeScreen(),
    AIRecipeScreen(),
    AIIngredientScreen(),
    CartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: activeAppTab,
      builder: (context, tab, _) => Scaffold(
        body: IndexedStack(index: tab, children: _pages),
        bottomNavigationBar: AppFooter(
          selectedIndex: tab,
          onSelected: (index) => activeAppTab.value = index,
        ),
      ),
    );
  }
}
