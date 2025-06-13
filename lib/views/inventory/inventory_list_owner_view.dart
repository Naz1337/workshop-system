import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/inventory_item.dart';

class InventoryListOwnerView extends StatelessWidget {
  const InventoryListOwnerView({super.key});

  Stream<List<InventoryItem>> getInventoryStream() {
    return FirebaseFirestore.instance
        .collection('inventory')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return InventoryItem(
              id: doc.id,
              name: doc['name'] ?? '',
              quantity: doc['quantity'] ?? 0,
              price: (doc['price'] ?? 0).toDouble(),
              category: '',
            );
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Item',
            onPressed: () async {
              await context.push('/inventory/add');
              // No need to reload manually — StreamBuilder listens for changes
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Usage History',
            onPressed: () => context.push('/inventory/history'),
          ),
          IconButton(
            icon: const Icon(Icons.approval),
            tooltip: 'Approve Item Requests',
            onPressed: () => context.push('/inventory/requests'),
          ),
        ],
      ),
      body: StreamBuilder<List<InventoryItem>>(
        stream: getInventoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('No inventory items found.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text(
                    'Qty: ${item.quantity} | Price: RM${item.price.toStringAsFixed(2)}',
                  ),
                  onTap: () => context.push('/inventory/details/${item.id}'),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.push('/inventory/edit/${item.id}');
                          break;
                        case 'delete':
                          FirebaseFirestore.instance
                              .collection('inventory')
                              .doc(item.id)
                              .delete();
                          break;
                        case 'update_quantity':
                          context.push('/inventory/update/${item.id}');
                          break;
                        case 'mark_damaged':
                          context.push('/inventory/damaged/${item.id}');
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit Item'),
                          ),
                          PopupMenuItem(
                            value: 'update_quantity',
                            child: Text('Update Quantity'),
                          ),
                          PopupMenuItem(
                            value: 'mark_damaged',
                            child: Text('Mark as Used/Damaged'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete Item'),
                          ),
                        ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
