import 'package:alkhafajdashboard/data/model/orders/order_item_model.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/utils/order_delivery_type_helper.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';

class OrderDetailsDialog extends StatelessWidget {
  const OrderDetailsDialog({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 720,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
          boxShadow: ConstVar.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                decoration: const BoxDecoration(
                  gradient: ConstVar.brandGradient,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              MyText(
                                'تفاصيل الطلب #${order.id}',
                                size: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                              const SizedBox(height: 6),
                              MyText(
                                'عرض شامل للعميل، الموقع، العناصر، وحالة التنفيذ الحالية بشكل مرتب وواضح.',
                                size: 13,
                                color: Colors.white.withValues(alpha: 0.82),
                                height: 1.5,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _HeaderBadge(
                          label: 'الحالة',
                          value: _statusLabel(order.status),
                        ),
                        _HeaderBadge(
                          label: 'نوع الطلب',
                          value: orderDeliveryTypeLabel(order),
                        ),
                        if (order.isFutureDelivery)
                          _HeaderBadge(
                            label: 'يوم الطلب',
                            value: formatOrderDate(order.scheduledDeliveryDate),
                          ),
                        _HeaderBadge(
                          label: 'الموقع',
                          value: order.assignedLocationName ?? 'غير محدد',
                        ),
                        _HeaderBadge(
                          label: 'الإجمالي',
                          value: order.total.toStringAsFixed(2),
                        ),
                        if (order.hasPromoDiscount)
                          _HeaderBadge(
                            label: 'البرومو',
                            value:
                                order.discountCodeSnapshot == null ||
                                    order.discountCodeSnapshot!.isEmpty
                                ? '-'
                                : order.discountCodeSnapshot!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SectionCard(
                        title: 'معلومات العميل',
                        child: Column(
                          children: <Widget>[
                            _InfoRow(
                              title: 'العميل',
                              value: order.customerName,
                            ),
                            _InfoRow(
                              title: 'الهاتف',
                              value: order.customerPhone,
                            ),
                            _InfoRow(
                              title: 'الموقع الحالي',
                              value: order.assignedLocationName ?? 'غير محدد',
                            ),
                            _InfoRow(
                              title: 'نوع الطلب',
                              value: orderDeliveryTypeLabel(order),
                            ),
                            if (order.isFutureDelivery)
                              _InfoRow(
                                title: 'يوم الطلب',
                                value: formatOrderDate(
                                  order.scheduledDeliveryDate,
                                ),
                              ),
                            _InfoRow(
                              title: 'إحداثيات العميل',
                              value:
                                  '${order.customerLat.toStringAsFixed(5)}, ${order.customerLng.toStringAsFixed(5)}',
                            ),
                            if ((order.note ?? '').trim().isNotEmpty)
                              _InfoRow(title: 'ملاحظات', value: order.note!),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'تقدم الطلب',
                        child: _OrderStatusTimeline(status: order.status),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'الملخص المالي',
                        child: Column(
                          children: <Widget>[
                            _InfoRow(
                              title: 'المنتجات',
                              value: order.subtotal.toStringAsFixed(2),
                            ),
                            _InfoRow(
                              title: 'التوصيل',
                              value: order.deliveryFee == 0
                                  ? 'مجاني'
                                  : order.deliveryFee.toStringAsFixed(2),
                            ),
                            if (order.hasPromoDiscount)
                              _InfoRow(
                                title:
                                    order.discountCodeSnapshot == null ||
                                        order.discountCodeSnapshot!.isEmpty
                                    ? 'خصم البرومو'
                                    : 'خصم البرومو (${order.discountCodeSnapshot})',
                                value:
                                    '-${order.discountAmount.toStringAsFixed(2)}',
                              ),
                            _InfoRow(
                              title: 'الإجمالي النهائي',
                              value: order.total.toStringAsFixed(2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'عناصر الطلب',
                        child: Column(
                          children: order.items
                              .map(
                                (OrderItemModel item) =>
                                    _OrderItemTile(item: item),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MyButton(
                    text: 'إغلاق',
                    icon: Icons.check_rounded,
                    variant: MyButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MyText(
            label,
            size: 11,
            color: Colors.white.withValues(alpha: 0.76),
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          MyText(
            value,
            size: 15,
            color: Colors.white,
            fontWeight: FontWeight.w900,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ConstVar.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MyText(title, size: 18, fontWeight: FontWeight.w900),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: MyText(
              '$title:',
              size: 13,
              fontWeight: FontWeight.w800,
              color: ConstVar.textMuted,
            ),
          ),
          Expanded(
            child: MyText(
              value,
              size: 14,
              color: ConstVar.textPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConstVar.panelSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ConstVar.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: ConstVar.pColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: ConstVar.pColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MyText(
                  item.titleSnapshot.isEmpty ? 'منتج' : item.titleSnapshot,
                  size: 16,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(height: 6),
                MyText(
                  _itemPriceLine(item),
                  size: 13,
                  color: ConstVar.textMuted,
                  height: 1.45,
                ),
                if (item.formattedSelection.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: MyText(
                      item.formattedSelection,
                      size: 12,
                      fontWeight: FontWeight.w700,
                      color: ConstVar.pColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const MyText(
                'المجموع',
                size: 11,
                color: ConstVar.textMuted,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 4),
              MyText(
                item.lineTotal.toStringAsFixed(2),
                size: 16,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _itemPriceLine(OrderItemModel item) {
  if (item.discountPercentSnapshot > 0) {
    return 'الكمية: ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} '
        '(خصم ${item.discountPercentSnapshot}% من ${item.originalUnitPrice.toStringAsFixed(2)})';
  }
  return 'الكمية: ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}';
}

const List<String> _orderFlowStatuses = <String>[
  'pending',
  'confirmed',
  'preparing',
  'shipped',
  'delivered',
];

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ConstVar.dangerColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ConstVar.dangerColor.withValues(alpha: 0.20),
          ),
        ),
        child: const MyText(
          'تم إلغاء الطلب',
          size: 14,
          color: ConstVar.dangerColor,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    final int currentIndex = _orderFlowStatuses.indexOf(status);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List<Widget>.generate(_orderFlowStatuses.length, (int index) {
        final String step = _orderFlowStatuses[index];
        final bool done = currentIndex >= index;
        final bool current = currentIndex == index;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: current
                ? ConstVar.pColor.withValues(alpha: 0.12)
                : done
                ? ConstVar.successColor.withValues(alpha: 0.12)
                : ConstVar.panelSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: current
                  ? ConstVar.pColor
                  : done
                  ? ConstVar.successColor.withValues(alpha: 0.30)
                  : ConstVar.borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 16,
                color: current
                    ? ConstVar.pColor
                    : done
                    ? ConstVar.successColor
                    : ConstVar.textMuted,
              ),
              const SizedBox(width: 6),
              MyText(
                _statusLabel(step),
                size: 12,
                fontWeight: FontWeight.w800,
                color: current
                    ? ConstVar.pColor
                    : done
                    ? ConstVar.successColor
                    : ConstVar.textMuted,
              ),
            ],
          ),
        );
      }),
    );
  }
}
