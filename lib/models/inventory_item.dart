class InventoryItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final double price;
  final String status; // ✅ Add this line

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    this.status = 'available', // ✅ default value
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json, String id) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      status: json['status'] ?? 'available',
    );
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    int? quantity,
    double? price,
    String? category,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }
}
