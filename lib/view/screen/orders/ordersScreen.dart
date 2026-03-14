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
                builder: (context) => const MyAppbar(
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
                      final String message = state is OrdersError
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
                          child: orders.isEmpty
                              ? const _EmptyOrdersView()
                              : ListView.separated(
                                  itemCount: orders.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'لوحة متابعة الطلبات',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  cubit.isAdmin
                      ? 'الأدمن يراجع الطلبات الجديدة ويحوّلها إلى أقرب موقع مناسب.'
                      : 'أنت ترى فقط الطلبات المحولة إلى موقعك لتجهيزها أو رفضها.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.cubit});

  final OrderModel order;
  final OrdersCubit cubit;

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
        border: Border.all(color: Colors.grey.shade200),
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
                        _ChipLabel(label: 'الحالة: ${order.status}'),
                        _ChipLabel(
                          label:
                              'الموقع الحالي: ${order.assignedLocationName ?? 'غير محدد'}',
                        ),
                        _ChipLabel(
                          label: 'الإجمالي: ${order.total.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
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
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: OrderPreparationScreen(order: order),
                      ),
                    ),
                  );

                  if (updated == true && context.mounted) {
                    await context.read<OrdersCubit>().initialize();
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
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              suggestion == null
                  ? 'لا يوجد اقتراح موقع حالياً'
                  : 'أقرب موقع مقترح: ${suggestion.location.name} (${suggestion.distance.toStringAsFixed(2)} كم)',
              style: TextStyle(
                color: suggestion == null
                    ? Colors.grey.shade600
                    : Colors.indigo,
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
                    onPressed: stateBusy(context)
                        ? null
                        : () => cubit.assignOrder(
                            order: order,
                            location: location,
                            notes: location.id == suggestion?.location.id
                                ? 'تم التحويل حسب أقرب موقع مقترح'
                                : 'تم التحويل يدوياً من الأدمن',
                          ),
                    icon: const Icon(Icons.alt_route),
                    label: Text('تحويل إلى ${location.name}'),
                  ),
                ),
                if (order.status != 'cancelled')
                  FilledButton.tonalIcon(
                    onPressed: stateBusy(context)
                        ? null
                        : () => cubit.changeOrderStatus(
                            order: order,
                            status: 'cancelled',
                            notes: 'تم إلغاء الطلب من الإدارة',
                          ),
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
                'اضغط على "فتح صفحة التجهيز" لمراجعة التفاصيل، سجل الحالات، ثم بدء التجهيز أو رفض الطلب أو إنهائه من شاشة مستقلة.',
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
            'لا توجد طلبات حالياً',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'ستظهر هنا الطلبات الواردة من التطبيق ليتم تحويلها أو تجهيزها.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
