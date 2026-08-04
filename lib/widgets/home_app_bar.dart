import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/saved_recipes_screen.dart';
import '../screens/search_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/voice_modal.dart';
import '../theme/tokens.dart';
import 'daana_icon.dart';
import 'eyebrow.dart';

/// The delivery and search header shown at the top of the home screen.
class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key, this.isSignedInOverride});

  final bool? isSignedInOverride;

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {

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
        final isSignedIn = widget.isSignedInOverride ?? (snapshot.hasData && snapshot.data != null);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Eyebrow('Delivering today, 6 – 8 pm', size: 9.5),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const DaanaIcon('pin', size: 15, color: Daana.moss),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'DHA Phase VI',
                                    style: Daana.sans(size: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                DaanaIcon('chevD', size: 14, color: Daana.ink50),
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
                            GestureDetector(
                              key: const Key('home_app_bar_user_icon'),
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
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('Delivering today, 6 – 8 pm', size: 9.5),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const DaanaIcon('pin', size: 15, color: Daana.moss),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text('DHA Phase VI',
                                      style: Daana.sans(size: 15),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  DaanaIcon('chevD', size: 14, color: Daana.ink50),
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
                        GestureDetector(
                          key: const Key('home_app_bar_user_icon'),
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
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: isMobile ? 8 : 0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      child: Container(
                        height: isMobile ? 42 : 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Daana.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Daana.hairlineSoft),
                        ),
                        child: Row(
                          children: [
                            DaanaIcon('search', size: 16, color: Daana.ink50),
                            const SizedBox(width: 10),
                            Text(
                              'Search "ٹماٹر" or "Tomato"',
                              style: Daana.sans(size: 14, color: Daana.ink50),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => showVoiceModal(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Daana.sage,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: DaanaIcon('mic', size: 18, color: Daana.bg),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
