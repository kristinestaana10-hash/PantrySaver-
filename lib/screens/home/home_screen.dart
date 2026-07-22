import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/models/expense.dart';
import 'package:pantrysaver/models/pantry_item.dart';
import 'package:pantrysaver/models/user_profile.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/screens/budget/budget_screen.dart';
import 'package:pantrysaver/screens/notifications/notifications_screen.dart';
import 'package:pantrysaver/screens/pantry/pantry_screen.dart';
import 'package:pantrysaver/screens/profile/profile_screen.dart';
import 'package:pantrysaver/screens/recipes/recipes_screen.dart';
import 'package:pantrysaver/screens/reports/reports_screen.dart';
import 'package:pantrysaver/screens/shopping/shopping_screen.dart';
import 'package:pantrysaver/utils/formatters.dart';
import 'package:pantrysaver/widgets/app_modal.dart';
import 'package:pantrysaver/widgets/shared/app_bottom_nav.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pages = const [HomeDashboard(), PantryScreen(), ShoppingScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: PantryBottomNav(currentIndex: _currentIndex, onTap: (index) => setState(() => _currentIndex = index)),
      );
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: PantryAppBar(
        title: 'PantrySaver',
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          IconButton(icon: const Icon(Icons.dark_mode_outlined), onPressed: () => provider.toggleDarkMode(!provider.darkMode)),
        ],
      ),
      body: StreamBuilder<List<PantryItem>>(
        stream: provider.pantryService.streamItems(user.uid),
        builder: (context, pantrySnapshot) => StreamBuilder<List<Expense>>(
          stream: provider.budgetService.streamExpenses(user.uid),
          builder: (context, expenseSnapshot) {
            if (!pantrySnapshot.hasData || !expenseSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            final items = pantrySnapshot.data!;
            final expenses = expenseSnapshot.data!;
            final now = DateTime.now();
            final budget = provider.profile?.monthlyBudget ?? 0;
            final spent = expenses.where((expense) => expense.dateCreated.year == now.year && expense.dateCreated.month == now.month).fold<double>(0, (total, expense) => total + expense.amount);
            final remaining = budget - spent;
            final expiring = items.where((item) => item.status == PantryStatus.expiringSoon).length;
            final expired = items.where((item) => item.status == PantryStatus.expired).length;
            final lowStock = items.where((item) => item.quantity <= 1).length;
            final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text('Good morning, ${provider.profile?.fullName ?? 'there'}!', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                _budgetSummary(context, budget: budget, spent: spent, remaining: remaining, progress: progress),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Quick summary cards'),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = (constraints.maxWidth - 20) / 3;
                    return Wrap(spacing: 10, runSpacing: 10, children: [
                      DashboardMetricCard(width: width, label: 'Pantry items', value: '${items.length}', icon: Icons.kitchen_outlined, color: Theme.of(context).colorScheme.primary),
                      DashboardMetricCard(width: width, label: 'Expiring soon', value: '$expiring', icon: Icons.timer_outlined, color: Colors.orange),
                      DashboardMetricCard(width: width, label: 'Low stock', value: '$lowStock', icon: Icons.warning_amber_rounded, color: Colors.amber.shade800),
                      DashboardMetricCard(width: width, label: 'Expired', value: '$expired', icon: Icons.error_outline_rounded, color: Theme.of(context).colorScheme.error),
                      DashboardMetricCard(width: width, label: 'Expenses', value: peso(spent), icon: Icons.receipt_long_outlined, color: Colors.orange),
                      DashboardMetricCard(width: width, label: 'Remaining', value: peso(remaining), icon: Icons.savings_outlined, color: remaining < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
                    ]);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showSetBudgetDialog(context, provider),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('Set monthly budget'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen())),
                        icon: const Icon(Icons.add_card_outlined),
                        label: const Text('Manage expenses'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _sectionTitle(context, 'Recent grocery purchases', action: 'See all', onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetScreen()))),
                const SizedBox(height: 8),
                if (expenses.isEmpty) const PantryCard(child: Text('No grocery purchases recorded yet.')) else ...expenses.take(3).map(_expenseTile),
                const SizedBox(height: 16),
                _sectionTitle(context, 'Recent pantry items', action: 'See all', onAction: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryScreen()))),
                const SizedBox(height: 8),
                if (items.isEmpty) const PantryCard(child: Text('No pantry items recorded yet.')) else ...items.take(3).map(_pantryTile),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _action(context, 'Shopping list', Icons.shopping_bag_outlined, const ShoppingScreen()),
                  _action(context, 'Recipes', Icons.restaurant_menu_outlined, const RecipesScreen()),
                  _action(context, 'Reports', Icons.bar_chart_outlined, const ReportsScreen()),
                ]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _budgetSummary(BuildContext context, {required double budget, required double spent, required double remaining, required double progress}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: .22), blurRadius: 16, offset: const Offset(0, 8))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Monthly grocery budget', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: .85))),
          const SizedBox(height: 4),
          Text(peso(budget), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: _budgetValue(context, 'Total spent', peso(spent))), const SizedBox(width: 14), Expanded(child: _budgetValue(context, 'Remaining budget', peso(remaining)))]),
          const SizedBox(height: 14),
          ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: Colors.white.withValues(alpha: .28), color: Theme.of(context).colorScheme.secondary)),
        ]),
      );

  Future<void> _showSetBudgetDialog(BuildContext context, AppProvider provider) async {
    final profile = provider.profile;
    if (profile == null) return;
    final controller = TextEditingController(text: profile.monthlyBudget == 0 ? '' : profile.monthlyBudget.toStringAsFixed(2));
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.account_balance_wallet_outlined),
        title: const Text('Set monthly budget'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Set the amount you plan to spend on groceries this month.'),
          const SizedBox(height: 16),
          TextField(controller: controller, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Monthly grocery budget', prefixText: '₱ ')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text.trim());
              if (amount == null || amount < 0) {
                await AppModal.show(dialogContext, type: AppModalType.error, title: 'Invalid budget', message: 'Enter a valid monthly budget amount.');
                return;
              }
              await provider.updateProfile(UserProfile(uid: profile.uid, fullName: profile.fullName, email: profile.email, monthlyBudget: amount, createdAt: profile.createdAt, notificationsEnabled: profile.notificationsEnabled));
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) await AppModal.show(context, type: AppModalType.success, title: 'Monthly budget saved', message: 'Your monthly grocery budget is ${peso(amount)}.');
            },
            child: const Text('Save budget'),
          ),
        ],
      ),
    );
  }

  Widget _budgetValue(BuildContext context, String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: .8))), const SizedBox(height: 2), Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w800))]);
  Widget _sectionTitle(BuildContext context, String title, {String? action, VoidCallback? onAction}) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), if (action != null) TextButton(onPressed: onAction, child: Text(action))]);
  Widget _action(BuildContext context, String label, IconData icon, Widget screen) => ActionChip(avatar: Icon(icon), label: Text(label), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)));
  Widget _expenseTile(Expense expense) => Padding(padding: const EdgeInsets.only(bottom: 8), child: PantryCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.shopping_basket_outlined)), title: Text(expense.groceryStore, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(shortDate(expense.dateCreated)), trailing: Text(peso(expense.amount), style: const TextStyle(fontWeight: FontWeight.w700)))));
  Widget _pantryTile(PantryItem item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: PantryCard(child: ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.kitchen_outlined)), title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('${item.quantity} ${item.unit} • ${shortDate(item.expirationDate)}'), trailing: Text(item.status == PantryStatus.expired ? 'Expired' : item.status == PantryStatus.expiringSoon ? 'Expiring soon' : 'Fresh'))));
}

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({super.key, required this.width, required this.label, required this.value, required this.icon, required this.color});
  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: PantryCard(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 19)), const SizedBox(height: 10), Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(label, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)])));
}
