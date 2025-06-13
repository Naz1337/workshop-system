class InventoryUsage {
  final String itemId;
  final String status; // e.g., "used" or "damaged"
  final DateTime timestamp;

  InventoryUsage({
    required this.itemId,
    required this.status,
    required this.timestamp,
  });
}
