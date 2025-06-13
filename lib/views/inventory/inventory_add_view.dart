import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/inventory_item.dart';
import '../../../services/inventory_service.dart';

class InventoryAddView extends StatelessWidget {
  const InventoryAddView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final priceController = TextEditingController();

    final inventoryService = Provider.of<InventoryService>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
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
              onPressed: () async {
                final name = nameController.text.trim();
                final qty = int.tryParse(qtyController.text.trim()) ?? 0;
                final price =
                    double.tryParse(priceController.text.trim()) ?? 0.0;

                if (name.isEmpty || qty <= 0 || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid item details'),
                    ),
                  );
                  return;
                }

                final newItem = InventoryItem(
                  id: '', // Firestore will generate ID
                  name: name,
                  quantity: qty,
                  price: price,
                  category: '', // Add input if needed
                );

                final docRef = await FirebaseFirestore.instance
                    .collection('inventory')
                    .add({
                      'name': newItem.name,
                      'quantity': newItem.quantity,
                      'price': newItem.price,
                      'category': newItem.category,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                // Save the Firestore-generated ID into your item
                final itemWithId = InventoryItem(
                  id: docRef.id, // ✅ Use the generated document ID
                  name: name,
                  quantity: qty,
                  price: price,
                  category: '',
                );

                // Optionally add it to your service/provider if needed
                try {
                  await inventoryService.addItem(itemWithId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item added successfully')),
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add item: $e')),
                  );
                }

                try {
                  await inventoryService.addItem(newItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item added successfully')),
                  );
                  Navigator.pop(
                    context,
                    true,
                  ); // ✅ Return true to trigger reload
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add item: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 30),

            // 👇 StreamBuilder to show current items
            Expanded(
              child: StreamBuilder<List<InventoryItem>>(
                stream: inventoryService.getItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No inventory items found.'),
                    );
                  }

                  final items = snapshot.data!;

                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          'Qty: ${item.quantity}, Price: RM${item.price.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
