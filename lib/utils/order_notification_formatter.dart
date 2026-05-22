import 'package:alkhafajdashboard/data/model/orders/order_model.dart';

class OrderNotificationContent {
  const OrderNotificationContent({
    required this.title,
    required this.body,
    required this.payload,
  });

  final String title;
  final String body;
  final Map<String, dynamic> payload;
}

OrderNotificationContent buildOrderNotificationContent({
  required OrderModel order,
  required String status,
}) {
  final String orderNumber = '#${order.id}';
  final String normalizedStatus = status.trim().toLowerCase();

  switch (normalizedStatus) {
    case 'confirmed':
      return OrderNotificationContent(
        title: 'تم تأكيد طلبك $orderNumber',
        body: 'استلمنا طلبك وبدأنا ترتيبه للخطوات التالية.',
        payload: <String, dynamic>{
          'order_id': order.id,
          'order_status': 'confirmed',
          'screen': 'order_details',
        },
      );
    case 'preparing':
      return OrderNotificationContent(
        title: 'طلبك $orderNumber قيد التجهيز',
        body: 'نعمل الآن على تجهيز طلبك، وسنخبرك فور خروجه للتوصيل.',
        payload: <String, dynamic>{
          'order_id': order.id,
          'order_status': 'preparing',
          'screen': 'order_details',
        },
      );
    case 'shipped':
      return OrderNotificationContent(
        title: 'طلبك $orderNumber خرج للتوصيل',
        body: 'الطلب في الطريق إليك الآن. تابع حالة الطلب من داخل التطبيق.',
        payload: <String, dynamic>{
          'order_id': order.id,
          'order_status': 'shipped',
          'screen': 'order_details',
        },
      );
    case 'delivered':
      return OrderNotificationContent(
        title: 'تم تسليم طلبك $orderNumber',
        body: 'اكتمل الطلب بنجاح. شكرًا لاختيارك متجرنا.',
        payload: <String, dynamic>{
          'order_id': order.id,
          'order_status': 'delivered',
          'screen': 'order_details',
        },
      );
    case 'cancelled':
      return OrderNotificationContent(
        title: 'تم إلغاء طلبك $orderNumber',
        body:
            'تم تحديث حالة الطلب إلى ملغي. يمكنك التواصل معنا إذا احتجت أي مساعدة.',
        payload: <String, dynamic>{
          'order_id': order.id,
          'order_status': 'cancelled',
          'screen': 'order_details',
        },
      );
    default:
      return OrderNotificationContent(
        title: 'تحديث على طلبك $orderNumber',
        body: 'تم تحديث حالة الطلب. افتح التطبيق للاطلاع على التفاصيل.',
        payload: <String, dynamic>{
          'order_id': order.id,
          'order_status': normalizedStatus,
          'screen': 'order_details',
        },
      );
  }
}
