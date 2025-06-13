import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';

class InventoryService {
  final CollectionReference _inventory = FirebaseFirestore.instance.collection(
    'inventory',
  );

  // ✅ Add inventory with custom ID (preserve ID consistency)
  Future<void> addItem(InventoryItem item) async {
    final docRef = _inventory.doc(); // Create a new doc with a generated ID
    final newItem = item.copyWith(
      id: docRef.id,
    ); // Assign the generated ID to the item
    await docRef.set(newItem.toJson()); // Save to Firestore
  }

  // ✅ Get all inventory items as a stream (auto-update UI)
  Stream<List<InventoryItem>> getItems() {
    return _inventory.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) => InventoryItem.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList(),
    );
  }

  // ✅ Get items once (optional if you don’t need stream)
  Future<List<InventoryItem>> fetchAllItemsOnce() async {
    final snapshot = await _inventory.get();
    return snapshot.docs.map((doc) {
      return InventoryItem.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // ✅ Update inventory item
  Future<void> updateItem(String id, InventoryItem item) async {
    await _inventory.doc(id).update(item.toJson());
  }

  // ✅ Delete inventory item
  Future<void> deleteItem(String id) async {
    await _inventory.doc(id).delete();
  }

  // ✅ Optional: Get a single item by ID
  Future<InventoryItem?> getItemById(String id) async {
    final doc = await _inventory.doc(id).get();
    if (doc.exists) {
      return InventoryItem.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }
}
