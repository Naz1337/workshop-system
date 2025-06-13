import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inventory/inventory_viewmodel.dart';
import '../../models/inventory_item.dart';

class InventoryEditView extends StatefulWidget {
  final String itemId;
  const InventoryEditView({required this.itemId, super.key});

  @override
  State<InventoryEditView> createState() => _InventoryEditViewState();
}

class _InventoryEditViewState extends State<InventoryEditView> {
  late TextEditingController nameController;
  late TextEditingController qtyController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    qtyController = TextEditingController();
    priceController = TextEditingController();

    // Wait for the widget to build before checking for item
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<InventoryViewModel>(context, listen: false);

      // If items are not yet loaded, wait for them
      if (viewModel.items.isEmpty) {
        viewModel.loadItems().then((_) {
          final item = viewModel.getItemById(widget.itemId);
          if (item != null) {
            nameController.text = item.name;
            qtyController.text = item.quantity.toString();
            priceController.text = item.price.toString();
            setState(() {}); // Rebuild with data
          }
        });
      } else {
        final item = viewModel.getItemById(widget.itemId);
        if (item != null) {
          nameController.text = item.name;
          qtyController.text = item.quantity.toString();
          priceController.text = item.price.toString();
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);
    final item = viewModel.getItemById(widget.itemId);

    if (item == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                viewModel.updateItem(
                  item.id,
                  nameController.text,
                  int.parse(qtyController.text),
                  double.parse(priceController.text),
                );
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
