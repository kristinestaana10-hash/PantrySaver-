import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/models/expense.dart';
import 'package:pantrysaver/models/pantry_item.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/utils/formatters.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>(); final user = provider.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(appBar: const PantryAppBar(title: 'Notifications'), body: StreamBuilder<List<PantryItem>>(stream: provider.pantryService.streamItems(user.uid), builder: (context, pantrySnapshot) => StreamBuilder<List<Expense>>(stream: provider.budgetService.streamExpenses(user.uid), builder: (context, expenseSnapshot) {
      if (!pantrySnapshot.hasData || !expenseSnapshot.hasData) return const Center(child: CircularProgressIndicator());
      final items = pantrySnapshot.data!; final now = DateTime.now(); final spent = expenseSnapshot.data!.where((e) => e.dateCreated.year == now.year && e.dateCreated.month == now.month).fold<double>(0, (sum, e) => sum + e.amount); final budget = provider.profile?.monthlyBudget ?? 0;
      final notices = <({String title, String message, IconData icon, Color color})>[];
      for (final item in items.where((i) => i.status == PantryStatus.expired)) { notices.add((title: 'Expired item', message: '${item.name} has expired.', icon: Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error)); }
      for (final item in items.where((i) => i.status == PantryStatus.expiringSoon)) { notices.add((title: 'Expiring soon', message: '${item.name} expires on ${shortDate(item.expirationDate)}.', icon: Icons.timer_outlined, color: Colors.orange)); }
      for (final item in items.where((i) => i.quantity <= 1)) { notices.add((title: 'Low stock', message: '${item.name} has ${item.quantity} ${item.unit} left.', icon: Icons.inventory_2_outlined, color: Colors.orange)); }
      if (budget > 0 && spent >= budget) notices.add((title: 'Budget limit reached', message: 'You have spent ${peso(spent)} of your ${peso(budget)} monthly budget.', icon: Icons.account_balance_wallet_outlined, color: Theme.of(context).colorScheme.error));
      return notices.isEmpty ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('You are all caught up. No pantry or budget alerts right now.'))) : ListView.separated(padding: const EdgeInsets.all(16), itemCount: notices.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, index) { final note = notices[index]; return PantryCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(backgroundColor: note.color.withValues(alpha: .15), child: Icon(note.icon, color: note.color)), title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(note.message))); });
    })));
  }
}
