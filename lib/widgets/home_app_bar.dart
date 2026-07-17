import 'package:flutter/material.dart';

import '../screens/search_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/voice_modal.dart';
import '../theme/tokens.dart';
import 'daana_icon.dart';
import 'eyebrow.dart';

/// The delivery and search header shown at the top of the home screen.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
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
                        Text('DHA Phase VI', style: Daana.sans(size: 15)),
                        const SizedBox(width: 4),
                        DaanaIcon('chevD', size: 14, color: Daana.ink50),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierDismissible: true,
                    barrierColor: Colors.transparent,
                    pageBuilder: (routeContext, _, __) => SignInScreen(
                      onClose: () => Navigator.of(routeContext).pop(),
                    ),
                  ),
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                  child: Container(
                    height: 48,
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
                    color: Daana.ink,
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
  }
}
