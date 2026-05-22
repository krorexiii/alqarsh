import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({Repository? repository})
    : _repository = repository ?? Repository(),
      super(NotificationsInitial());

  final Repository _repository;

  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> customers = [];
  int customerCount = 0;

  Future<void> initialize() async {
    emit(NotificationsLoading());
    try {
      notifications = await _repository.fetchNotifications();
      customers = await _repository.fetchNotificationCustomers();
      customerCount = await _repository.fetchCustomerCount();
      emit(NotificationsLoaded());
    } catch (e) {
      emit(NotificationsError('فشل في جلب الإشعارات: ${e.toString()}'));
    }
  }

  Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    emit(NotificationsSending());
    try {
      await _repository.sendBroadcastNotification(
        title: title,
        body: body,
        type: type,
        payload: payload,
      );
      await initialize();
      emit(NotificationsSuccess('تم إرسال الإشعار العام عبر الـ Topic بنجاح'));
    } catch (e) {
      emit(NotificationsError('فشل في إرسال الإشعار: ${e.toString()}'));
    }
  }

  Future<void> sendNotificationToCustomer({
    required int customerId,
    required String title,
    required String body,
    required String type,
    int? orderId,
    String? orderStatus,
    Map<String, dynamic>? payload,
  }) async {
    emit(NotificationsSending());
    try {
      await _repository.sendNotificationToCustomer(
        customerId: customerId,
        title: title,
        body: body,
        type: type,
        orderId: orderId,
        orderStatus: orderStatus,
        payload: payload,
      );
      await initialize();
      Map<String, dynamic>? customer;
      for (final Map<String, dynamic> row in customers) {
        if (row['id'] == customerId) {
          customer = row;
          break;
        }
      }
      final String customerName = (customer?['name'] ?? 'العميل المحدد')
          .toString();
      emit(NotificationsSuccess('تم إرسال الإشعار الفردي إلى $customerName'));
    } catch (e) {
      emit(NotificationsError('فشل في إرسال الإشعار: ${e.toString()}'));
    }
  }

  Future<void> deleteNotification({required int notificationId}) async {
    emit(NotificationsSending());
    try {
      await _repository.deleteNotification(notificationId: notificationId);
      await initialize();
      emit(NotificationsSuccess('تم حذف الإشعار بنجاح'));
    } catch (e) {
      emit(NotificationsError('فشل في حذف الإشعار'));
    }
  }
}
