import 'package:flutter/material.dart';
import 'package:pantrysaver/screens/auth/auth_screen.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [PantryAppTheme.softYellow, Colors.white]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: PantryAppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(32)),
                    child: const Icon(Icons.local_grocery_store, size: 84, color: PantryAppTheme.primary),
                  ),
                ),
                const SizedBox(height: 24),
                Text('PantrySaver', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: PantryAppTheme.primary)),
                const SizedBox(height: 10),
                const Text('Manage your pantry, budget, shopping list, and recipes from one calm, modern space.', textAlign: TextAlign.center),
                const SizedBox(height: 28),
                PantryPrimaryButton(label: 'Get Started', onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen())), icon: Icons.arrow_forward_rounded),
                const SizedBox(height: 12),
                PantryOutlinedButton(label: 'I already have an account', onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen())), icon: Icons.login_rounded),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
