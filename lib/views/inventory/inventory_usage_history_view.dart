import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inventory/inventory_viewmodel.dart';
import '../../models/inventory_item.dart';

class InventoryUsageHistoryView extends StatelessWidget {
  final String itemId;

  const InventoryUsageHistoryView({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);
    final InventoryItem? item = viewModel.getItemById(itemId);

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found.')));
    }

    // Simulated usage history
    final usageHistory = viewModel.getUsageHistory(item.id);

    return Scaffold(
      appBar: AppBar(title: Text('Usage History - ${item.name}')),
      body:
          usageHistory.isEmpty
              ? const Center(child: Text('No usage history available.'))
              : ListView.builder(
                itemCount: usageHistory.length,
                itemBuilder: (context, index) {
                  final entry = usageHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Status: ${entry.status}'),
                    subtitle: Text('Date: ${entry.timestamp.toString()}'),
                  );
                },
              ),
    );
  }
}
