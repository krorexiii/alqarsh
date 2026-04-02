import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/view/screen/orders/cubit/orders_cubit.dart';
import 'package:alkhafajdashboard/view/screen/orders/preparation/orderPreparationScreen.dart';
import 'package:alkhafajdashboard/view/screen/orders/widget/order_details_dialog.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit()..initialize(),
      child: Scaffold(
        drawer: const DashboardDrawer(currentRoute: 'orders'),
        backgroundColor: const Color(0xfff6f7fb),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder:
                    (context) => const MyAppbar(
                      title: 'إدارة الطلبات',
                      isBack: false,
                      actions: [],
                    ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocConsumer<OrdersCubit, OrdersState>(
                  listener: (context, state) {
                    if (state is OrdersError || state is OrdersSuccess) {
                      final String message =
                          state is OrdersError
                              ? state.message
                              : (state as OrdersSuccess).message;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    }
                  },
                  builder: (context, state) {
                    final OrdersCubit cubit = context.read<OrdersCubit>();
                    if (state is OrdersLoading && cubit.orders.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final List<OrderModel> orders = cubit.visibleOrders;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _OrdersHeader(cubit: cubit, totalOrders: orders.length),
                        const SizedBox(height: 12),
                        Expanded(
                          child:
                              orders.isEmpty
                                  ? const _EmptyOrdersView()
                                  : ListView.separated(
                                    itemCount: orders.length,
                                    separatorBuilder:
                                        (_, _) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final OrderModel order = orders[index];
                                      return _OrderCard(
                                        order: order,
                                        cubit: cubit,
                                      );
                                    },
                                  ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.cubit, required this.totalOrders});

  final OrdersCubit cubit;
  final int totalOrders;

  Future<String?> _askRequiredReason(BuildContext context, String title) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب سبب الإجراء',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final String value = controller.text.trim();
                  if (value.isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop(value);
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
    );
  }

  Future<void> _bulkAssign(BuildContext context) async {
    if (cubit.locations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مواقع متاحة للتحويل')),
      );
      return;
    }

    int selectedLocationId = cubit.locations.first.id;

    final int? locationId = await showDialog<int>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تحويل جماعي للموقع'),
            content: StatefulBuilder(
              builder:
                  (context, setState) => DropdownButtonFormField<int>(
                    value: selectedLocationId,
                    items:
                        cubit.locations
                            .map(
                              (location) => DropdownMenuItem<int>(
                                value: location.id,
                                child: Text(location.name),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        selectedLocationId = value;
                      });
                    },
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(selectedLocationId),
                child: const Text('التالي'),
              ),
            ],
          ),
    );

    if (locationId == null) {
      return;
    }

    final LocationModel location = cubit.locations.firstWhere(
      (location) => location.id == locationId,
    );

    final String? reason = await _askRequiredReason(
      context,
      'سبب التحويل الجماعي',
    );

    if (reason == null) {
      return;
    }

    await cubit.bulkAssignOrders(location: location, notes: reason);
  }

  Future<void> _bulkCancel(BuildContext context) async {
    final String? reason = await _askRequiredReason(
      context,
      'سبب الإلغاء الجماعي',
    );

    if (reason == null) {
      return;
    }

    await cubit.bulkChangeStatus(status: 'cancelled', notes: reason);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'لوحة متابعة الطلبات',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cubit.isAdmin
                          ? 'فلترة وبحث وتحويل جماعي مع تحديث تلقائي كل 20 ثانية.'
                          : 'عرض طلبات موقعك فقط مع تتبع التنفيذ وتحديث تلقائي.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffeef2ff),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'عدد الطلبات',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalOrders',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: cubit.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'بحث برقم الطلب أو اسم العميل أو الهاتف',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.grey.shade50,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<OrdersSortMode>(
                value: cubit.selectedSortMode,
                items: const [
                  DropdownMenuItem(
                    value: OrdersSortMode.newest,
                    child: Text('الأحدث'),
                  ),
                  DropdownMenuItem(
                    value: OrdersSortMode.oldest,
                    child: Text('الأقدم'),
                  ),
                  DropdownMenuItem(
                    value: OrdersSortMode.highestTotal,
                    child: Text('الأعلى إجمالي'),
                  ),
                  DropdownMenuItem(
                    value: OrdersSortMode.oldestPendingFirst,
                    child: Text('المعلقة أولاً'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    cubit.setSortMode(value);
                  }
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'تحديث الآن',
                onPressed: cubit.refreshSilently,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'الكل',
                selected: cubit.selectedFilter == OrdersFilterStatus.all,
                onTap: () => cubit.setFilter(OrdersFilterStatus.all),
              ),
              _FilterChip(
                label: 'جديد',
                selected: cubit.selectedFilter == OrdersFilterStatus.pending,
                onTap: () => cubit.setFilter(OrdersFilterStatus.pending),
              ),
              _FilterChip(
                label: 'مؤكد',
                selected: cubit.selectedFilter == OrdersFilterStatus.confirmed,
                onTap: () => cubit.setFilter(OrdersFilterStatus.confirmed),
              ),
              _FilterChip(
                label: 'قيد التحضير',
                selected: cubit.selectedFilter == OrdersFilterStatus.preparing,
                onTap: () => cubit.setFilter(OrdersFilterStatus.preparing),
              ),
              _FilterChip(
                label: 'بالشحن',
                selected: cubit.selectedFilter == OrdersFilterStatus.shipped,
                onTap: () => cubit.setFilter(OrdersFilterStatus.shipped),
              ),
              _FilterChip(
                label: 'مكتمل',
                selected: cubit.selectedFilter == OrdersFilterStatus.delivered,
                onTap: () => cubit.setFilter(OrdersFilterStatus.delivered),
              ),
              _FilterChip(
                label: 'ملغي',
                selected: cubit.selectedFilter == OrdersFilterStatus.cancelled,
                onTap: () => cubit.setFilter(OrdersFilterStatus.cancelled),
              ),
              _FilterChip(
                label: 'طلبات مخفضة',
                selected: cubit.selectedFilter == OrdersFilterStatus.discounted,
                onTap: () => cubit.setFilter(OrdersFilterStatus.discounted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: cubit.selectAllVisibleOrders,
                  icon: const Icon(Icons.select_all),
                  label: const Text('تحديد الكل'),
                ),
                OutlinedButton.icon(
                  onPressed: cubit.clearSelection,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('إلغاء التحديد'),
                ),
                if (cubit.isAdmin)
                  FilledButton.tonalIcon(
                    onPressed:
                        cubit.hasSelection ? () => _bulkAssign(context) : null,
                    icon: const Icon(Icons.alt_route),
                    label: Text('تحويل جماعي (${cubit.selectedCount})'),
                  ),
                FilledButton.tonalIcon(
                  onPressed:
                      cubit.hasSelection ? () => _bulkCancel(context) : null,
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text('إلغاء جماعي (${cubit.selectedCount})'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.cubit});

  final OrderModel order;
  final OrdersCubit cubit;

  Future<String?> _askRequiredReason(BuildContext context, String title) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب السبب',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () {
                  final String value = controller.text.trim();
                  if (value.isEmpty) {
                    return;
                  }
                  Navigator.of(context).pop(value);
                },
                child: const Text('تأكيد'),
              ),
            ],
          ),
    );
  }

  Future<void> _assignToLocation(
    BuildContext context,
    LocationModel location,
    SuggestedLocation? suggestion,
  ) async {
    final String? reason = await _askRequiredReason(
      context,
      location.id == suggestion?.location.id
          ? 'سبب التحويل المقترح'
          : 'سبب التحويل اليدوي',
    );

    if (reason == null) {
      return;
    }

    await cubit.assignOrder(order: order, location: location, notes: reason);
  }

  Future<void> _cancelOrder(BuildContext context) async {
    final String? reason = await _askRequiredReason(context, 'سبب إلغاء الطلب');
    if (reason == null) {
      return;
    }

    await cubit.changeOrderStatus(
      order: order,
      status: 'cancelled',
      notes: reason,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SuggestedLocation? suggestion = cubit.getSuggestedLocation(order);
    final List<LocationModel> selectableLocations = cubit.locations;
    final bool isAdmin = cubit.isAdmin;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: order.isLate ? Colors.red.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: cubit.isOrderSelected(order),
                onChanged: (_) => cubit.toggleOrderSelection(order),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الطلب #${order.id} - ${order.customerName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ChipLabel(
                          label: 'الحالة: ${_statusLabel(order.status)}',
                        ),
                        _ChipLabel(
                          label:
                              'الموقع الحالي: ${order.assignedLocationName ?? 'غير محدد'}',
                        ),
                        _ChipLabel(
                          label: 'الإجمالي: ${order.total.toStringAsFixed(2)}',
                        ),
                        _ChipLabel(label: 'العناصر: ${order.totalItemsCount}'),
                        _ChipLabel(label: 'الكمية: ${order.totalQuantity}'),
                        if (order.discountedItemsCount > 0)
                          _ChipLabel(
                            label:
                                'مخفضة: ${order.discountedItemsCount}/${order.totalItemsCount}',
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _OrderStatusTimeline(status: order.status),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  if (isAdmin) {
                    await showDialog<void>(
                      context: context,
                      builder: (_) => OrderDetailsDialog(order: order),
                    );
                    return;
                  }

                  final bool? updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider.value(
                            value: cubit,
                            child: OrderPreparationScreen(order: order),
                          ),
                    ),
                  );

                  if (updated == true && context.mounted) {
                    await context.read<OrdersCubit>().refreshSilently();
                  }
                },
                icon: Icon(
                  isAdmin
                      ? Icons.visibility_outlined
                      : Icons.fact_check_outlined,
                ),
                label: Text(isAdmin ? 'التفاصيل' : 'فتح صفحة التجهيز'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              order.isLate
                  ? 'متأخر منذ ${order.waitingDuration.inMinutes} دقيقة'
                  : 'زمن الانتظار: ${order.waitingDuration.inMinutes} دقيقة',
              style: TextStyle(
                color: order.isLate ? Colors.red.shade700 : Colors.indigo,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              suggestion == null
                  ? 'لا يوجد اقتراح موقع حالياً'
                  : 'أقرب موقع مقترح: ${suggestion.location.name} (${suggestion.distance.toStringAsFixed(2)} كم)',
              style: TextStyle(
                color:
                    suggestion == null ? Colors.grey.shade600 : Colors.indigo,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (isAdmin)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...selectableLocations.map(
                  (location) => OutlinedButton.icon(
                    onPressed:
                        stateBusy(context) ||
                                !cubit.canTransitionTo(order, 'confirmed')
                            ? null
                            : () => _assignToLocation(
                              context,
                              location,
                              suggestion,
                            ),
                    icon: const Icon(Icons.alt_route),
                    label: Text('تحويل إلى ${location.name}'),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed:
                      stateBusy(context) ||
                              !cubit.canTransitionTo(order, 'cancelled')
                          ? null
                          : () => _cancelOrder(context),
                  icon: const Icon(Icons.close),
                  label: const Text('إلغاء الطلب'),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xfff8fafc),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'اضغط على "فتح صفحة التجهيز" لتحديث الحالة ضمن المسار المنطقي للطلب.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool stateBusy(BuildContext context) =>
      context.watch<OrdersCubit>().state is OrdersSaving;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? Colors.indigo.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? Colors.indigo : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.indigo : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(label),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            'لا توجد طلبات مطابقة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'غيّر الفلاتر أو كلمة البحث لعرض نتائج أخرى.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'جديد';
    case 'confirmed':
      return 'مؤكد';
    case 'preparing':
      return 'قيد التحضير';
    case 'shipped':
      return 'بالشحن';
    case 'delivered':
      return 'مكتمل';
    case 'cancelled':
      return 'ملغي';
    default:
      return status;
  }
}

const List<String> _orderFlowStatuses = <String>[
  'pending',
  'confirmed',
  'preparing',
  'shipped',
  'delivered',
];

int _statusStepIndex(String status) {
  if (status == 'cancelled') {
    return -1;
  }
  return _orderFlowStatuses.indexOf(status);
}

class _OrderStatusTimeline extends StatelessWidget {
  const _OrderStatusTimeline({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: const Text(
          'تم إلغاء الطلب',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    final int currentIndex = _statusStepIndex(status);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(_orderFlowStatuses.length, (index) {
        final String step = _orderFlowStatuses[index];
        final bool done = currentIndex >= index;
        final bool current = currentIndex == index;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:
                current
                    ? Colors.indigo.withValues(alpha: 0.16)
                    : done
                    ? Colors.green.withValues(alpha: 0.14)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  current
                      ? Colors.indigo
                      : done
                      ? Colors.green.shade400
                      : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                done ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 14,
                color: done ? Colors.green : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                _statusLabel(step),
                style: TextStyle(
                  fontWeight: current ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
