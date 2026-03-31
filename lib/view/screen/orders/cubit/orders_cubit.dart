import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:alkhafajdashboard/utils/order_distance_helper.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({Repository? repository})
    : _repository = repository ?? Repository(),
      super(OrdersInitial());

  final Repository _repository;

  List<OrderModel> orders = <OrderModel>[];
  List<LocationModel> locations = <LocationModel>[];
  SessionUserModel? currentUser;

  Future<void> initialize() async {
    emit(OrdersLoading());
    try {
      currentUser = await _repository.fetchCurrentSessionUser();
      final List<dynamic> locationRows = await _repository.fetchLocations();
      locations = locationRows
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
      orders = await _repository.fetchOrders();
      emit(OrdersLoaded());
    } catch (e) {
      emit(OrdersError('فشل في جلب الطلبات: ${e.toString()}'));
    }
  }

  bool get isAdmin => currentUser?.isAdmin ?? false;

  List<OrderModel> get visibleOrders {
    return orders;
  }

  SuggestedLocation? getSuggestedLocation(OrderModel order) {
    if (locations.isEmpty) {
      return null;
    }

    LocationModel? bestLocation;
    double? bestDistance;

    for (final location in locations) {
      final double distance = calculateDistanceKm(
        order.customerLat,
        order.customerLng,
        location.lX,
        location.lY,
      );

      if (bestDistance == null || distance < bestDistance) {
        bestDistance = distance;
        bestLocation = location;
      }
    }

    if (bestLocation == null || bestDistance == null) {
      return null;
    }

    return SuggestedLocation(location: bestLocation, distance: bestDistance);
  }

  Future<void> assignOrder({
    required OrderModel order,
    required LocationModel location,
    String? notes,
  }) async {
    if (currentUser == null) {
      emit(OrdersError('لم يتم التعرف على المستخدم الحالي'));
      return;
    }

    emit(OrdersSaving());
    try {
      await _repository.assignOrderToLocation(
        orderId: order.id,
        locationId: location.id,
        changedBy: currentUser!.userId,
        notes: notes,
      );
      await initialize();
      emit(OrdersSuccess('تم تحويل الطلب إلى ${location.name}'));
    } catch (e) {
      emit(OrdersError('تعذر تحويل الطلب إلى الموقع المحدد'));
    }
  }

  Future<void> changeOrderStatus({
    required OrderModel order,
    required String status,
    String? notes,
    int? locationId,
  }) async {
    if (currentUser == null) {
      emit(OrdersError('لم يتم التعرف على المستخدم الحالي'));
      return;
    }

    emit(OrdersSaving());
    try {
      await _repository.updateOrderStatus(
        orderId: order.id,
        status: status,
        changedBy: currentUser!.userId,
        notes: notes,
        locationId: locationId,
      );
      await initialize();
      emit(OrdersSuccess('تم تحديث حالة الطلب بنجاح'));
    } catch (e) {
      emit(OrdersError('تعذر تحديث حالة الطلب'));
    }
  }
}
