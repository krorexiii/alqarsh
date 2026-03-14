import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_item_model.dart';
import 'package:alkhafajdashboard/data/model/orders/order_status_history_model.dart';

class OrderModel {
  final int id;
  final String shopId;
  final int customerId;
  final String status;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double customerLat;
  final double customerLng;
  final String customerName;
  final String customerPhone;
  final int? assignedLocationId;
  final String? assignedLocationName;
  final List<OrderItemModel> items;
  final List<OrderStatusHistoryModel> history;

  const OrderModel({
    required this.id,
    required this.shopId,
    required this.customerId,
    required this.status,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.customerLat,
    required this.customerLng,
    required this.customerName,
    required this.customerPhone,
    required this.assignedLocationId,
    required this.assignedLocationName,
    required this.items,
    required this.history,
  });

  bool get isAssigned => assignedLocationId != null;

  bool get canBePrepared =>
      status == 'confirmed' || status == 'preparing' || status == 'shipped';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['order_items'] as List<dynamic>? ?? [];
    final List<dynamic> historyJson =
        json['order_status_history'] as List<dynamic>? ?? [];
    final Map<String, dynamic>? customerJson =
        json['customers'] as Map<String, dynamic>?;
    final Map<String, dynamic>? assignedLocationJson =
        json['assigned_location'] as Map<String, dynamic>?;
    final List<OrderStatusHistoryModel> parsedHistory = historyJson
        .whereType<Map<String, dynamic>>()
        .map(OrderStatusHistoryModel.fromJson)
        .toList();

    return OrderModel(
      id: json['id'] as int? ?? 0,
      shopId: (json['shop_id'] ?? '').toString(),
      customerId: json['customer_id'] as int? ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      note: json['note']?.toString(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
      customerLat:
          (customerJson?['l_x'] as num?)?.toDouble() ??
          (json['customer_lat'] as num?)?.toDouble() ??
          0,
      customerLng:
          (customerJson?['l_y'] as num?)?.toDouble() ??
          (json['customer_lng'] as num?)?.toDouble() ??
          0,
      customerName: (customerJson?['name'] ?? json['customer_name'] ?? 'عميل')
          .toString(),
      customerPhone: (customerJson?['phone'] ?? json['customer_phone'] ?? '')
          .toString(),
      assignedLocationId:
          json['assigned_location_id'] as int? ??
          assignedLocationJson?['id'] as int?,
      assignedLocationName:
          assignedLocationJson?['name']?.toString() ??
          json['assigned_location_name']?.toString(),
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromJson)
          .toList(),
      history: parsedHistory,
    );
  }

  OrderModel copyWith({
    String? status,
    int? assignedLocationId,
    String? assignedLocationName,
    List<OrderStatusHistoryModel>? history,
  }) {
    return OrderModel(
      id: id,
      shopId: shopId,
      customerId: customerId,
      status: status ?? this.status,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
      customerLat: customerLat,
      customerLng: customerLng,
      customerName: customerName,
      customerPhone: customerPhone,
      assignedLocationId: assignedLocationId ?? this.assignedLocationId,
      assignedLocationName: assignedLocationName ?? this.assignedLocationName,
      items: items,
      history: history ?? this.history,
    );
  }
}

class SuggestedLocation {
  final LocationModel location;
  final double distance;

  const SuggestedLocation({required this.location, required this.distance});
}
