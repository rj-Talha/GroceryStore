import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';
import 'admin_portal_screen.dart';
import 'location_picker_sheet.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetForm({bool clearStatus = true}) {
    _firstNameController.clear();
    _lastNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _locationController.clear();
    _emailController.clear();
    _passwordController.clear();
    _showPassword = false;
    if (clearStatus) {
      _statusMessage = null;
      _statusMessageColor = null;
    }
    _formKey.currentState?.reset();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$");
    return regex.hasMatch(email);
  }

  String? _validateAlphabeticName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$').hasMatch(name)) {
      return 'Use letters only';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) {
      return 'Required';
    }
    if (!RegExp(r'^03\d{9}$').hasMatch(phone)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  Future<void> _openLocationPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationPickerSheet(),
    );

    if (!mounted || selected == null || selected.trim().isEmpty) {
      return;
    }

    setState(() {
      _locationController.text = selected.trim();
    });
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter your email address first.';
        _statusMessageColor = Colors.red.shade700;
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _statusMessage = 'Please enter a valid email address.';
        _statusMessageColor = Colors.red.shade700;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _statusMessageColor = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      await auth.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        _statusMessage = 'A password reset link has been sent to your email.';
        _statusMessageColor = Daana.moss;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      switch (error.code) {
        case 'invalid-email':
          setState(() {
            _statusMessage = 'Please enter a valid email address.';
            _statusMessageColor = Colors.red.shade700;
          });
          break;
        case 'user-not-found':
          setState(() {
            _statusMessage = 'No account found with this email address.';
            _statusMessageColor = Colors.red.shade700;
          });
          break;
        case 'too-many-requests':
          setState(() {
            _statusMessage = 'Too many requests. Please try again later.';
            _statusMessageColor = Colors.red.shade700;
          });
          break;
        case 'network-request-failed':
          setState(() {
            _statusMessage = 'Please check your internet connection and try again.';
            _statusMessageColor = Colors.red.shade700;
          });
          break;
        default:
          setState(() {
            _statusMessage = error.message ?? 'Unable to send password reset email.';
            _statusMessageColor = Colors.red.shade700;
          });
      }
    } catch (_) {
      if (!mounted) return;
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

        final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
        await user.updateDisplayName(fullName.isEmpty ? null : fullName);

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
          {
            'email': user.email,
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
            'location': _locationController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
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
                                  if (_isRegistering) ...[
                                    _buildField(
                                      label: 'First name',
                                      controller: _firstNameController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                                      ],
                                      validator: _validateAlphabeticName,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      label: 'Last name',
                                      controller: _lastNameController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                                      ],
                                      validator: _validateAlphabeticName,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      label: 'Phone number',
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(11),
                                      ],
                                      validator: _validatePhoneNumber,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildField(
                                      label: 'Address',
                                      controller: _addressController,
                                      maxLines: 3,
                                      validator: (value) =>
                                          value == null || value.trim().isEmpty ? 'Required' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: _openLocationPicker,
                                      child: AbsorbPointer(
                                        child: _buildField(
                                          label: 'Location',
                                          controller: _locationController,
                                          readOnly: true,
                                          suffixIcon: const Icon(Icons.map_outlined),
                                          hintText: 'Tap to pick your address on the map',
                                          validator: (value) =>
                                              value == null || value.trim().isEmpty ? 'Required' : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
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
                                  const SizedBox(height: 8),
                                  if (!_isRegistering)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: _isLoading ? null : _resetPassword,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Forgot password?',
                                          style: Daana.sans(size: 13, color: Daana.ink70),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 12),
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
    bool readOnly = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? hintText,
    VoidCallback? onTap,
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
            readOnly: readOnly,
            validator: validator,
            inputFormatters: inputFormatters,
            maxLines: maxLines,
            onTap: onTap,
            style: Daana.sans(size: 15),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              hintText: hintText,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
