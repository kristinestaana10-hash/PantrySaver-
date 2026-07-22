import 'package:flutter/material.dart';
import 'package:pantrysaver/widgets/shared/app_dialogs.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PantryAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PantryCard(
            child: Column(children: [
              CircleAvatar(radius: 36, backgroundColor: PantryAppTheme.softYellow, child: const Icon(Icons.person, size: 36, color: PantryAppTheme.primary)),
              const SizedBox(height: 12),
              const Text('Alex Morgan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const Text('alex@example.com'),
              const SizedBox(height: 16),
              PantryPrimaryButton(label: 'Edit Profile', onPressed: () => PantryDialogs.showInfo(context, title: 'Edit Profile', message: 'Profile edit form is ready to connect to your existing backend.'), icon: Icons.edit_outlined),
            ]),
          ),
          const SizedBox(height: 16),
          PantryCard(
            child: Column(children: [
              _settingTile(Icons.settings_outlined, 'Settings', 'Preferences and reminders'),
              _settingTile(Icons.info_outline, 'About', 'PantrySaver UI demo'),
              _settingTile(Icons.logout, 'Logout', 'Sign out of your account', onTap: () async {
                final confirmed = await PantryDialogs.showConfirm(context, title: 'Logout?', message: 'You can reconnect to your account anytime.', confirmLabel: 'Logout');
                if ((confirmed ?? false) && context.mounted) {
                  Navigator.pop(context);
                }
              }),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: PantryAppTheme.softOrange, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: PantryAppTheme.primary)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
