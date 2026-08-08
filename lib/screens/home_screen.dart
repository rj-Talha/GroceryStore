import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/products.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';
import '../services/ai_service.dart';
import '../theme/tokens.dart';
import '../widgets/btn.dart';
import '../widgets/daana_icon.dart';
import '../widgets/eyebrow.dart';
import '../widgets/premium_background.dart';
import '../widgets/product_card.dart';
import '../widgets/product_placeholder.dart';
import 'category_screen.dart';
import 'product_detail_screen.dart';
import 'saved_recipes_screen.dart';
import 'search_screen.dart';
import 'ai_recipe_screen.dart';
import 'sign_in_screen.dart';
import 'voice_modal.dart';
import '../widgets/app_footer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();

    if (catalog.isLoading) {
      return Container(
        color: Daana.bg,
        child: const Center(
          child: CircularProgressIndicator(color: Daana.moss),
        ),
      );
    }

    final trending = catalog.trendingProducts;
    final topTrending = trending.isNotEmpty ? trending.first : null;

    return Stack(
      children: [
        const PremiumBackground(),
        SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AddressBar(),
                const SizedBox(height: 12),
                const _SearchBar(),
                const SizedBox(height: 18),
                if (trending.isNotEmpty) _BannerCarousel(products: trending),
                const SizedBox(height: 28),
                const _CategoriesSection(),
                const SizedBox(height: 20),
                const _AITile(),
                const SizedBox(height: 24),
                const _SuggestionsSection(),
                const SizedBox(height: 24),
                const _AllProductsSection(),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 92,
          child: _AiChatFab(onPressed: () => _openChatSheet(context)),
        ),
      ],
    );
  }

  void _openChatSheet(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.18),
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (routeContext, animation, secondaryAnimation) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(routeContext).pop(),
                child: Container(color: Colors.transparent),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SlideTransition(
                  position: animation.drive(
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeOutCubic)),
                  ),
                  child: const _AiChatSheet(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AiChatFab extends StatefulWidget {
  final VoidCallback onPressed;

  const _AiChatFab({required this.onPressed});

  @override
  State<_AiChatFab> createState() => _AiChatFabState();
}

class _AiChatFabState extends State<_AiChatFab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: _hovered ? 150 : 56,
        height: 56,
        decoration: BoxDecoration(
          color: Daana.moss,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onPressed,
            child: Center(
              child: _hovered
                  ? Text(
                      "FAQ's BOT",
                      style: Daana.sans(
                        size: 14,
                        color: Daana.bg,
                        weight: FontWeight.w600,
                      ),
                    )
                  : const Icon(
                      Icons.smart_toy_outlined,
                      color: Daana.bg,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class _AiChatSheet extends StatefulWidget {
  const _AiChatSheet({super.key});

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final _questionController = TextEditingController();
  final _aiService = AIService();
  bool _isLoading = false;
  final _messages = <_ChatEntry>[];
  final _faqs = const <_FaqItem>[
    _FaqItem(
      question: 'How much time does delivery take?',
      answer:
          'Most orders are delivered within 6 to 8 hours, depending on your area and the items in your cart.',
    ),
    _FaqItem(
      question: 'How are fruits and vegetables kept fresh?',
      answer:
          'Fresh produce is stored in temperature-controlled conditions and packed carefully to preserve freshness during delivery.',
    ),
    _FaqItem(
      question: 'How is chicken kept fresh?',
      answer:
          'Chicken is kept chilled in sealed packaging and delivered as quickly as possible to maintain food safety and quality.',
    ),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _sendQuery() async {
    final query = _questionController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _messages.add(_ChatEntry(isUser: true, text: query));
      _isLoading = true;
      _questionController.clear();
    });

    final response = await _aiService.answerQuery(query);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatEntry(isUser: false, text: response));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 320,
          color: Daana.bg,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Daana.moss,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.smart_toy_outlined,
                              color: Daana.bg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "FAQ's BOT",
                                style: Daana.serif(size: 20, height: 1.0),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ask only e-grocery store questions',
                                style: Daana.sans(size: 13, color: Daana.ink50),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          color: Daana.ink70,
                          splashRadius: 22,
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Daana.hairlineSoft, height: 1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView(
                        padding: const EdgeInsets.only(top: 16, bottom: 12),
                        children: [
                          ..._faqs.map((faq) => _FaqTile(faq)),
                          if (_messages.isNotEmpty) const SizedBox(height: 16),
                          ..._messages.map(
                            (message) => _ChatBubble(message: message),
                          ),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Daana.moss,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Divider(color: Daana.hairlineSoft, height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Daana.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Daana.hairlineSoft),
                            ),
                            child: TextField(
                              controller: _questionController,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendQuery(),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Ask about this store, delivery, products, or orders',
                                hintStyle: Daana.sans(
                                  size: 13,
                                  color: Daana.ink50,
                                ),
                              ),
                              style: Daana.sans(size: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _isLoading ? null : _sendQuery,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _isLoading ? Daana.ink15 : Daana.moss,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.send,
                              color: _isLoading ? Daana.ink50 : Daana.bg,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatEntry {
  final bool isUser;
  final String text;

  const _ChatEntry({required this.isUser, required this.text});
}

class _FaqTile extends StatelessWidget {
  final _FaqItem faq;
  const _FaqTile(this.faq);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 4, top: 4, bottom: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Daana.card,
        collapsedBackgroundColor: Daana.card,
        title: Text(faq.question, style: Daana.sans(size: 14)),
        iconColor: Daana.moss,
        collapsedIconColor: Daana.ink50,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              faq.answer,
              style: Daana.sans(size: 13, color: Daana.ink70, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatEntry message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bgColor = message.isUser ? Daana.moss : Daana.card;
    final textColor = message.isUser ? Daana.bg : Daana.ink;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: Daana.sans(size: 13, color: textColor, height: 1.5),
        ),
      ),
    );
  }
}

class _AddressBar extends StatefulWidget {
  const _AddressBar();

  @override
  State<_AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<_AddressBar> {
  String _displayLabel(User? user) {
    if (user == null) {
      return 'Guest User';
    }
    
    final displayName = (user.displayName ?? '').trim();
    if (displayName.isNotEmpty) {
      return displayName;
    }

    final email = (user.email ?? '').trim();
    if (email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Guest User';
  }

  Future<void> _handleUserIconTap(BuildContext context, {required bool isSignedIn}) async {
    if (!isSignedIn) {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          pageBuilder: (routeContext, _, __) => SignInScreen(
            onClose: () => Navigator.of(routeContext).pop(),
          ),
        ),
      );
      return;
    }

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Sign out?'),
          content: const Text('Do you want to sign out from your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final label = _displayLabel(snapshot.data);
        final isSignedIn = snapshot.hasData && snapshot.data != null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow('Delivering today 6 am - 10 pm', size: 9.5),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            DaanaIcon('pin', size: 15, color: Daana.moss),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Rawat, Islamabad',
                                style: Daana.sans(size: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Hi, $label',
                            style: Daana.sans(size: 12, color: Daana.ink70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SavedRecipesScreen()),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Daana.moss.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Daana.moss.withOpacity(0.22)),
                              ),
                              child: Text(
                                'My Recipe',
                                style: Daana.sans(
                                  size: 12,
                                  color: Daana.moss,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => _handleUserIconTap(context, isSignedIn: isSignedIn),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Daana.card,
                                shape: BoxShape.circle,
                                border: Border.all(color: Daana.hairlineSoft),
                              ),
                              child: const Center(child: DaanaIcon('user', size: 17)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Delivering today 6 am - 10 pm', size: 9.5),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              DaanaIcon('pin', size: 15, color: Daana.moss),
                              const SizedBox(width: 6),
                              Text('Rawat, Islamabad', style: Daana.sans(size: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          'Hi, $label',
                          style: Daana.sans(size: 12, color: Daana.ink70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SavedRecipesScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Daana.moss.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Daana.moss.withOpacity(0.22)),
                          ),
                          child: Text(
                            'My Recipe',
                            style: Daana.sans(
                              size: 12,
                              color: Daana.moss,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _handleUserIconTap(context, isSignedIn: isSignedIn),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Daana.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: Daana.hairlineSoft),
                          ),
                          child: const Center(child: DaanaIcon('user', size: 17)),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Daana.glass,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Daana.hairlineSoft),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        DaanaIcon('search', size: 18, color: Daana.ink50),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search "ٹماٹر" or "Tomato"',
                            style: Daana.sans(size: 15, color: Daana.ink50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => showVoiceModal(context),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Daana.mint, Daana.sage],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Daana.moss.withAlpha(30),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: DaanaIcon('mic', size: 20, color: Daana.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatefulWidget {
  final List<Product> products;
  const _BannerCarousel({required this.products});

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  late final PageController _controller;
  late int _page;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _page = 0;
    _controller = PageController(viewportFraction: 0.94);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || widget.products.isEmpty) return;
      final next = (_page + 1) % widget.products.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant _BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.products.length != widget.products.length) {
      _page = 0;
      _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 360;
            return SizedBox(
              height: isCompact ? 250 : 230,
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.products.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return _BannerSlide(product: product, compact: isCompact);
                },
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.products.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: index == _page ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index == _page ? Daana.mossDark : Daana.moss.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerSlide extends StatelessWidget {
  final Product product;
  final bool compact;
  const _BannerSlide({required this.product, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          padding: EdgeInsets.all(compact ? 16 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Daana.mossDark, Color(0xFF1F4B30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: Daana.glowShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                top: compact ? 12 : 20,
                right: compact ? 12 : 20,
                child: Opacity(
                  opacity: 0.15,
                  child: SizedBox(
                    width: compact ? 96 : 120,
                    height: compact ? 96 : 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Daana.mint.withAlpha(120), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: compact ? 0 : 0,
                top: compact ? 10 : 20,
                child: Hero(
                  tag: 'banner-${product.key}',
                  child: SizedBox(
                    width: compact ? 120 : 140,
                    height: compact ? 120 : 140,
                    child: ProductPlaceholder(
                      label: product.label,
                      tone: product.tone,
                      radius: compact ? 60 : 70,
                      imageUrl: product.imageUrl,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Daana.mint.withAlpha(220),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const DaanaIcon('flame', size: 14, color: Daana.mossDark),
                          const SizedBox(width: 8),
                          Text('Trending this week', style: Daana.sans(size: 11, color: Daana.mossDark, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 16),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        '${product.name} are trending.',
                        style: Daana.serif(size: compact ? 20 : 26, color: Daana.white, height: 1.05),
                        maxLines: compact ? 2 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 8),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Text(
                        'Everyone is buying ${product.name.toLowerCase()} right now. Delivered today.',
                        style: Daana.sans(size: compact ? 12 : 14, color: Daana.white.withOpacity(0.82), height: 1.4),
                        maxLines: compact ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Btn(
                      'Shop now',
                      variant: BtnVariant.moss,
                      size: compact ? BtnSize.sm : BtnSize.md,
                      iconRight: 'arrowR',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: product),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  /// (English, Urdu, tone, IconData) — Material Icons are bundled with Flutter.
  static const cats = <(String, String, String, IconData)>[
    ('Fruits', 'پھل', 'c', Icons.apple),
    ('Veg', 'سبزی', 'b', Icons.eco),
    ('Meat', 'گوشت', 'a', Icons.set_meal),
    ('Dairy', 'دودھ', 'd', Icons.egg_alt),
    ('Bakery', 'بیکری', 'c', Icons.bakery_dining),
    ('Pantry', 'راشن', 'd', Icons.rice_bowl),
    ('Drinks', 'مشروبات', 'b', Icons.local_drink),
    ('Home', 'گھر', 'e', Icons.cleaning_services),
  ];

  static const _categoryImages = {
    'Fruits': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIguRwNvGFvWEwTWcwmp1BepLcMKHDQtoRff2DqVbHWA&s=10',
    'Veg': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZbmxWZLe1A_Vil0nNcK5WWQ2DGeqaFfA-hq6cOqqPKQ&s=10',
    'Meat': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRsCDX6JlAmdG4Lamp5JVL6YCFnXjtn7Tx-OKdqSKDiSmM4RCyJ_R1IEGY&s=10',
    'Dairy': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRfSlgJaTgFJdFGXhgSe341NLWCxcxMUkRpD_uggEnc5Q&s',
    'Bakery': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwgiVphhGjQgnmpPG_LV745EAzJhN2ng3wgctDk9H5hBwRpn1TQ7Srn3k&s=10',
    'Pantry': 'https://images.squarespace-cdn.com/content/v1/5aba884031d4dfc50ab90a6e/1666813212484-QHWOPPBJVPJSCRPR9TDK/IMG_0117.JPG',
    'Drinks': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxfqtVMlEFEGKksJpP-iAAd8FKsgF9l975CSEmC-WXEQ&s=10',
    'Home': '',
  };

  static const _toneBg = {
    'a': Color(0xFFE8E2D2),
    'b': Color(0xFFDDE2D5),
    'c': Color(0xFFEBDFD0),
    'd': Color(0xFFE0DED7),
    'e': Color(0xFFD8DBD3),
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: Daana.serif(size: 22, height: 1.0)),
              Text('See all', style: Daana.sans(size: 12, color: Daana.moss)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = 4;
              final imageSize = width >= 500 ? 72.0 : 56.0;
              final iconSize = width >= 500 ? 28.0 : 22.0;
              final textSize = width >= 500 ? 13.0 : 11.5;
              final urduSize = width >= 500 ? 11.0 : 10.0;
              final cardPadding = width >= 500 ? 14.0 : 10.0;
              final childAspectRatio = width >= 500 ? 0.82 : 0.72;

              return GridView.count(
                padding: EdgeInsets.zero,
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: childAspectRatio,
                children: List.generate(cats.length, (index) {
                  final c = cats[index];
                  return GestureDetector(
                    onTap: () {
                      if (c.$1 == 'Home') {
                        context.read<CatalogProvider>().refreshProducts();
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CategoryScreen(category: c.$1)),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Daana.card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Daana.hairlineSoft),
                        boxShadow: Daana.softShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: imageSize,
                            height: imageSize,
                            decoration: BoxDecoration(
                              color: _toneBg[c.$3],
                              borderRadius: BorderRadius.circular(18),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _categoryImages.containsKey(c.$1)
                                ? Image.network(
                                    _categoryImages[c.$1]!,
                                    fit: BoxFit.cover,
                                    width: imageSize,
                                    height: imageSize,
                                    errorBuilder: (context, error, stackTrace) => Center(
                                      child: Icon(c.$4, size: iconSize, color: Daana.mossDark),
                                    ),
                                  )
                                : Center(
                                    child: Icon(c.$4, size: iconSize, color: Daana.mossDark),
                                  ),
                          ),
                          SizedBox(height: width >= 500 ? 14 : 10),
                          Text(c.$1, style: Daana.sans(size: textSize, weight: FontWeight.w600), textAlign: TextAlign.center),
                          SizedBox(height: width >= 500 ? 4 : 2),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              c.$2,
                              style: Daana.urdu(
                                size: urduSize,
                                color: Daana.ink60,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AITile extends StatelessWidget {
  const _AITile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Daana.mossInk,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DaanaIcon(
                  'sparkle',
                  size: 13,
                  color: Daana.bg.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Eyebrow(
                  'Assistant',
                  color: Daana.bg.withOpacity(0.55),
                  size: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                "What's in your fridge tonight?",
                style: Daana.serif(size: 26, color: Daana.bg, height: 1.05),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll suggest three things to cook.",
              style: Daana.sans(
                size: 12.5,
                color: Daana.bg.withOpacity(0.7),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                activeAppTab.value = 1;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AIRecipeScreen(showFooter: true)),
                );
              },
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Daana.bg.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Daana.bg.withOpacity(0.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open assistant',
                      style: Daana.sans(size: 13, color: Daana.bg),
                    ),
                    const SizedBox(width: 6),
                    DaanaIcon('arrowR', size: 13, color: Daana.bg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsSection extends StatefulWidget {
  const _SuggestionsSection();

  @override
  State<_SuggestionsSection> createState() => _SuggestionsSectionState();
}

class _SuggestionsSectionState extends State<_SuggestionsSection> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final recs = catalog.suggestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Suggestions', size: 9.5),
              const SizedBox(height: 2),
              Text(
                'Picked for your pantry',
                style: Daana.serif(size: 22, height: 1.0),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent) {
                if (_controller.hasClients) {
                  final newOffset = (_controller.offset + event.scrollDelta.dy)
                      .clamp(0.0, _controller.position.maxScrollExtent);
                  _controller.jumpTo(newOffset);
                }
              }
            },
            
            child: RawScrollbar(
              thumbVisibility: true,
              thickness: 15,
              radius: const Radius.circular(8),
              minThumbLength: 56,
              controller: _controller,
              child: ListView.separated(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final (p, reason) = recs[i];
                  return SizedBox(
                    width: 168,
                    child: ProductCard(
                      product: p,
                      subtitle: p.quantity?.trim().isNotEmpty == true
                          ? p.quantity!.trim()
                          : p.unit,
                      reason: reason,
                      compact: true,
                      onAdd: () {
                        context.read<CartProvider>().addItem(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${p.name} added to cart'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class _AllProductsSection extends StatelessWidget {
  const _AllProductsSection();

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final products = catalog.allProducts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('All Products', size: 9.5),
          const SizedBox(height: 2),
          Text('Browse every product', style: Daana.serif(size: 22, height: 1.0)),
          const SizedBox(height: 12),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No products available.',
                style: Daana.sans(size: 14, color: Daana.ink50),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 1200
                    ? 4
                    : width >= 800
                        ? 3
                        : 2;

                final childAspectRatio = width >= 1200
                    ? 0.72
                    : width >= 800
                        ? 0.76
                        : 0.64;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: childAspectRatio,
              children: products
                  .map((p) => ProductCard(
                        product: p,
                        subtitle: p.quantity?.trim().isNotEmpty == true
                            ? p.quantity!.trim()
                            : p.unit,
                        compact: true,
                        onAdd: () {
                          context.read<CartProvider>().addItem(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${p.name} added to cart'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: p),
                          ),
                        ),
                      ))
                  .toList(),
            );
              },
            ),
        ],
      ),
    );
  }
}
