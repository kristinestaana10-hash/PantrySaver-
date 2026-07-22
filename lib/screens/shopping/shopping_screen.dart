import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/models/shopping_item.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/widgets/app_modal.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';
import 'package:uuid/uuid.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      appBar: const PantryAppBar(title: 'Shopping List'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(context, provider),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: PantryAppTheme.primary,
      ),
      body: StreamBuilder<List<ShoppingItem>>(
        stream: provider.shoppingService.streamItems(provider.currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: PantryCard(
                  child: ListTile(
                    title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('Qty: ${item.quantity}'),
                    leading: Checkbox(value: item.purchased, onChanged: (value) async {
                      await provider.shoppingService.updateItem(ShoppingItem(
                        id: item.id,
                        userId: item.userId,
                        itemName: item.itemName,
                        quantity: item.quantity,
                        purchased: value ?? false,
                        createdAt: item.createdAt,
                      ));
                    }),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showDialog(context, provider, existing: item)), IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await AppModal.show(
                          context,
                          type: AppModalType.confirmation,
                          title: 'Delete item?',
                          message: 'This will remove ${item.itemName} from your shopping list.',
                          confirmText: 'Delete',
                          cancelText: 'Keep it',
                        );
                        if (confirmed ?? false) {
                          await provider.shoppingService.deleteItem(item.id);
                        }
                      },
                    )]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showDialog(BuildContext context, AppProvider provider, {ShoppingItem? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.itemName ?? '');
    final quantityController = TextEditingController(text: existing?.quantity.toString() ?? '1');
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Shopping Item' : 'Edit Shopping Item'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'), validator: (v) => int.tryParse(v ?? '') == null || int.parse(v!) < 0 ? 'Enter a valid quantity' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final itemName = nameController.text.trim();
              final pantryHasItem = (await provider.pantryService.streamItems(provider.currentUser!.uid).first).any((entry) => entry.name.toLowerCase() == itemName.toLowerCase());
              if (pantryHasItem && existing == null) {
                if (context.mounted) {
                  final continueAdding = await AppModal.show(context, type: AppModalType.warning, title: 'Already in your pantry', message: '$itemName is already available in your pantry. Add it to the shopping list anyway only if you need more.', confirmText: 'Add anyway', cancelText: 'Cancel', showCancelButton: true);
                  if (continueAdding != true) return;
                }
              }
              final item = ShoppingItem(
                id: existing?.id ?? const Uuid().v4(),
                userId: provider.currentUser!.uid,
                itemName: itemName,
                quantity: int.parse(quantityController.text),
                purchased: existing?.purchased ?? false,
                createdAt: existing?.createdAt ?? DateTime.now(),
              );
              if (existing == null) { await provider.shoppingService.addItem(item); } else { await provider.shoppingService.updateItem(item); }
              if (context.mounted) {
                Navigator.pop(ctx);
                await AppModal.show(
                  context,
                  type: AppModalType.success,
                  title: existing == null ? 'Shopping item added' : 'Shopping item updated',
                  message: existing == null ? 'Your item is now on the list.' : 'Your changes were saved.',
                  confirmText: 'Nice',
                );
              }
            },
            child: Text(existing == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }
}
