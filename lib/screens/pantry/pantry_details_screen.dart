import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/models/pantry_item.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/widgets/app_modal.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

class PantryDetailsScreen extends StatelessWidget {
  const PantryDetailsScreen({super.key, required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PantryAppBar(title: item.name),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PantryCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: PantryAppTheme.softYellow, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.kitchen, color: PantryAppTheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  Text(item.category, style: TextStyle(color: Colors.grey.shade700)),
                ])),
                Chip(label: Text(item.status.name.toUpperCase()), backgroundColor: item.status == PantryStatus.expired ? Colors.red.shade100 : item.status == PantryStatus.expiringSoon ? Colors.orange.shade100 : Colors.green.shade100),
              ]),
              const SizedBox(height: 16),
              _detailRow('Quantity', '${item.quantity} ${item.unit}'),
              _detailRow('Purchase Date', item.purchaseDate.toLocal().toString().split(' ')[0]),
              _detailRow('Expiration Date', item.expirationDate.toLocal().toString().split(' ')[0]),
              _detailRow('Storage', item.storageLocation),
            ]),
          ),
          const SizedBox(height: 16),
          PantryCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Suggested Recipes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('View ingredient-based suggestions generated from your available pantry items in Recipe Suggestions.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ]),
          ),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: [
            PantryPrimaryButton(label: 'Mark as Consumed', onPressed: () async { final provider = context.read<AppProvider>(); final confirmed = await AppModal.show(context, type: AppModalType.confirmation, title: 'Mark as consumed?', message: 'This sets ${item.name} quantity to zero.', confirmText: 'Confirm'); if (confirmed == true) { await provider.pantryService.updateItem(PantryItem(id: item.id, userId: item.userId, name: item.name, category: item.category, quantity: 0, unit: item.unit, purchaseDate: item.purchaseDate, expirationDate: item.expirationDate, storageLocation: item.storageLocation, barcode: item.barcode, imageUrl: item.imageUrl, createdAt: item.createdAt)); if (context.mounted) Navigator.pop(context); } }, icon: Icons.check_circle_outline),
            PantryOutlinedButton(
              label: 'Delete',
              onPressed: () async {
                final confirmed = await AppModal.show(context, type: AppModalType.confirmation, title: 'Delete item?', message: 'This will remove ${item.name} from your pantry.', confirmText: 'Delete');
                if ((confirmed ?? false) && context.mounted) {
                  await context.read<AppProvider>().pantryService.deleteItem(item.id);
                  Navigator.pop(context);
                }
              },
              icon: Icons.delete_outline,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), Text(value)]),
    );
  }
}
