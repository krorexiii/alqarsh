import 'package:alkhafajdashboard/data/model/orders/order_model.dart';

String orderDeliveryTypeLabel(OrderModel order) {
  return order.isFutureDelivery ? 'طلب مستقبلي' : 'طلب حالي';
}

String formatOrderDate(DateTime? date) {
  if (date == null) {
    return '-';
  }

  final String year = date.year.toString().padLeft(4, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '$year/$month/$day';
}

String futureOrderBadgeText(OrderModel order) {
  final String date = formatOrderDate(order.scheduledDeliveryDate);
  return date == '-' ? 'طلب مستقبلي' : 'مستقبلي $date';
}
