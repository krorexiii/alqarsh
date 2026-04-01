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
  int customerCount = 0;

  Future<void> initialize() async {
    emit(NotificationsLoading());
    try {
      notifications = await _repository.fetchNotifications();
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
  }) async {
    emit(NotificationsSending());
    try {
      await _repository.sendBroadcastNotification(
        title: title,
        body: body,
        type: type,
      );
      await initialize();
      emit(NotificationsSuccess(
        'تم إرسال الإشعار بنجاح إلى $customerCount عميل',
      ));
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
