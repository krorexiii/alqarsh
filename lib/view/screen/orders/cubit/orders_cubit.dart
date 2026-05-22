import 'dart:async';

import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:alkhafajdashboard/utils/order_distance_helper.dart';
import 'package:alkhafajdashboard/utils/order_notification_formatter.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'orders_state.dart';

enum OrdersFilterStatus {
  all,
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
  discounted,
}

enum OrdersSortMode { newest, oldest, highestTotal, oldestPendingFirst }

enum OrdersDeliveryTypeFilter { all, current, future }

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({Repository? repository})
    : _repository = repository ?? Repository(),
      super(OrdersInitial());

  final Repository _repository;

  List<OrderModel> orders = <OrderModel>[];
  List<LocationModel> locations = <LocationModel>[];
  SessionUserModel? currentUser;

  OrdersFilterStatus selectedFilter = OrdersFilterStatus.all;
  OrdersSortMode selectedSortMode = OrdersSortMode.newest;
  OrdersDeliveryTypeFilter selectedDeliveryTypeFilter =
      OrdersDeliveryTypeFilter.all;
  String searchQuery = '';

  final Set<int> selectedOrderIds = <int>{};
  Timer? _autoRefreshTimer;

  void _safeEmit(OrdersState state) {
    if (isClosed) {
      return;
    }
    emit(state);
  }

  Future<void> initialize() async {
    await _refreshData(withLoading: true, showSuccessMessage: false);
    _ensureAutoRefresh();
  }

  Future<void> refreshSilently() async {
    await _refreshData(withLoading: false, showSuccessMessage: false);
  }

  Future<void> _refreshData({
    required bool withLoading,
    required bool showSuccessMessage,
  }) async {
    if (isClosed) {
      return;
    }

    if (withLoading) {
      _safeEmit(OrdersLoading());
    }

    try {
      currentUser = await _repository.fetchCurrentSessionUser();
      if (isClosed) {
        return;
      }
      final List<dynamic> locationRows = await _repository
          .fetchStoreLocations();
      if (isClosed) {
        return;
      }
      locations = locationRows
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
      orders = await _repository.fetchOrders();
      if (isClosed) {
        return;
      }

      _pruneSelectionToVisibleOrders();

      if (showSuccessMessage) {
        _safeEmit(OrdersSuccess('تم تحديث الطلبات'));
      }
      _safeEmit(OrdersLoaded());
    } catch (e) {
      _safeEmit(OrdersError('فشل في جلب الطلبات: ${e.toString()}'));
    }
  }

  bool get isAdmin => currentUser?.isAdmin ?? false;

  bool get hasSelection => selectedOrderIds.isNotEmpty;
  int get selectedCount => selectedOrderIds.length;

  void _ensureAutoRefresh() {
    _autoRefreshTimer ??= Timer.periodic(const Duration(seconds: 20), (_) {
      if (isClosed) {
        return;
      }
      refreshSilently();
    });
  }

  void _pruneSelectionToVisibleOrders() {
    final Set<int> visibleIds = visibleOrders.map((order) => order.id).toSet();
    selectedOrderIds.removeWhere((id) => !visibleIds.contains(id));
  }

  void setFilter(OrdersFilterStatus filter) {
    selectedFilter = filter;
    _pruneSelectionToVisibleOrders();
    _safeEmit(OrdersLoaded());
  }

  void setSearchQuery(String value) {
    searchQuery = value.trim();
    _pruneSelectionToVisibleOrders();
    _safeEmit(OrdersLoaded());
  }

  void setSortMode(OrdersSortMode mode) {
    selectedSortMode = mode;
    _safeEmit(OrdersLoaded());
  }

  void setDeliveryTypeFilter(OrdersDeliveryTypeFilter filter) {
    selectedDeliveryTypeFilter = filter;
    _pruneSelectionToVisibleOrders();
    _safeEmit(OrdersLoaded());
  }

  bool isOrderSelected(OrderModel order) => selectedOrderIds.contains(order.id);

  void toggleOrderSelection(OrderModel order) {
    if (selectedOrderIds.contains(order.id)) {
      selectedOrderIds.remove(order.id);
    } else {
      selectedOrderIds.add(order.id);
    }
    _safeEmit(OrdersLoaded());
  }

  void selectAllVisibleOrders() {
    selectedOrderIds
      ..clear()
      ..addAll(visibleOrders.map((order) => order.id));
    _safeEmit(OrdersLoaded());
  }

  void clearSelection() {
    if (selectedOrderIds.isEmpty) {
      return;
    }
    selectedOrderIds.clear();
    _safeEmit(OrdersLoaded());
  }

  List<OrderModel> get selectedOrders => visibleOrders
      .where((order) => selectedOrderIds.contains(order.id))
      .toList();

  List<String> getAllowedNextStatuses(OrderModel order) {
    switch (order.status) {
      case 'pending':
        return <String>['confirmed', 'cancelled'];
      case 'confirmed':
        return <String>['preparing', 'cancelled'];
      case 'preparing':
        return <String>['shipped', 'cancelled'];
      case 'shipped':
        return <String>['delivered'];
      default:
        return <String>[];
    }
  }

  bool canTransitionTo(OrderModel order, String nextStatus) {
    return getAllowedNextStatuses(order).contains(nextStatus);
  }

  int? _resolveLocationIdForStatusChange({
    required OrderModel order,
    required String nextStatus,
    int? requestedLocationId,
  }) {
    if (nextStatus == 'pending' || nextStatus == 'cancelled') {
      return null;
    }

    if (requestedLocationId != null && requestedLocationId > 0) {
      return requestedLocationId;
    }

    if (order.assignedLocationId != null && order.assignedLocationId! > 0) {
      return order.assignedLocationId;
    }

    return null;
  }

  Future<bool> _sendOrderStatusNotification({
    required OrderModel order,
    required String status,
  }) async {
    final OrderNotificationContent content = buildOrderNotificationContent(
      order: order,
      status: status,
    );

    try {
      await _repository.sendNotificationToCustomer(
        customerId: order.customerId,
        title: content.title,
        body: content.body,
        type: 'order_status',
        orderId: order.id,
        orderStatus: status,
        payload: content.payload,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  List<OrderModel> get visibleOrders {
    Iterable<OrderModel> scoped = orders;

    if (!isAdmin) {
      final int? userLocationId = currentUser?.locationId;
      if (userLocationId == null || userLocationId <= 0) {
        return <OrderModel>[];
      }
      scoped = scoped.where(
        (order) => order.assignedLocationId == userLocationId,
      );
    }

    if (selectedFilter != OrdersFilterStatus.all) {
      if (selectedFilter == OrdersFilterStatus.discounted) {
        scoped = scoped.where((order) => order.hasAnyDiscount);
      } else {
        final String filterStatus = selectedFilter.name;
        scoped = scoped.where((order) => order.status == filterStatus);
      }
    }

    if (selectedDeliveryTypeFilter != OrdersDeliveryTypeFilter.all) {
      scoped = scoped.where((order) {
        return selectedDeliveryTypeFilter == OrdersDeliveryTypeFilter.future
            ? order.isFutureDelivery
            : !order.isFutureDelivery;
      });
    }

    if (searchQuery.isNotEmpty) {
      final String q = searchQuery.toLowerCase();
      scoped = scoped.where((order) {
        return order.id.toString().contains(q) ||
            order.customerName.toLowerCase().contains(q) ||
            order.customerPhone.toLowerCase().contains(q);
      });
    }

    final List<OrderModel> result = scoped.toList();

    switch (selectedSortMode) {
      case OrdersSortMode.newest:
        result.sort(
          (a, b) => (b.orderingDate ?? DateTime(1970)).compareTo(
            a.orderingDate ?? DateTime(1970),
          ),
        );
        break;
      case OrdersSortMode.oldest:
        result.sort(
          (a, b) => (a.orderingDate ?? DateTime(1970)).compareTo(
            b.orderingDate ?? DateTime(1970),
          ),
        );
        break;
      case OrdersSortMode.highestTotal:
        result.sort((a, b) => b.total.compareTo(a.total));
        break;
      case OrdersSortMode.oldestPendingFirst:
        result.sort((a, b) {
          final bool aPending = a.status == 'pending';
          final bool bPending = b.status == 'pending';
          if (aPending != bPending) {
            return aPending ? -1 : 1;
          }
          return (a.orderingDate ?? DateTime(1970)).compareTo(
            b.orderingDate ?? DateTime(1970),
          );
        });
        break;
    }

    return result;
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
      _safeEmit(OrdersError('لم يتم التعرف على المستخدم الحالي'));
      return;
    }

    if (!canTransitionTo(order, 'confirmed')) {
      _safeEmit(OrdersError('لا يمكن تحويل الطلب في حالته الحالية'));
      return;
    }

    _safeEmit(OrdersSaving());
    try {
      await _repository.assignOrderToLocation(
        orderId: order.id,
        locationId: location.id,
        changedBy: currentUser!.userId,
        notes: notes,
      );
      final bool notificationSent = await _sendOrderStatusNotification(
        order: order,
        status: 'confirmed',
      );
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(
        OrdersSuccess(
          notificationSent
              ? 'تم تحويل الطلب إلى ${location.name}'
              : 'تم تحويل الطلب إلى ${location.name} لكن تعذر إرسال إشعار العميل',
        ),
      );
    } catch (e) {
      _safeEmit(OrdersError('تعذر تحويل الطلب إلى الموقع المحدد'));
    }
  }

  Future<void> changeOrderStatus({
    required OrderModel order,
    required String status,
    String? notes,
    int? locationId,
  }) async {
    if (currentUser == null) {
      _safeEmit(OrdersError('لم يتم التعرف على المستخدم الحالي'));
      return;
    }

    if (!canTransitionTo(order, status)) {
      _safeEmit(
        OrdersError('الانتقال من ${order.status} إلى $status غير مسموح'),
      );
      return;
    }

    _safeEmit(OrdersSaving());
    try {
      final int? resolvedLocationId = _resolveLocationIdForStatusChange(
        order: order,
        nextStatus: status,
        requestedLocationId: locationId,
      );

      await _repository.updateOrderStatus(
        orderId: order.id,
        status: status,
        changedBy: currentUser!.userId,
        notes: notes,
        locationId: resolvedLocationId,
      );
      final bool notificationSent = await _sendOrderStatusNotification(
        order: order,
        status: status,
      );
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(
        OrdersSuccess(
          notificationSent
              ? 'تم تحديث حالة الطلب بنجاح'
              : 'تم تحديث حالة الطلب لكن تعذر إرسال إشعار العميل',
        ),
      );
    } catch (e) {
      _safeEmit(OrdersError('تعذر تحديث حالة الطلب'));
    }
  }

  Future<void> bulkAssignOrders({
    required LocationModel location,
    String? notes,
  }) async {
    if (!hasSelection) {
      _safeEmit(OrdersError('اختر طلبات أولاً'));
      return;
    }

    final List<OrderModel> targets = selectedOrders
        .where((order) => canTransitionTo(order, 'confirmed'))
        .toList();

    if (targets.isEmpty) {
      _safeEmit(OrdersError('لا توجد طلبات قابلة للتحويل في الاختيار الحالي'));
      return;
    }

    _safeEmit(OrdersSaving());
    try {
      int notificationFailures = 0;
      for (final order in targets) {
        await _repository.assignOrderToLocation(
          orderId: order.id,
          locationId: location.id,
          changedBy: currentUser!.userId,
          notes: notes,
        );
        final bool notificationSent = await _sendOrderStatusNotification(
          order: order,
          status: 'confirmed',
        );
        if (!notificationSent) {
          notificationFailures++;
        }
      }
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(
        OrdersSuccess(
          notificationFailures == 0
              ? 'تم تحويل ${targets.length} طلب إلى ${location.name}'
              : 'تم تحويل ${targets.length} طلب إلى ${location.name} مع فشل $notificationFailures إشعار',
        ),
      );
    } catch (_) {
      _safeEmit(OrdersError('فشل التحويل الجماعي للطلبات'));
    }
  }

  Future<void> bulkChangeStatus({required String status, String? notes}) async {
    if (!hasSelection) {
      _safeEmit(OrdersError('اختر طلبات أولاً'));
      return;
    }

    final List<OrderModel> targets = selectedOrders
        .where((order) => canTransitionTo(order, status))
        .toList();

    if (targets.isEmpty) {
      _safeEmit(OrdersError('لا توجد طلبات تدعم هذا الانتقال'));
      return;
    }

    _safeEmit(OrdersSaving());
    try {
      int notificationFailures = 0;
      for (final order in targets) {
        final int? resolvedLocationId = _resolveLocationIdForStatusChange(
          order: order,
          nextStatus: status,
          requestedLocationId: currentUser?.locationId,
        );

        await _repository.updateOrderStatus(
          orderId: order.id,
          status: status,
          changedBy: currentUser!.userId,
          notes: notes,
          locationId: resolvedLocationId,
        );
        final bool notificationSent = await _sendOrderStatusNotification(
          order: order,
          status: status,
        );
        if (!notificationSent) {
          notificationFailures++;
        }
      }
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(
        OrdersSuccess(
          notificationFailures == 0
              ? 'تم تحديث ${targets.length} طلب'
              : 'تم تحديث ${targets.length} طلب مع فشل $notificationFailures إشعار',
        ),
      );
    } catch (_) {
      _safeEmit(OrdersError('فشل التحديث الجماعي للحالات'));
    }
  }

  @override
  Future<void> close() {
    _autoRefreshTimer?.cancel();
    return super.close();
  }
}
