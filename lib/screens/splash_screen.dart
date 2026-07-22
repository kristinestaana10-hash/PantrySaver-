import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/screens/auth/auth_screen.dart';
import 'package:pantrysaver/screens/home/home_screen.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    if (provider.currentUser != null) {
      return const HomeScreen();
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [PantryAppTheme.softYellow, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: PantryAppTheme.primary.withValues(alpha: 0.14), shape: BoxShape.circle),
                child: const Icon(Icons.local_grocery_store, size: 72, color: PantryAppTheme.primary),
              ),
              const SizedBox(height: 24),
              const Text('PantrySaver', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: PantryAppTheme.primary)),
              const SizedBox(height: 8),
              const Text('Smart grocery budgeting, pantry control, and waste-free meals', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
              const SizedBox(height: 20),
              PantryPrimaryButton(
                label: 'Get Started',
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen())),
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
