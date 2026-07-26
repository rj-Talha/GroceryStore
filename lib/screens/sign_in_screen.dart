import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'admin_portal_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isRegistering = false;
  bool _isLoading = false;
  String? _statusMessage;
  Color? _statusMessageColor;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetForm({bool clearStatus = true}) {
    _emailController.clear();
    _passwordController.clear();
    _showPassword = false;
    if (clearStatus) {
      _statusMessage = null;
      _statusMessageColor = null;
    }
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _statusMessageColor = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      if (_isRegistering) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = credential.user;
        if (user == null) {
          throw FirebaseAuthException(
            code: 'user-creation-failed',
            message: 'Unable to create user.',
          );
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );

        await auth.signOut();

        if (!mounted) return;
        setState(() {
          _isRegistering = false;
          _statusMessage = 'Account created successfully. Please sign in.';
          _statusMessageColor = Daana.moss;
          _resetForm(clearStatus: false);
        });
      } else {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        if (isAdminCredential(email, password)) {
          await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminPortalScreen()),
          );
          return;
        }

        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() {
        _statusMessage = error.message ?? 'Authentication failed';
        _statusMessageColor = Colors.red.shade700;
        
      });
    } catch (error) {
      setState(() {
        _statusMessage = 'Something went wrong. Please try again.';
        _statusMessageColor = Colors.red.shade700;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegistering ? 'Create account' : 'Sign in';
    final actionText = _isRegistering ? 'Continue' : 'Sign in';
    final switchText = _isRegistering
        ? 'Already have an account? Sign in'
        : 'New here? Create account';

    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.black.withAlpha((0.45 * 255).round()),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Daana.bg,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Daana.ink.withAlpha((0.12 * 255).round()),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: Daana.serif(
                                size: 34,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Use your email and password to access your grocery list.',
                              style: Daana.sans(size: 15, color: Daana.ink70),
                            ),
                            const SizedBox(height: 32),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildField(
                                    label: 'Email',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Enter a valid email address';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Password',
                                    controller: _passwordController,
                                    obscureText: !_showPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _showPassword ? Icons.visibility : Icons.visibility_off,
                                        color: Daana.ink50,
                                      ),
                                      onPressed: () => setState(() => _showPassword = !_showPassword),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  if (_statusMessage != null) ...[
                                    Text(
                                      _statusMessage!,
                                      style: Daana.sans(
                                        size: 14,
                                        color: _statusMessageColor ?? Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                  ],
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _submit,
                                    style: ButtonStyle(
                                      minimumSize: WidgetStateProperty.all(
                                        const Size.fromHeight(52),
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      backgroundColor: WidgetStateProperty.resolveWith(
                                        (states) {
                                          if (states.contains(WidgetState.disabled)) {
                                            return Daana.ink.withValues(alpha: 89);
                                          }
                                          if (states.contains(WidgetState.hovered) ||
                                              states.contains(WidgetState.focused)) {
                                            return Daana.bg;
                                          }
                                          return Daana.ink;
                                        },
                                      ),
                                      foregroundColor: WidgetStateProperty.resolveWith(
                                        (states) {
                                          if (states.contains(WidgetState.disabled)) {
                                            return Colors.white.withValues(alpha: 166);
                                          }
                                          if (states.contains(WidgetState.hovered) ||
                                              states.contains(WidgetState.focused)) {
                                            return Daana.ink;
                                          }
                                          return Colors.white;
                                        },
                                      ),
                                      textStyle: WidgetStateProperty.all(
                                        Daana.sans(size: 16, weight: FontWeight.w600)
                                            .copyWith(color: null),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              color: Daana.bg,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(actionText),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () => setState(() {
                                              _isRegistering = !_isRegistering;
                                              _resetForm();
                                            }),
                                    child: Text(
                                      switchText,
                                      style: Daana.sans(size: 14, color: Daana.ink70),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -0,
                      right: -0,
                      child: IconButton(
                        onPressed: widget.onClose ?? () => Navigator.of(context, rootNavigator: true).maybePop(),
                        icon: const Icon(Icons.close, size: 24),
                        color: Daana.ink,
                        tooltip: 'Close',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Daana.sans(size: 13, color: Daana.ink70)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Daana.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Daana.hairlineSoft),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: validator,
            style: Daana.sans(size: 15),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
