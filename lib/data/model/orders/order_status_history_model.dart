class OrderStatusHistoryModel {
  final int id;
  final int orderId;
  final String status;
  final String? changedBy;
  final String? notes;
  final DateTime? createdAt;
  final int? locationId;

  const OrderStatusHistoryModel({
    required this.id,
    required this.orderId,
    required this.status,
    this.changedBy,
    this.notes,
    this.createdAt,
    this.locationId,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      id: json['id'] as int? ?? 0,
      orderId: json['order_id'] as int? ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      changedBy: json['changed_by']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      locationId: json['location_id'] as int?,
    );
  }
}
