import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inventory/inventory_viewmodel.dart';
import '../../models/inventory_item.dart';

class InventoryUpdateQuantityView extends StatefulWidget {
  final String itemId;

  const InventoryUpdateQuantityView({super.key, required this.itemId});

  @override
  State<InventoryUpdateQuantityView> createState() =>
      _InventoryUpdateQuantityViewState();
}

class _InventoryUpdateQuantityViewState
    extends State<InventoryUpdateQuantityView> {
  final _formKey = GlobalKey<FormState>();
  int? _updatedQuantity;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);
    final InventoryItem? item = viewModel.getItemById(widget.itemId);

    if (item == null) {
      return const Scaffold(body: Center(child: Text('Item not found.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Update Quantity - ${item.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Current Quantity: ${item.quantity}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'New Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _updatedQuantity = int.tryParse(value!);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    if (_updatedQuantity != null) {
                      viewModel.updateQuantity(item.id, _updatedQuantity!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quantity updated')),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Update Quantity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
