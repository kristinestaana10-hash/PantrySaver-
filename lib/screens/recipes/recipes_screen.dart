import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/models/pantry_item.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(appBar: const PantryAppBar(title: 'Recipe Suggestions'), body: StreamBuilder<List<PantryItem>>(
      stream: provider.pantryService.streamItems(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final available = snapshot.data!.where((item) => item.status != PantryStatus.expired && item.quantity > 0).toList();
        final byCategory = <String, List<PantryItem>>{};
        for (final item in available) { byCategory.putIfAbsent(item.category, () => []).add(item); }
        return ListView(padding: const EdgeInsets.all(16), children: [
          PantryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cook with what you have', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(available.isEmpty ? 'Add available pantry items to see ingredient-based meal ideas.' : '${available.length} available ingredients are ready to use. Suggestions only use your current pantry items.') ])),
          const SizedBox(height: 16),
          if (available.isNotEmpty) ...byCategory.entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 12), child: PantryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.restaurant_menu_rounded), const SizedBox(width: 10), Expanded(child: Text('${entry.key} ingredient idea', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)))]), const SizedBox(height: 10), Text(entry.value.map((item) => item.name).join(', ')), const SizedBox(height: 8), Text('Use these ${entry.value.length} available ${entry.key.toLowerCase()} item${entry.value.length == 1 ? '' : 's'} as the base for your next meal.', style: Theme.of(context).textTheme.bodySmall)])))),
        ]);
      },
    ));
  }
}
