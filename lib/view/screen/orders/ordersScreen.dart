import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/utils/order_delivery_type_helper.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/orders/cubit/orders_cubit.dart';
import 'package:alkhafajdashboard/view/screen/orders/preparation/orderPreparationScreen.dart';
import 'package:alkhafajdashboard/view/screen/orders/widget/order_details_dialog.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrdersCubit()..initialize(),
      child: DashboardScaffold(
        currentRoute: 'orders',
        title: 'إدارة الطلبات',
        subtitle:
            'لوحة متابعة احترافية للطلبات، الفرز، التحضير، التحويل، والتسليم ضمن تجربة عربية واضحة ومريحة.',
        actions: <Widget>[
          BlocBuilder<OrdersCubit, OrdersState>(
            builder: (BuildContext context, OrdersState state) {
              final OrdersCubit cubit = context.read<OrdersCubit>();
              final bool isLoading = state is OrdersLoading;
              return MyButton(
                text: isLoading ? 'جاري التحديث...' : 'تحديث الطلبات',
                icon: isLoading ? Icons.hourglass_empty : Icons.refresh_rounded,
                variant: MyButtonVariant.secondary,
                onPressed: isLoading
                    ? null
                    : () async {
                        await cubit.refreshSilently();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('تم تحديث الطلبات بنجاح'),
                                ],
                              ),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
              );
            },
          ),
        ],
        child: BlocConsumer<OrdersCubit, OrdersState>(
          listener: (context, state) {
            if (state is OrdersError || state is OrdersSuccess) {
              final String message = state is OrdersError
                  ? state.message
                  : (state as OrdersSuccess).message;
              final bool isError = state is OrdersError;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        isError
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(message)),
                    ],
                  ),
                  backgroundColor: isError
                      ? Colors.red.shade600
                      : Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          },
          builder: (context, state) {
            final OrdersCubit cubit = context.read<OrdersCubit>();
            if (state is OrdersLoading && cubit.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ConstVar.pColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحميل الطلبات...',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            final List<OrderModel> orders = cubit.visibleOrders;

            return Column(
              children: [
                _StatsBar(cubit: cubit),
                const SizedBox(height: 16),
                _ToolBar(cubit: cubit),
                const SizedBox(height: 16),
                Expanded(
                  child: orders.isEmpty
                      ? const _EmptyOrdersView()
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return TweenAnimationBuilder<double>(
                              duration: Duration(
                                milliseconds: 300 + (index * 50),
                              ),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: _OrderCard(
                                order: orders[index],
                                cubit: cubit,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════ Stats Bar ═══════════════

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.cubit});
  final OrdersCubit cubit;

  @override
  Widget build(BuildContext context) {
    int countByStatus(String status) =>
        cubit.visibleOrders.where((o) => o.status == status).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(
            label: 'الكل',
            count: cubit.visibleOrders.length,
            color: ConstVar.pColor,
            icon: Icons.shopping_bag,
          ),
          _StatItem(
            label: 'جديد',
            count: countByStatus('pending'),
            color: Colors.orange,
            icon: Icons.fiber_new,
          ),
          _StatItem(
            label: 'مستقبل',
            count: cubit.visibleOrders.where((o) => o.isFutureDelivery).length,
            color: Colors.indigo,
            icon: Icons.event_available,
          ),
          _StatItem(
            label: 'مؤكد',
            count: countByStatus('confirmed'),
            color: Colors.blue,
            icon: Icons.verified,
          ),
          _StatItem(
            label: 'تحضير',
            count: countByStatus('preparing'),
            color: Colors.purple,
            icon: Icons.restaurant,
          ),
          _StatItem(
            label: 'شحن',
            count: countByStatus('shipped'),
            color: Colors.teal,
            icon: Icons.local_shipping,
          ),
          _StatItem(
            label: 'مكتمل',
            count: countByStatus('delivered'),
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          _StatItem(
            label: 'ملغي',
            count: countByStatus('cancelled'),
            color: Colors.red,
            icon: Icons.cancel,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════ Toolbar ═══════════════

class _ToolBar extends StatelessWidget {
  const _ToolBar({required this.cubit});
  final OrdersCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xfff0f2f5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    onChanged: cubit.setSearchQuery,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'بحث برقم الطلب، اسم العميل أو الهاتف...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: ConstVar.pColor.withValues(alpha: 0.6),
                        size: 22,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f2f5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<OrdersDeliveryTypeFilter>(
                    value: cubit.selectedDeliveryTypeFilter,
                    isDense: true,
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                      color: ConstVar.pColor.withValues(alpha: 0.7),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    items: OrdersDeliveryTypeFilter.values
                        .map(
                          (filter) =>
                              DropdownMenuItem<OrdersDeliveryTypeFilter>(
                                value: filter,
                                child: Text(_deliveryTypeFilterLabel(filter)),
                              ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        cubit.setDeliveryTypeFilter(value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xfff0f2f5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<OrdersSortMode>(
                    value: cubit.selectedSortMode,
                    isDense: true,
                    icon: Icon(
                      Icons.unfold_more,
                      size: 20,
                      color: ConstVar.pColor.withValues(alpha: 0.7),
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
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
                        child: Text('الأعلى مبلغ'),
                      ),
                      DropdownMenuItem(
                        value: OrdersSortMode.oldestPendingFirst,
                        child: Text('المعلقة أولاً'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) cubit.setSortMode(value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SmallIconBtn(
                icon: Icons.refresh,
                tooltip: 'تحديث',
                onPressed: cubit.refreshSilently,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
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
                  color: Colors.orange,
                ),
                _FilterChip(
                  label: 'مؤكد',
                  selected:
                      cubit.selectedFilter == OrdersFilterStatus.confirmed,
                  onTap: () => cubit.setFilter(OrdersFilterStatus.confirmed),
                  color: Colors.blue,
                ),
                _FilterChip(
                  label: 'قيد التحضير',
                  selected:
                      cubit.selectedFilter == OrdersFilterStatus.preparing,
                  onTap: () => cubit.setFilter(OrdersFilterStatus.preparing),
                  color: Colors.purple,
                ),
                _FilterChip(
                  label: 'بالشحن',
                  selected: cubit.selectedFilter == OrdersFilterStatus.shipped,
                  onTap: () => cubit.setFilter(OrdersFilterStatus.shipped),
                  color: Colors.teal,
                ),
                _FilterChip(
                  label: 'مكتمل',
                  selected:
                      cubit.selectedFilter == OrdersFilterStatus.delivered,
                  onTap: () => cubit.setFilter(OrdersFilterStatus.delivered),
                  color: Colors.green,
                ),
                _FilterChip(
                  label: 'ملغي',
                  selected:
                      cubit.selectedFilter == OrdersFilterStatus.cancelled,
                  onTap: () => cubit.setFilter(OrdersFilterStatus.cancelled),
                  color: Colors.red,
                ),
                _FilterChip(
                  label: 'مخفضة',
                  selected:
                      cubit.selectedFilter == OrdersFilterStatus.discounted,
                  onTap: () => cubit.setFilter(OrdersFilterStatus.discounted),
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ),
          if (cubit.isAdmin && cubit.hasSelection) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ConstVar.pColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ConstVar.pColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: ConstVar.pColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'تم تحديد ${cubit.selectedCount} طلب',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: ConstVar.pColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: cubit.clearSelection,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(
                      'إلغاء التحديد',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton.icon(
                    onPressed: () => _bulkAssign(context, cubit),
                    icon: const Icon(Icons.alt_route, size: 16),
                    label: const Text(
                      'تحويل جماعي',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: ConstVar.pColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        cubit.bulkChangeStatus(status: 'cancelled'),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text(
                      'إلغاء جماعي',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _bulkAssign(BuildContext context, OrdersCubit cubit) async {
    if (cubit.locations.isEmpty) return;
    int selectedLocationId = cubit.locations.first.id;

    final int? locationId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تحويل جماعي للموقع'),
        content: StatefulBuilder(
          builder: (context, setState) => DropdownButtonFormField<int>(
            initialValue: selectedLocationId,
            items: cubit.locations
                .map(
                  (l) =>
                      DropdownMenuItem<int>(value: l.id, child: Text(l.name)),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => selectedLocationId = v);
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
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (locationId == null) return;

    final LocationModel location = cubit.locations.firstWhere(
      (l) => l.id == locationId,
    );
    await cubit.bulkAssignOrders(location: location);
  }
}

class _SmallIconBtn extends StatelessWidget {
  const _SmallIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xfff5f7fa),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: Colors.grey.shade700),
          ),
        ),
      ),
    );
  }
}

// ═══════════════ Order Card ═══════════════

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.cubit});
  final OrderModel order;
  final OrdersCubit cubit;

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = cubit.isAdmin;
    final bool isBusy = context.watch<OrdersCubit>().state is OrdersSaving;
    final SuggestedLocation? suggestion = cubit.getSuggestedLocation(order);
    final bool isFuture = order.isFutureDelivery;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: order.isLate
            ? Border.all(color: Colors.red.shade200, width: 2)
            : isFuture
            ? Border.all(color: Colors.indigo.shade200, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _statusColor(order.status).withValues(alpha: 0.04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (isAdmin)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Checkbox(
                      value: cubit.isOrderSelected(order),
                      onChanged: (_) => cubit.toggleOrderSelection(order),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      activeColor: ConstVar.pColor,
                    ),
                  ),
                _StatusBadge(status: order.status),
                if (isFuture) ...[
                  const SizedBox(width: 8),
                  _FutureOrderBadge(order: order),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id} - ${order.customerName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 13,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.customerPhone,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _OrderTimingBadge(order: order),
                const SizedBox(width: 10),
                _SmallIconBtn(
                  icon: isAdmin ? Icons.visibility : Icons.fact_check,
                  tooltip: isAdmin ? 'التفاصيل' : 'صفحة التجهيز',
                  onPressed: () async {
                    if (isAdmin) {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => OrderDetailsDialog(order: order),
                      );
                      return;
                    }
                    final bool? updated = await Navigator.of(context)
                        .push<bool>(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: cubit,
                              child: OrderPreparationScreen(order: order),
                            ),
                          ),
                        );
                    if (updated == true && context.mounted) {
                      await context.read<OrdersCubit>().refreshSilently();
                    }
                  },
                ),
              ],
            ),
          ),

          // ── Body ──
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    _ModernInfoChip(
                      icon: Icons.attach_money,
                      text: '${order.total.toStringAsFixed(0)} د.ع',
                      gradient: [Colors.green.shade50, Colors.green.shade100],
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    _ModernInfoChip(
                      icon: Icons.inventory_2,
                      text: '${order.totalItemsCount} عنصر',
                      gradient: [Colors.blue.shade50, Colors.blue.shade100],
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    _ModernInfoChip(
                      icon: Icons.grid_view,
                      text: '${order.totalQuantity} قطعة',
                      gradient: [Colors.purple.shade50, Colors.purple.shade100],
                      color: Colors.purple.shade700,
                    ),
                    if (order.discountedItemsCount > 0) ...[
                      const SizedBox(width: 8),
                      _ModernInfoChip(
                        icon: Icons.local_offer,
                        text: '${order.discountedItemsCount} مخفض',
                        gradient: [Colors.amber.shade50, Colors.amber.shade100],
                        color: Colors.amber.shade800,
                      ),
                    ],
                    if (isFuture) ...[
                      const SizedBox(width: 8),
                      _ModernInfoChip(
                        icon: Icons.event_available,
                        text: futureOrderBadgeText(order),
                        gradient: [
                          Colors.indigo.shade50,
                          Colors.indigo.shade100,
                        ],
                        color: Colors.indigo.shade700,
                      ),
                    ],
                    if (order.hasPromoDiscount) ...[
                      const SizedBox(width: 8),
                      _ModernInfoChip(
                        icon: Icons.sell_rounded,
                        text:
                            order.discountCodeSnapshot == null ||
                                order.discountCodeSnapshot!.isEmpty
                            ? 'برومو'
                            : order.discountCodeSnapshot!,
                        gradient: [Colors.teal.shade50, Colors.teal.shade100],
                        color: Colors.teal.shade800,
                      ),
                    ],
                    const Spacer(),
                    if (order.assignedLocationName != null)
                      _ModernInfoChip(
                        icon: Icons.location_on,
                        text: order.assignedLocationName!,
                        gradient: [
                          ConstVar.pColor.withValues(alpha: 0.1),
                          ConstVar.pColor.withValues(alpha: 0.15),
                        ],
                        color: ConstVar.pColor,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                _OrderTimeline(status: order.status),
              ],
            ),
          ),

          // ── Inline Status Actions ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xfff8f9fa),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: _InlineStatusActions(
              order: order,
              cubit: cubit,
              isBusy: isBusy,
              isAdmin: isAdmin,
              suggestion: suggestion,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════ Inline Status Actions ═══════════════

class _InlineStatusActions extends StatelessWidget {
  const _InlineStatusActions({
    required this.order,
    required this.cubit,
    required this.isBusy,
    required this.isAdmin,
    required this.suggestion,
  });

  final OrderModel order;
  final OrdersCubit cubit;
  final bool isBusy;
  final bool isAdmin;
  final SuggestedLocation? suggestion;

  @override
  Widget build(BuildContext context) {
    final List<String> allowed = cubit.getAllowedNextStatuses(order);

    if (allowed.isEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text(
            order.status == 'cancelled' ? 'تم إلغاء الطلب' : 'الطلب مكتمل',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...allowed.where((s) => s != 'cancelled').map((nextStatus) {
          if (isAdmin &&
              order.status == 'pending' &&
              nextStatus == 'confirmed') {
            return _LocationAssignDropdown(
              order: order,
              cubit: cubit,
              isBusy: isBusy,
              suggestion: suggestion,
            );
          }
          return _ActionButton(
            label: _nextActionLabel(nextStatus),
            icon: _nextActionIcon(nextStatus),
            color: _statusColor(nextStatus),
            isBusy: isBusy,
            onPressed: () => cubit.changeOrderStatus(
              order: order,
              status: nextStatus,
              locationId: order.assignedLocationId,
            ),
          );
        }),
        if (allowed.contains('cancelled'))
          _ActionButton(
            label: 'إلغاء',
            icon: Icons.close,
            color: Colors.red,
            isBusy: isBusy,
            outlined: true,
            onPressed: () =>
                cubit.changeOrderStatus(order: order, status: 'cancelled'),
          ),
        if (isAdmin && suggestion != null && order.status == 'pending')
          Text(
            '📍 مقترح: ${suggestion!.location.name} (${suggestion!.distance.toStringAsFixed(1)} كم)',
            style: TextStyle(
              fontSize: 12,
              color: ConstVar.pColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  String _nextActionLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'تأكيد';
      case 'preparing':
        return 'بدء التحضير';
      case 'shipped':
        return 'شحن';
      case 'delivered':
        return 'تم التسليم';
      default:
        return status;
    }
  }

  IconData _nextActionIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check;
      case 'preparing':
        return Icons.restaurant;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.arrow_forward;
    }
  }
}

class _LocationAssignDropdown extends StatelessWidget {
  const _LocationAssignDropdown({
    required this.order,
    required this.cubit,
    required this.isBusy,
    required this.suggestion,
  });
  final OrderModel order;
  final OrdersCubit cubit;
  final bool isBusy;
  final SuggestedLocation? suggestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: PopupMenuButton<LocationModel>(
        enabled: !isBusy,
        tooltip: 'تأكيد وتحويل لموقع',
        offset: const Offset(0, 45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        itemBuilder: (_) => cubit.locations
            .map(
              (location) => PopupMenuItem<LocationModel>(
                value: location,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: location.id == suggestion?.location.id
                              ? Colors.amber.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          location.id == suggestion?.location.id
                              ? Icons.star
                              : Icons.location_on,
                          size: 20,
                          color: location.id == suggestion?.location.id
                              ? Colors.amber.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (location.id == suggestion?.location.id)
                              Text(
                                'موقع مقترح (${suggestion!.distance.toStringAsFixed(1)} كم)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
        onSelected: (location) =>
            cubit.assignOrder(order: order, location: location),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'تأكيد وتحويل',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, size: 20, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isBusy,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final IconData icon;
  final Color color;
  final bool isBusy;
  final bool outlined;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isBusy ? null : onPressed,
      icon: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }
}

// ═══════════════ Shared Widgets ═══════════════

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _statusColor(status),
        ),
      ),
    );
  }
}

class _FutureOrderBadge extends StatelessWidget {
  const _FutureOrderBadge({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available, size: 13, color: Colors.indigo.shade700),
          const SizedBox(width: 5),
          Text(
            futureOrderBadgeText(order),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTimingBadge extends StatelessWidget {
  const _OrderTimingBadge({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final bool isFuture = order.isFutureDelivery;
    final Color color = isFuture
        ? Colors.indigo.shade700
        : order.isLate
        ? Colors.red.shade700
        : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isFuture
            ? Colors.indigo.shade50
            : order.isLate
            ? Colors.red.shade50
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFuture ? Icons.event_note : Icons.schedule,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            isFuture
                ? formatOrderDate(order.scheduledDeliveryDate)
                : '${order.waitingDuration.inMinutes} د',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernInfoChip extends StatelessWidget {
  const _ModernInfoChip({
    required this.icon,
    required this.text,
    required this.gradient,
    required this.color,
  });
  final IconData icon;
  final String text;
  final List<Color> gradient;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? ConstVar.pColor;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? c : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? c : Colors.grey.shade600,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == 'cancelled') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 16, color: Colors.red),
            SizedBox(width: 6),
            Text(
              'تم إلغاء الطلب',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final int currentIdx = _orderFlowStatuses.indexOf(status);

    return Row(
      children: List.generate(_orderFlowStatuses.length * 2 - 1, (i) {
        if (i.isOdd) {
          final int stepBefore = i ~/ 2;
          final bool done = currentIdx > stepBefore;
          return Expanded(
            child: Container(
              height: 2,
              color: done ? Colors.green.shade400 : Colors.grey.shade300,
            ),
          );
        }

        final int stepIdx = i ~/ 2;
        final String step = _orderFlowStatuses[stepIdx];
        final bool done = currentIdx >= stepIdx;
        final bool current = currentIdx == stepIdx;

        return Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: current
                    ? ConstVar.pColor
                    : done
                    ? Colors.green
                    : Colors.grey.shade300,
              ),
              child: Icon(
                done ? Icons.check : Icons.circle,
                size: done ? 14 : 8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _statusLabel(step),
              style: TextStyle(
                fontSize: 10,
                fontWeight: current ? FontWeight.bold : FontWeight.w500,
                color: current
                    ? ConstVar.pColor
                    : done
                    ? Colors.green.shade700
                    : Colors.grey.shade500,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _EmptyOrdersView extends StatelessWidget {
  const _EmptyOrdersView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'لا توجد طلبات مطابقة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'جرّب تغيير الفلاتر أو كلمة البحث',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════ Helpers ═══════════════

String _statusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'جديد';
    case 'confirmed':
      return 'مؤكد';
    case 'preparing':
      return 'تحضير';
    case 'shipped':
      return 'شحن';
    case 'delivered':
      return 'مكتمل';
    case 'cancelled':
      return 'ملغي';
    default:
      return status;
  }
}

String _deliveryTypeFilterLabel(OrdersDeliveryTypeFilter filter) {
  switch (filter) {
    case OrdersDeliveryTypeFilter.all:
      return 'كل الأنواع';
    case OrdersDeliveryTypeFilter.current:
      return 'حالي';
    case OrdersDeliveryTypeFilter.future:
      return 'مستقبل';
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
      return Colors.blue;
    case 'preparing':
      return Colors.purple;
    case 'shipped':
      return Colors.teal;
    case 'delivered':
      return Colors.green;
    case 'cancelled':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

const List<String> _orderFlowStatuses = <String>[
  'pending',
  'confirmed',
  'preparing',
  'shipped',
  'delivered',
];
