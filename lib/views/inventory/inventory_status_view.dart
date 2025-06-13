import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inventory/inventory_viewmodel.dart';
import '../../models/inventory_item.dart';

class InventoryStatusView extends StatefulWidget {
  final String itemId;

  const InventoryStatusView({super.key, required this.itemId});

  @override
  State<InventoryStatusView> createState() => _InventoryStatusViewState();
}

class _InventoryStatusViewState extends State<InventoryStatusView> {
  String? _status;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);
    final InventoryItem? item = viewModel.getItemById(widget.itemId);

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mark Item Status - ${item.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item: ${item.name}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              const Text('Select Status:'),
              ListTile(
                title: const Text('Used'),
                leading: Radio<String>(
                  value: 'used',
                  groupValue: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Damaged'),
                leading: Radio<String>(
                  value: 'damaged',
                  groupValue: _status,
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_status == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a status')),
                    );
                    return;
                  }

                  viewModel.markItemStatus(item.id, _status!);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Marked as $_status')));
                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
