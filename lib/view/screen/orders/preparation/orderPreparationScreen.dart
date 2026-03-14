import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/view/screen/orders/cubit/orders_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderPreparationScreen extends StatelessWidget {
  const OrderPreparationScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final OrdersCubit cubit = context.read<OrdersCubit>();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Builder(
              builder: (context) => const MyAppbar(
                title: 'تجهيز الطلب',
                isBack: true,
                actions: [],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocConsumer<OrdersCubit, OrdersState>(
                listener: (context, state) {
                  if (state is OrdersSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                    Navigator.of(context).pop(true);
                  } else if (state is OrdersError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  final bool isSaving = state is OrdersSaving;
                  final OrderModel latestOrder =
                      cubit.orders
                          .where((current) => current.id == order.id)
                          .firstOrNull ??
                      order;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _OrderPreparationSummary(order: latestOrder),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _OrderPreparationActions(
                          order: latestOrder,
                          isSaving: isSaving,
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
    );
  }
}

class _OrderPreparationSummary extends StatelessWidget {
  const _OrderPreparationSummary({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView(
        children: [
          Text(
            'الطلب #${order.id} - ${order.customerName}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(label: 'الحالة: ${order.status}'),
              _InfoBadge(
                label: 'الموقع: ${order.assignedLocationName ?? 'غير محدد'}',
              ),
              _InfoBadge(label: 'الإجمالي: ${order.total.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'بيانات العميل',
            child: Column(
              children: [
                _DataRow(title: 'الاسم', value: order.customerName),
                _DataRow(title: 'الهاتف', value: order.customerPhone),
                _DataRow(
                  title: 'الإحداثيات',
                  value:
                      '${order.customerLat.toStringAsFixed(5)}, ${order.customerLng.toStringAsFixed(5)}',
                ),
                if ((order.note ?? '').trim().isNotEmpty)
                  _DataRow(title: 'ملاحظات', value: order.note!),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'عناصر الطلب',
            child: Column(
              children: order.items
                  .map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.titleSnapshot.isEmpty
                            ? 'منتج'
                            : item.titleSnapshot,
                      ),
                      subtitle: Text(
                        'الكمية ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}',
                      ),
                      trailing: Text(item.lineTotal.toStringAsFixed(2)),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          _SectionCard(
            title: 'سجل الحالات',
            child: Column(
              children: order.history.isEmpty
                  ? [
                      Text(
                        'لا يوجد سجل حالات بعد',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ]
                  : order.history.map((entry) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history),
                        title: Text(entry.status),
                        subtitle: Text(entry.notes ?? 'بدون ملاحظات'),
                        trailing: Text(
                          entry.createdAt == null
                              ? ''
                              : '${entry.createdAt!.hour.toString().padLeft(2, '0')}:${entry.createdAt!.minute.toString().padLeft(2, '0')}',
                        ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderPreparationActions extends StatelessWidget {
  const _OrderPreparationActions({required this.order, required this.isSaving});

  final OrderModel order;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    final OrdersCubit cubit = context.read<OrdersCubit>();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'إجراءات الموقع',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'من هنا يستطيع موظف الموقع بدء التجهيز أو رفض الطلب وإعادته للإدارة أو إنهاؤه.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: isSaving || !order.canBePrepared
                ? null
                : () => cubit.changeOrderStatus(
                    order: order,
                    status: 'preparing',
                    notes: 'بدأ الموقع تجهيز الطلب من شاشة التحضير',
                    locationId: cubit.currentUser?.locationId,
                  ),
            icon: const Icon(Icons.kitchen_outlined),
            label: const Text('بدء التجهيز'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: isSaving
                ? null
                : () => cubit.changeOrderStatus(
                    order: order,
                    status: 'pending',
                    notes: 'تم رفض الطلب من الموقع وإرجاعه للإدارة',
                    locationId: cubit.currentUser?.locationId,
                  ),
            icon: const Icon(Icons.reply_outlined),
            label: const Text('رفض وإرجاع للإدارة'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: isSaving
                ? null
                : () => cubit.changeOrderStatus(
                    order: order,
                    status: 'delivered',
                    notes: 'تم إنهاء الطلب من الموقع',
                    locationId: cubit.currentUser?.locationId,
                  ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('إنهاء الطلب'),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xfff8fafc),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'الحالة الحالية: ${order.status}\nالموقع الحالي: ${order.assignedLocationName ?? 'غير محدد'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfffcfcfd),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffeef2ff),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
