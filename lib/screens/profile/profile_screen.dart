import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/models/user_profile.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/screens/profile/profile_detail_screen.dart';
import 'package:pantrysaver/widgets/app_modal.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.profile;
    return Scaffold(
      appBar: const PantryAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PantryCard(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileDetailScreen())),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                CircleAvatar(radius: 28, backgroundColor: PantryAppTheme.softYellow, child: const Icon(Icons.person, color: PantryAppTheme.primary)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile?.fullName ?? 'User', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(profile?.email ?? '', style: TextStyle(color: Colors.grey.shade700)),
                ])),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          PantryCard(
            child: Column(children: [
              ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Edit Profile'), onTap: () => _showEditDialog(context, provider, profile)),
              SwitchListTile(value: provider.darkMode, onChanged: (value) => provider.toggleDarkMode(value), title: const Text('Dark Mode'), secondary: const Icon(Icons.dark_mode_outlined)),
              ListTile(leading: const Icon(Icons.logout_outlined), title: const Text('Logout'), onTap: () async {
                final confirmed = await AppModal.show(
                  context,
                  type: AppModalType.confirmation,
                  title: 'Log out?',
                  message: 'You’ll need to sign in again to access your pantry.',
                  confirmText: 'Log out',
                  cancelText: 'Stay signed in',
                );
                if (confirmed ?? false) {
                  await provider.signOut();
                }
              }),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context, AppProvider provider, UserProfile? profile) async {
    if (profile == null) return;
    final nameController = TextEditingController(text: profile.fullName);
    final budgetController = TextEditingController(text: profile.monthlyBudget.toString());
    final formKey = GlobalKey<FormState>();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: budgetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monthly Budget'), validator: (v) => double.tryParse(v ?? '') == null || double.parse(v!) <= 0 ? 'Budget must be greater than zero' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final updated = UserProfile(
                uid: profile.uid,
                fullName: nameController.text.trim(),
                email: profile.email,
                monthlyBudget: double.parse(budgetController.text),
                createdAt: profile.createdAt,
                notificationsEnabled: profile.notificationsEnabled,
              );
              await provider.updateProfile(updated);
              if (context.mounted) {
                Navigator.pop(ctx);
                await AppModal.show(
                  context,
                  type: AppModalType.success,
                  title: 'Profile updated',
                  message: 'Your profile details were saved successfully.',
                  confirmText: 'Great',
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
