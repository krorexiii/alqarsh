import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/data/model/orders/order_item_model.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/utils/order_delivery_type_helper.dart';
import 'package:alkhafajdashboard/view/screen/orders/cubit/orders_cubit.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderPreparationScreen extends StatelessWidget {
  const OrderPreparationScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final OrdersCubit cubit = context.read<OrdersCubit>();

    return DashboardScaffold(
      currentRoute: 'orders',
      title: 'تجهيز الطلب',
      subtitle:
          'مراجعة تفاصيل الطلب، متابعة تاريخه، وتنفيذ إجراءات الموقع ضمن صفحة أوضح وأكثر توازناً.',
      showDrawer: false,
      isBack: true,
      actions: <Widget>[
        MyButton(
          text: 'العودة للطلبات',
          icon: Icons.arrow_back_rounded,
          variant: MyButtonVariant.secondary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
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

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 1080;
              final Widget summary = _OrderPreparationSummary(
                order: latestOrder,
              );
              final Widget actions = _OrderPreparationActions(
                order: latestOrder,
                isSaving: isSaving,
              );

              if (compact) {
                return ListView(
                  children: <Widget>[
                    summary,
                    const SizedBox(height: 18),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 3, child: summary),
                  const SizedBox(width: 18),
                  Expanded(flex: 2, child: actions),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _OrderPreparationSummary extends StatelessWidget {
  const _OrderPreparationSummary({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          MyText(
            'الطلب #${order.id} - ${order.customerName}',
            size: 24,
            fontWeight: FontWeight.w900,
          ),
          const SizedBox(height: 8),
          MyText(
            'إجمالي الطلب ${order.total.toStringAsFixed(2)} مع متابعة الحالة والموقع الحالي وسجل التنفيذ.',
            size: 14,
            color: ConstVar.textMuted,
            height: 1.5,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoBadge(label: 'الحالة: ${_statusLabel(order.status)}'),
              _InfoBadge(label: 'نوع الطلب: ${orderDeliveryTypeLabel(order)}'),
              if (order.isFutureDelivery)
                _InfoBadge(
                  label:
                      'يوم الطلب: ${formatOrderDate(order.scheduledDeliveryDate)}',
                ),
              _InfoBadge(
                label: 'الموقع: ${order.assignedLocationName ?? 'غير محدد'}',
              ),
              _InfoBadge(label: 'الإجمالي: ${order.total.toStringAsFixed(2)}'),
              if (order.hasPromoDiscount)
                _InfoBadge(
                  label:
                      order.discountCodeSnapshot == null ||
                          order.discountCodeSnapshot!.isEmpty
                      ? 'برومو مفعّل'
                      : 'برومو: ${order.discountCodeSnapshot}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          _OrderStatusTimeline(status: order.status),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'بيانات العميل',
            child: Column(
              children: [
                _DataRow(title: 'الاسم', value: order.customerName),
                _DataRow(title: 'الهاتف', value: order.customerPhone),
                _DataRow(
                  title: 'نوع الطلب',
                  value: orderDeliveryTypeLabel(order),
                ),
                if (order.isFutureDelivery)
                  _DataRow(
                    title: 'يوم الطلب',
                    value: formatOrderDate(order.scheduledDeliveryDate),
                  ),
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
            title: 'الملخص المالي',
            child: Column(
              children: [
                _DataRow(
                  title: 'المنتجات',
                  value: order.subtotal.toStringAsFixed(2),
                ),
                _DataRow(
                  title: 'التوصيل',
                  value: order.deliveryFee == 0
                      ? 'مجاني'
                      : order.deliveryFee.toStringAsFixed(2),
                ),
                if (order.hasPromoDiscount)
                  _DataRow(
                    title:
                        order.discountCodeSnapshot == null ||
                            order.discountCodeSnapshot!.isEmpty
                        ? 'خصم البرومو'
                        : 'خصم البرومو (${order.discountCodeSnapshot})',
                    value: '-${order.discountAmount.toStringAsFixed(2)}',
                  ),
                _DataRow(
                  title: 'الإجمالي النهائي',
                  value: order.total.toStringAsFixed(2),
                ),
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
                      subtitle: _OrderItemSubtitle(item: item),
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
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: ConstVar.panelSoft,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            color: ConstVar.pColor,
                            size: 20,
                          ),
                        ),
                        title: Text(_statusLabel(entry.status)),
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

class _OrderItemSubtitle extends StatelessWidget {
  const _OrderItemSubtitle({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_itemPriceLine(item)),
        if (item.formattedSelection.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              item.formattedSelection,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _itemPriceLine(OrderItemModel item) {
    if (item.discountPercentSnapshot > 0) {
      return 'الكمية ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} '
          '(خصم ${item.discountPercentSnapshot}% من ${item.originalUnitPrice.toStringAsFixed(2)})';
    }
    return 'الكمية ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}';
  }
}

class _OrderPreparationActions extends StatelessWidget {
  const _OrderPreparationActions({required this.order, required this.isSaving});

  final OrderModel order;
  final bool isSaving;

  Future<String?> _askRequiredReason(BuildContext context, String title) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
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

  Future<void> _changeStatusWithReason(
    BuildContext context,
    OrdersCubit cubit,
    String status,
    String title,
  ) async {
    final String? reason = await _askRequiredReason(context, title);
    if (reason == null) {
      return;
    }
    await cubit.changeOrderStatus(
      order: order,
      status: status,
      notes: reason,
      locationId: order.assignedLocationId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final OrdersCubit cubit = context.read<OrdersCubit>();

    return MyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MyText('إجراءات الموقع', size: 22, fontWeight: FontWeight.w900),
          const SizedBox(height: 8),
          MyText(
            'من هنا يستطيع موظف الموقع بدء التجهيز أو تحويل الطلب أو إنهاؤه مع تسجيل السبب بوضوح.',
            size: 14,
            color: ConstVar.textMuted,
            height: 1.5,
          ),
          const SizedBox(height: 18),
          MyButton(
            text: 'بدء التجهيز',
            icon: Icons.kitchen_outlined,
            expand: true,
            onPressed: isSaving || !cubit.canTransitionTo(order, 'preparing')
                ? null
                : () => _changeStatusWithReason(
                    context,
                    cubit,
                    'preparing',
                    'سبب بدء التجهيز',
                  ),
          ),
          const SizedBox(height: 10),
          MyButton(
            text: 'تحويل إلى الشحن',
            icon: Icons.local_shipping_outlined,
            variant: MyButtonVariant.secondary,
            onPressed: isSaving || !cubit.canTransitionTo(order, 'shipped')
                ? null
                : () => _changeStatusWithReason(
                    context,
                    cubit,
                    'shipped',
                    'سبب تحويل الطلب إلى الشحن',
                  ),
          ),
          const SizedBox(height: 10),
          MyButton(
            text: 'رفض وإلغاء الطلب',
            icon: Icons.reply_outlined,
            variant: MyButtonVariant.ghost,
            onPressed: isSaving || !cubit.canTransitionTo(order, 'cancelled')
                ? null
                : () => _changeStatusWithReason(
                    context,
                    cubit,
                    'cancelled',
                    'سبب رفض/إلغاء الطلب',
                  ),
          ),
          const SizedBox(height: 10),
          MyButton(
            text: 'إنهاء الطلب',
            icon: Icons.check_circle_outline,
            variant: MyButtonVariant.secondary,
            onPressed: isSaving || !cubit.canTransitionTo(order, 'delivered')
                ? null
                : () => _changeStatusWithReason(
                    context,
                    cubit,
                    'delivered',
                    'سبب إنهاء الطلب',
                  ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ConstVar.panelSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ConstVar.borderColor),
            ),
            child: MyText(
              'الحالة الحالية: ${_statusLabel(order.status)}\nالموقع الحالي: ${order.assignedLocationName ?? 'غير محدد'}',
              size: 14,
              fontWeight: FontWeight.w700,
              height: 1.55,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ConstVar.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText(title, size: 18, fontWeight: FontWeight.w900),
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
        color: ConstVar.panelSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ConstVar.borderColor),
      ),
      child: MyText(
        label,
        size: 12,
        fontWeight: FontWeight.w700,
        color: ConstVar.pColor,
      ),
    );
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
            color: current
                ? Colors.indigo.withValues(alpha: 0.16)
                : done
                ? Colors.green.withValues(alpha: 0.14)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: current
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
