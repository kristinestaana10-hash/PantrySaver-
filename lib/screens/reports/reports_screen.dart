import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/models/expense.dart';
import 'package:pantrysaver/models/pantry_item.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/utils/formatters.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>(); final user = provider.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(appBar: const PantryAppBar(title: 'Reports'), body: StreamBuilder<List<PantryItem>>(stream: provider.pantryService.streamItems(user.uid), builder: (context, pantry) => StreamBuilder<List<Expense>>(stream: provider.budgetService.streamExpenses(user.uid), builder: (context, expenses) {
      if (!pantry.hasData || !expenses.hasData) return const Center(child: CircularProgressIndicator());
      final now = DateTime.now(); final currentExpenses = expenses.data!.where((e) => e.dateCreated.year == now.year && e.dateCreated.month == now.month).toList(); final spent = currentExpenses.fold<double>(0, (sum, e) => sum + e.amount); final budget = provider.profile?.monthlyBudget ?? 0; final items = pantry.data!; final expired = items.where((i) => i.status == PantryStatus.expired).toList(); final expiring = items.where((i) => i.status == PantryStatus.expiringSoon).length; final low = items.where((i) => i.quantity <= 1).length;
      return ListView(padding: const EdgeInsets.all(16), children: [
        _section(context, 'Budget summary', Icons.account_balance_wallet_outlined, [
          _line('Monthly budget', peso(budget)), _line('Total grocery expenses', peso(spent)), _line('Remaining budget', peso(budget - spent)), _line('Budget used', budget <= 0 ? 'No budget set' : '${(spent / budget * 100).toStringAsFixed(0)}%'),
        ]),
        _section(context, 'Pantry summary', Icons.kitchen_outlined, [_line('Total pantry items', '${items.length}'), _line('Fresh items', '${items.where((i) => i.status == PantryStatus.fresh).length}'), _line('Expiring soon', '$expiring'), _line('Low stock', '$low')]),
        _section(context, 'Food waste summary', Icons.delete_outline, [_line('Expired items', '${expired.length}'), _line('Expired item names', expired.isEmpty ? 'None' : expired.map((i) => i.name).join(', '))]),
        _section(context, 'Grocery expense summary', Icons.receipt_long_outlined, [_line('Purchases this month', '${currentExpenses.length}'), _line('Average purchase', currentExpenses.isEmpty ? peso(0) : peso(spent / currentExpenses.length)), _line('Most recent purchase', currentExpenses.isEmpty ? 'None' : '${currentExpenses.first.groceryStore} • ${peso(currentExpenses.first.amount)}')]),
      ]);
    })));
  }
  Widget _line(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label)), const SizedBox(width: 12), Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700)))]));
  Widget _section(BuildContext context, String title, IconData icon, List<Widget> rows) => Padding(padding: const EdgeInsets.only(bottom: 14), child: PantryCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 10), Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))]), const Divider(height: 24), ...rows])));
}
