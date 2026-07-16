import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'admin_portal_screen.dart';
import 'app_shell.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSignIn = true;
  bool _signInPushed = false;

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

        // Always show the guest Shell as the app background.
        // If there is no signed-in user and the sign-in popup hasn't
        // been pushed yet, push it as a modal route so closing the
        // popup simply pops the route and doesn't trigger a full
        // rebuild/refresh of the Shell content.
        if (!snapshot.hasData && _showSignIn && !_signInPushed) {
          _signInPushed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).push(
              PageRouteBuilder(
                opaque: false,
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.45),
                transitionDuration: const Duration(milliseconds: 250),
                pageBuilder: (routeContext, animation, secondaryAnimation) {
                  return SignInScreen(
                    onClose: () {
                      Navigator.of(routeContext, rootNavigator: true).pop();
                      // allow the sign-in to be shown again later
                      setState(() {
                        _showSignIn = false;
                        _signInPushed = false;
                      });
                    },
                  );
                },
              ),
            );
          });
        }

        return const Shell();
      },
    );
  }
}
