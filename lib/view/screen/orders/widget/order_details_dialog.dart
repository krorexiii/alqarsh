import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:flutter/material.dart';

class OrderDetailsDialog extends StatelessWidget {
  const OrderDetailsDialog({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تفاصيل الطلب #${order.id}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _InfoRow(title: 'العميل', value: order.customerName),
              _InfoRow(title: 'الهاتف', value: order.customerPhone),
              _InfoRow(title: 'الحالة', value: order.status),
              _InfoRow(
                title: 'الموقع الحالي',
                value: order.assignedLocationName ?? 'غير محدد',
              ),
              _InfoRow(
                title: 'إحداثيات العميل',
                value:
                    '${order.customerLat.toStringAsFixed(5)}, ${order.customerLng.toStringAsFixed(5)}',
              ),
              const SizedBox(height: 10),
              _OrderStatusTimeline(status: order.status),
              const SizedBox(height: 10),
              if ((order.note ?? '').trim().isNotEmpty)
                _InfoRow(title: 'ملاحظات', value: order.note!),
              const SizedBox(height: 14),
              const Text(
                'العناصر',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ...order.items.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.titleSnapshot.isEmpty ? 'منتج' : item.titleSnapshot,
                  ),
                  subtitle: Text(
                    item.discountPercentSnapshot > 0
                        ? 'الكمية: ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)} (خصم ${item.discountPercentSnapshot}% من ${item.originalUnitPrice.toStringAsFixed(2)})'
                        : 'الكمية: ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}',
                  ),
                  trailing: Text(item.lineTotal.toStringAsFixed(2)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
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

    final int currentIndex = _orderFlowStatuses.indexOf(status);

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
