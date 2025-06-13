import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../../models/inventory_request.dart';
import '../../models/inventory_usage.dart';
import 'dart:math';

class InventoryViewModel extends ChangeNotifier {
  List<InventoryItem> _items = [];
  final List<InventoryRequest> _requests = [];
  final List<InventoryUsage> _usageHistory = []; // Step 2a

  bool _isLoading = false;

  List<InventoryItem> get items => _items;
  List<InventoryRequest> get pendingRequests => _requests;
  List<InventoryUsage> get usageHistory => _usageHistory;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    final snapshot =
        await FirebaseFirestore.instance.collection('inventory').get();

    _items =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return InventoryItem(
            id: doc.id,
            name: data['name'],
            quantity: data['quantity'],
            price: (data['price'] as num).toDouble(),
            category: data['category'] ?? '',
          );
        }).toList();

    _isLoading = false;
    notifyListeners();
  }

  // Add item
  void addItem(String name, int quantity, double price) {
    final newItem = InventoryItem(
      id: Random().nextInt(100000).toString(),
      name: name,
      quantity: quantity,
      price: price,
      category: '',
    );
    _items.add(newItem);
    notifyListeners();
  }

  // Update item
  void updateItem(String id, String name, int quantity, double price) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('inventory').doc(id);
      await docRef.update({'name': name, 'quantity': quantity, 'price': price});

      // Update local list to reflect the change immediately in UI
      final index = _items.indexWhere((item) => item.id == id);
      if (index != -1) {
        _items[index] = InventoryItem(
          id: id,
          name: name,
          quantity: quantity,
          price: price,
          category: '',
        );
        notifyListeners();
      }
    } catch (e) {
      print("Error updating item: $e");
    }
  }

  // ✅ Update quantity only
  void updateQuantity(String id, int newQuantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = InventoryItem(
        id: current.id,
        name: current.name,
        category: current.category,
        quantity: newQuantity,
        price: current.price,
      );
      notifyListeners();
    }
  }

  // Delete item
  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ✅ Step 2c: Get item by ID (null-safe)
  InventoryItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  // ✅ Step 2b: Mark item used/damaged + log to usage history
  void markItemStatus(String id, String status) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _items[index];

      // Reduce quantity only if marked as used
      final updatedQuantity =
          (status == 'used' && item.quantity > 0)
              ? item.quantity - 1
              : item.quantity;

      _items[index] = InventoryItem(
        id: item.id,
        name: item.name,
        category: item.category,
        quantity: updatedQuantity,
        price: item.price,
      );

      // Record in usage history
      _usageHistory.add(
        InventoryUsage(
          itemId: item.id,
          status: status,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    }
  }

  // ✅ Step 2c: Get usage history for an item
  List<InventoryUsage> getUsageHistory(String itemId) {
    return _usageHistory.where((usage) => usage.itemId == itemId).toList();
  }

  // Inventory Requests: Foreman actions
  void addRequest(String itemName, int quantity, String requestedBy) {
    final request = InventoryRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: itemName,
      quantity: quantity,
      requestedBy: requestedBy,
    );
    _requests.add(request);
    notifyListeners();
  }

  // Approve request: Owner
  void approveRequest(String requestId) {
    _requests.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }

  // Reject request: Owner
  void rejectRequest(String requestId) {
    _requests.removeWhere((r) => r.id == requestId);
    notifyListeners();
  }
}
