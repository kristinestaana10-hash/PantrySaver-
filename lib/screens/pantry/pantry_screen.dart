import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pantrysaver/models/pantry_item.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/screens/pantry/pantry_details_screen.dart';
import 'package:pantrysaver/widgets/app_modal.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

const _pantryCategories = <String>[
  'Fruit',
  'Vegetable',
  'Protein',
  'Dairy',
  'Grain',
  'Beverage',
  'Snack',
  'Condiment',
  'Frozen',
  'Other',
];

const _storageLocations = <String>[
  'Pantry',
  'Refrigerator',
  'Freezer',
  'Countertop',
  'Cupboard',
  'Cellar',
];

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _search = '';
  String _category = 'All';
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      appBar: const PantryAppBar(title: 'Pantry'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context, provider),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: PantryAppTheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Filter pantry items',
                  icon: const Icon(Icons.filter_list_rounded),
                  onSelected: (value) => setState(() {
                    if (value.startsWith('status:')) {
                      _status = value.substring('status:'.length);
                    } else {
                      _category = value.substring('category:'.length);
                    }
                  }),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'status:All', child: Text('All statuses')),
                    const PopupMenuItem(value: 'status:Fresh', child: Text('Fresh')),
                    const PopupMenuItem(value: 'status:Expiring soon', child: Text('Expiring soon')),
                    const PopupMenuItem(value: 'status:Expired', child: Text('Expired')),
                    const PopupMenuItem(value: 'status:Low stock', child: Text('Low stock (quantity 1 or less)')),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'category:All', child: Text('All categories')),
                    ..._pantryCategories.map(
                      (category) => PopupMenuItem(
                        value: 'category:$category',
                        child: Text(category),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PantryItem>>(
              stream: provider.pantryService.streamItems(provider.currentUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final items = (snapshot.data ?? []).where((item) {
                  final matchesSearch = item.name.toLowerCase().contains(_search.toLowerCase());
                  final matchesCategory = _category == 'All' || item.category == _category;
                  final matchesStatus = _status == 'All' ||
                      (_status == 'Fresh' && item.status == PantryStatus.fresh) ||
                      (_status == 'Expiring soon' && item.status == PantryStatus.expiringSoon) ||
                      (_status == 'Expired' && item.status == PantryStatus.expired) ||
                      (_status == 'Low stock' && item.quantity <= 1);
                  return matchesSearch && matchesCategory && matchesStatus;
                }).toList();
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: PantryCard(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PantryDetailsScreen(item: item))),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${item.quantity} ${item.unit} • ${item.storageLocation}'),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (item.quantity <= 1) const Icon(Icons.inventory_2_outlined, color: Colors.orange),
                            const SizedBox(width: 4),
                            Chip(label: Text(item.status.name.toUpperCase()), backgroundColor: item.status == PantryStatus.expired ? Colors.red.shade100 : item.status == PantryStatus.expiringSoon ? Colors.orange.shade100 : Colors.green.shade100),
                            PopupMenuButton<String>(onSelected: (action) async { if (action == 'edit') { await _showItemDialog(context, provider, existing: item); } else { final yes = await AppModal.show(context, type: AppModalType.confirmation, title: 'Delete pantry item?', message: 'Remove ${item.name} from your pantry?', confirmText: 'Delete'); if (yes == true) await provider.pantryService.deleteItem(item.id); } }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))]),
                          ]),
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PantryDetailsScreen(item: item))),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showItemDialog(BuildContext context, AppProvider provider, {PantryItem? existing}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existing?.name ?? '');
    final barcodeController = TextEditingController(text: existing?.barcode ?? '');
    final quantityController = TextEditingController(text: existing?.quantity.toString() ?? '1');
    final unitController = TextEditingController(text: existing?.unit ?? 'pcs');
    var category = _valueInList(existing?.category, _pantryCategories, 'Other');
    var storageLocation = _valueInList(existing?.storageLocation, _storageLocations, 'Pantry');
    DateTime purchaseDate = existing?.purchaseDate ?? DateTime.now();
    DateTime expirationDate = existing?.expirationDate ?? DateTime.now().add(const Duration(days: 30));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          title: Text(existing == null ? 'Add Pantry Item' : 'Edit Pantry Item'),
          content: SizedBox(
            width: math.min(MediaQuery.sizeOf(context).width - 40, 440),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Item name',
                        suffixIcon: IconButton(
                          tooltip: 'Scan barcode',
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          onPressed: () async {
                            final barcode = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _BarcodeScannerPage()));
                            if (barcode != null && barcode.isNotEmpty) {
                              setDialogState(() => barcodeController.text = barcode);
                            }
                          },
                        ),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter an item name' : null,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Scan barcode'),
                      onPressed: () async {
                        final barcode = await Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => const _BarcodeScannerPage()));
                        if (barcode != null && barcode.isNotEmpty) {
                          setDialogState(() => barcodeController.text = barcode);
                        }
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('The scanned code is saved with this pantry item.', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: barcodeController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Barcode (optional)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _pantryCategories.map((value) => DropdownMenuItem(value: value, child: Text(value, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (value) => setDialogState(() => category = value!),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: TextFormField(controller: quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity'), validator: (value) => int.tryParse(value ?? '') == null || int.parse(value!) < 0 ? 'Enter a valid quantity' : null)),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: unitController, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Unit'), validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null)),
                    ]),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: storageLocation,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Storage location'),
                      items: _storageLocations.map((value) => DropdownMenuItem(value: value, child: Text(value, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (value) => setDialogState(() => storageLocation = value!),
                    ),
                    const SizedBox(height: 12),
                    _DatePickerTile(label: 'Purchase date', value: purchaseDate, onTap: () async { final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDate: purchaseDate); if (picked != null) setDialogState(() => purchaseDate = picked); }),
                    _DatePickerTile(label: 'Expiration date', value: expirationDate, onTap: () async { final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDate: expirationDate); if (picked != null) setDialogState(() => expirationDate = picked); }),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (expirationDate.isBefore(purchaseDate)) {
                  await AppModal.show(context, type: AppModalType.warning, title: 'Invalid dates', message: 'Expiration date cannot be earlier than purchase date.', confirmText: 'Got it');
                  return;
                }
                final item = PantryItem(id: existing?.id ?? const Uuid().v4(), userId: provider.currentUser!.uid, name: nameController.text.trim(), category: category, quantity: int.parse(quantityController.text), unit: unitController.text.trim(), purchaseDate: purchaseDate, expirationDate: expirationDate, storageLocation: storageLocation, barcode: barcodeController.text.trim(), imageUrl: existing?.imageUrl ?? '', createdAt: existing?.createdAt ?? DateTime.now());
                if (existing == null) { await provider.pantryService.addItem(item); } else { await provider.pantryService.updateItem(item); }
                if (context.mounted) { Navigator.pop(dialogContext); await AppModal.show(context, type: AppModalType.success, title: existing == null ? 'Item added' : 'Item updated', message: existing == null ? 'Your pantry item was added successfully.' : 'Your pantry item was updated successfully.', confirmText: 'Done'); }
              },
              child: Text(existing == null ? 'Add item' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

String _valueInList(String? value, List<String> values, String fallback) => values.contains(value) ? value! : fallback;

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({required this.label, required this.value, required this.onTap});
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: const Icon(Icons.calendar_today_outlined, size: 18),
    label: Text('$label: ${value.toLocal().toString().split(' ')[0]}'),
    onPressed: onTap,
  );
}

class _BarcodeScannerPage extends StatefulWidget {
  const _BarcodeScannerPage();

  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(title: const Text('Scan barcode'), backgroundColor: Colors.black, foregroundColor: Colors.white),
    body: Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          onDetect: (capture) {
            if (_hasScanned || capture.barcodes.isEmpty) return;
            final value = capture.barcodes.first.rawValue;
            if (value == null || value.isEmpty) return;
            _hasScanned = true;
            Navigator.of(context).pop(value);
          },
        ),
        IgnorePointer(child: Center(child: Container(width: 260, height: 150, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(16)))),),
        const Positioned(left: 24, right: 24, bottom: 48, child: Text('Align the barcode inside the frame', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))),
      ],
    ),
  );
}
