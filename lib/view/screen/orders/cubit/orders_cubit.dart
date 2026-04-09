import 'dart:async';

import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:alkhafajdashboard/utils/order_distance_helper.dart';
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
      final List<dynamic> locationRows = await _repository.fetchLocations();
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

  List<OrderModel> get visibleOrders {
    Iterable<OrderModel> scoped = orders;

    if (!isAdmin) {
      final int userLocationId = currentUser?.locationId ?? 0;
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
          (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
            a.createdAt ?? DateTime(1970),
          ),
        );
        break;
      case OrdersSortMode.oldest:
        result.sort(
          (a, b) => (a.createdAt ?? DateTime(1970)).compareTo(
            b.createdAt ?? DateTime(1970),
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
          return (a.createdAt ?? DateTime(1970)).compareTo(
            b.createdAt ?? DateTime(1970),
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
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(OrdersSuccess('تم تحويل الطلب إلى ${location.name}'));
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
      await _repository.updateOrderStatus(
        orderId: order.id,
        status: status,
        changedBy: currentUser!.userId,
        notes: notes,
        locationId: locationId,
      );
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(OrdersSuccess('تم تحديث حالة الطلب بنجاح'));
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
      for (final order in targets) {
        await _repository.assignOrderToLocation(
          orderId: order.id,
          locationId: location.id,
          changedBy: currentUser!.userId,
          notes: notes,
        );
      }
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(
        OrdersSuccess('تم تحويل ${targets.length} طلب إلى ${location.name}'),
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
      for (final order in targets) {
        await _repository.updateOrderStatus(
          orderId: order.id,
          status: status,
          changedBy: currentUser!.userId,
          notes: notes,
          locationId: currentUser?.locationId,
        );
      }
      await _refreshData(withLoading: false, showSuccessMessage: false);
      _safeEmit(OrdersSuccess('تم تحديث ${targets.length} طلب'));
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
