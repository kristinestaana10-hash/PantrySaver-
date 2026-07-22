import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pantrysaver/models/expense.dart';
import 'package:pantrysaver/models/user_profile.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/utils/formatters.dart';
import 'package:pantrysaver/widgets/app_modal.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: PantryAppBar(title: 'Grocery Budget', actions: [IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () => _showBudgetDialog(context, provider))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showExpenseDialog(context, provider), icon: const Icon(Icons.add), label: const Text('Add expense')),
      body: StreamBuilder<List<Expense>>(
        stream: provider.budgetService.streamExpenses(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load expenses: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final expenses = snapshot.data!;
          final budget = provider.profile?.monthlyBudget ?? 0;
          final now = DateTime.now();
          final spent = expenses.where((e) => e.dateCreated.year == now.year && e.dateCreated.month == now.month).fold<double>(0, (sum, e) => sum + e.amount);
          final remaining = budget - spent;
          final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
          return ListView(padding: const EdgeInsets.all(16), children: [
            PantryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This month', style: Theme.of(context).textTheme.titleMedium), const SizedBox(height: 8),
              Text(peso(remaining), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: remaining < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary)),
              Text(remaining < 0 ? 'Over budget' : 'remaining from ${peso(budget)}'), const SizedBox(height: 16),
              LinearProgressIndicator(value: progress, minHeight: 10, borderRadius: BorderRadius.circular(99), color: remaining < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10), Text('${peso(spent)} spent • ${(progress * 100).toStringAsFixed(0)}% used'),
            ])),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: _metric(context, 'Monthly budget', peso(budget), Icons.account_balance_wallet_outlined)), const SizedBox(width: 12), Expanded(child: _metric(context, 'Grocery expenses', peso(spent), Icons.receipt_long_outlined))]),
            const SizedBox(height: 24), Text('Recent grocery purchases', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
            if (expenses.isEmpty) const PantryCard(child: Text('No grocery expenses yet. Add your first purchase to track your budget.')),
            ...expenses.map((expense) => Padding(padding: const EdgeInsets.only(bottom: 10), child: PantryCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.shopping_cart_outlined)), title: Text(expense.groceryStore, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${shortDate(expense.dateCreated)}${expense.notes.isEmpty ? '' : ' • ${expense.notes}'}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(peso(expense.amount), style: const TextStyle(fontWeight: FontWeight.w700)), IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showExpenseDialog(context, provider, existing: expense)), IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteExpense(context, provider, expense))]))))),
          ]);
        },
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String amount, IconData icon) => PantryCard(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 10), Text(label), const SizedBox(height: 4), Text(amount, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))]));

  Future<void> _showBudgetDialog(BuildContext context, AppProvider provider) async {
    final controller = TextEditingController(text: (provider.profile?.monthlyBudget ?? 0).toStringAsFixed(2));
    await showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Set monthly budget'), content: TextField(controller: controller, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(prefixText: '₱ ', labelText: 'Budget amount')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () async { final amount = double.tryParse(controller.text.trim()); if (amount == null || amount < 0) { await AppModal.show(dialogContext, type: AppModalType.error, title: 'Invalid amount', message: 'Enter a valid budget amount.'); return; } final profile = provider.profile; if (profile == null) return; await provider.updateProfile(UserProfile(uid: profile.uid, fullName: profile.fullName, email: profile.email, monthlyBudget: amount, createdAt: profile.createdAt, notificationsEnabled: profile.notificationsEnabled)); if (dialogContext.mounted) Navigator.pop(dialogContext); if (context.mounted) await AppModal.show(context, type: AppModalType.success, title: 'Budget updated', message: 'Your monthly budget is now ${peso(amount)}.'); }, child: const Text('Save'))]));
  }

  Future<void> _showExpenseDialog(BuildContext context, AppProvider provider, {Expense? existing}) async {
    final store = TextEditingController(text: existing?.groceryStore ?? ''); final amount = TextEditingController(text: existing?.amount.toString() ?? ''); final notes = TextEditingController(text: existing?.notes ?? '');
    await showDialog(context: context, builder: (dialogContext) => AlertDialog(title: Text(existing == null ? 'Add grocery expense' : 'Update grocery expense'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: store, decoration: const InputDecoration(labelText: 'Grocery store')), const SizedBox(height: 12), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(prefixText: '₱ ', labelText: 'Amount')), const SizedBox(height: 12), TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes (optional)'))])), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () async { final value = double.tryParse(amount.text.trim()); if (store.text.trim().isEmpty || value == null || value < 0) { await AppModal.show(dialogContext, type: AppModalType.error, title: 'Check your details', message: 'Enter a grocery store and valid amount.'); return; } final expense = Expense(id: existing?.id ?? const Uuid().v4(), userId: provider.currentUser!.uid, groceryStore: store.text.trim(), amount: value, notes: notes.text.trim(), dateCreated: existing?.dateCreated ?? DateTime.now()); if (existing == null) { await provider.budgetService.addExpense(expense); } else { await provider.budgetService.updateExpense(expense); } if (dialogContext.mounted) Navigator.pop(dialogContext); }, child: Text(existing == null ? 'Add' : 'Update'))]));
  }

  Future<void> _deleteExpense(BuildContext context, AppProvider provider, Expense expense) async { final confirmed = await AppModal.show(context, type: AppModalType.confirmation, title: 'Delete expense?', message: 'Remove ${expense.groceryStore} from your expense history?', confirmText: 'Delete'); if (confirmed == true) await provider.budgetService.deleteExpense(expense.id); }
}
