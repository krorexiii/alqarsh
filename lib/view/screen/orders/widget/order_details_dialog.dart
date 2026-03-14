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
                    'الكمية: ${item.quantity} × ${item.unitPrice.toStringAsFixed(2)}',
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
