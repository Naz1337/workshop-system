import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inventory/inventory_viewmodel.dart';

class InventoryRequestsView extends StatelessWidget {
  const InventoryRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryViewModel>(
      builder: (context, viewModel, _) {
        final requests = viewModel.pendingRequests;

        return Scaffold(
          appBar: AppBar(title: const Text('Item Requests')),
          body:
              requests.isEmpty
                  ? const Center(child: Text('No item requests found.'))
                  : ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            '${request.itemName} (Qty: ${request.quantity})',
                          ),
                          subtitle: Text(
                            'Requested by: ${request.requestedBy}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  viewModel.approveRequest(request.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request approved.'),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  viewModel.rejectRequest(request.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Request rejected.'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        );
      },
    );
  }
}
