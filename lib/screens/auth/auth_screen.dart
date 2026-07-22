import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/screens/home/home_screen.dart';
import 'package:pantrysaver/widgets/app_modal.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [PantryAppTheme.softYellow, Colors.white]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: PantryCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: PantryAppTheme.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                          child: const Icon(Icons.local_grocery_store, size: 48, color: PantryAppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('PantrySaver', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: PantryAppTheme.primary)),
                      const SizedBox(height: 6),
                      Text(_isLogin ? 'Welcome back' : 'Create your account', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                      if (provider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (!_isLogin)
                        PantryTextField(controller: _nameController, label: 'Full Name', prefixIcon: Icons.person_outline, validator: (value) => value == null || value.trim().isEmpty ? 'Enter your name' : null),
                      if (!_isLogin) const SizedBox(height: 12),
                      PantryTextField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined, validator: (value) => value == null || value.contains('@') ? null : 'Enter a valid email'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) => value != null && value.length >= 6 ? null : 'Password must be at least 6 characters',
                      ),
                      const SizedBox(height: 16),
                      PantryPrimaryButton(
                        label: provider.isLoading ? 'Working...' : (_isLogin ? 'Login' : 'Create Account'),
                        onPressed: provider.isLoading
                            ? () {}
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final navigator = Navigator.of(context);
                                  final modalContext = context;
                                  if (_isLogin) {
                                    await provider.signIn(email: _emailController.text, password: _passwordController.text);
                                  } else {
                                    await provider.signUp(email: _emailController.text, password: _passwordController.text, fullName: _nameController.text);
                                  }

                                  if (!mounted) return;
                                  if (provider.currentUser != null) {
                                    navigator.pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
                                  } else if (provider.errorMessage != null) {
                                    if (!context.mounted) return;
                                    await AppModal.show(modalContext, type: AppModalType.error, title: _isLogin ? 'Sign in failed' : 'Account setup failed', message: provider.errorMessage!, confirmText: 'Try again');
                                  }
                                }
                              },
                        icon: Icons.arrow_forward_rounded,
                      ),
                      const SizedBox(height: 10),
                      TextButton(onPressed: () => setState(() => _isLogin = !_isLogin), child: Text(_isLogin ? 'Need an account? Sign up' : 'Already have an account? Login')),
                      if (_isLogin)
                        TextButton(
                          onPressed: () async {
                            if (_emailController.text.contains('@')) {
                              final modalContext = context;
                              await provider.resetPassword(_emailController.text);
                              if (!mounted) return;
                              if (provider.errorMessage == null) {
                                if (!context.mounted) return;
                                await AppModal.show(modalContext, type: AppModalType.success, title: 'Check your inbox', message: 'Password reset instructions were sent to your email.', confirmText: 'OK');
                              } else {
                                if (!context.mounted) return;
                                await AppModal.show(modalContext, type: AppModalType.error, title: 'Reset failed', message: provider.errorMessage!, confirmText: 'Try again');
                              }
                            }
                          },
                          child: const Text('Forgot password?'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
