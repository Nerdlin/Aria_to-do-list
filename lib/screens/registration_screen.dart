import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/translations.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0B1120),
                    Color(0xFF132238),
                    Color(0xFF111827),
                  ]
                : const [
                    Colors.white,
                    Color(0xFFE6F4EA),
                    Color(0xFFD9F99D),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_alt_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  Text(
                    tr('Create account'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tr('Set up your profile once and keep tasks, analytics, and settings in sync.'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF111827).withValues(alpha: 0.92)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: tr('Name'),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: tr('Email'),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: tr('Password'),
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            onPressed: _isLoading ? null : _register,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.6,
                                    ),
                                  )
                                : Text(
                                    tr('Create Account'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
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

  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(context, '/shell');
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.message ?? tr('Unable to create account.'))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
