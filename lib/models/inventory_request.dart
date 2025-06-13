class InventoryRequest {
  final String id;
  final String itemName;
  final int quantity;
  final String requestedBy;

  InventoryRequest({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.requestedBy,
  });
}
