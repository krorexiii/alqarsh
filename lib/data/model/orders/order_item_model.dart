class OrderItemModel {
  final int id;
  final int orderId;
  final int itemId;
  final int quantity;
  final double originalUnitPrice;
  final int discountPercentSnapshot;
  final double unitPrice;
  final double lineTotal;
  final String titleSnapshot;
  final int? selectedColorId;
  final String? selectedColorName;
  final String? selectedColorHex;
  final int? selectedSizeId;
  final String? selectedSizeName;
  final DateTime? createdAt;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.itemId,
    required this.quantity,
    required this.originalUnitPrice,
    required this.discountPercentSnapshot,
    required this.unitPrice,
    required this.lineTotal,
    required this.titleSnapshot,
    this.selectedColorId,
    this.selectedColorName,
    this.selectedColorHex,
    this.selectedSizeId,
    this.selectedSizeName,
    this.createdAt,
  });

  String get formattedSelection {
    final List<String> parts = <String>[];
    if ((selectedColorName ?? '').trim().isNotEmpty) {
      parts.add('اللون: ${selectedColorName!.trim()}');
    }
    if ((selectedSizeName ?? '').trim().isNotEmpty) {
      parts.add('الحجم: ${selectedSizeName!.trim()}');
    }
    return parts.join(' | ');
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int? ?? 0,
      orderId: json['order_id'] as int? ?? 0,
      itemId: json['item_id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      originalUnitPrice:
          (json['original_unit_price'] as num?)?.toDouble() ??
          (json['unit_price'] as num?)?.toDouble() ??
          0,
      discountPercentSnapshot:
          (json['discount_percent_snapshot'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
      titleSnapshot: (json['title_snapshot'] ?? '').toString(),
      selectedColorId: (json['selected_color_id'] as num?)?.toInt(),
      selectedColorName: json['selected_color_name']?.toString(),
      selectedColorHex: json['selected_color_hex']?.toString(),
      selectedSizeId: (json['selected_size_id'] as num?)?.toInt(),
      selectedSizeName: json['selected_size_name']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}
