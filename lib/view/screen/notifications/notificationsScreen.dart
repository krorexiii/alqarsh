import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/notifications/cubit/notifications_cubit.dart';
import 'package:alkhafajdashboard/view/screen/notifications/widget/send_notification_dialog.dart';
import 'package:alkhafajdashboard/view/widget/dashboardDrawer.dart';
import 'package:alkhafajdashboard/view/widget/myAppbar.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit()..initialize(),
      child: Scaffold(
        drawer: const DashboardDrawer(currentRoute: 'notifications'),
        backgroundColor: const Color(0xfff6f7fb),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Builder(
                builder: (context) => MyAppbar(
                  title: 'إدارة الإشعارات',
                  isBack: false,
                  actions: [
                    IconButton(
                      onPressed: () =>
                          context.read<NotificationsCubit>().initialize(),
                      icon: const Icon(Icons.refresh),
                      tooltip: 'تحديث',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: BlocConsumer<NotificationsCubit, NotificationsState>(
                  listener: (context, state) {
                    if (state is NotificationsError ||
                        state is NotificationsSuccess) {
                      final String message = state is NotificationsError
                          ? state.message
                          : (state as NotificationsSuccess).message;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: state is NotificationsError
                              ? Colors.red.shade600
                              : Colors.green.shade600,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final NotificationsCubit cubit =
                        context.read<NotificationsCubit>();

                    if (state is NotificationsLoading &&
                        cubit.notifications.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _NotificationsHeader(cubit: cubit),
                        const SizedBox(height: 12),
                        Expanded(
                          child: cubit.notifications.isEmpty
                              ? const _EmptyView()
                              : ListView.separated(
                                  itemCount: cubit.notifications.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final n = cubit.notifications[index];
                                    return _NotificationCard(
                                      notification: n,
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

// ─── Header ──────────────────────────────────────────────────────────────────

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.cubit});

  final NotificationsCubit cubit;

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
                  'إرسال إشعارات Push للعملاء',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'أرسل عروض أو إعلانات لجميع عملاء التطبيق دفعة واحدة. الإشعارات تصل حتى لو التطبيق مغلق.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xffeef2ff),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Text(
                      'عدد العملاء',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cubit.customerCount}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () async {
                  final bool? sent = await showDialog<bool>(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: cubit,
                      child: const SendNotificationDialog(),
                    ),
                  );
                  if (sent == true && context.mounted) {
                    cubit.initialize();
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('إرسال إشعار جديد'),
                style: FilledButton.styleFrom(
                  backgroundColor: ConstVar.pColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Notification Card ───────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.cubit,
  });

  final Map<String, dynamic> notification;
  final NotificationsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final String title = notification['title'] ?? '';
    final String body = notification['body'] ?? '';
    final String type = notification['type'] ?? '';
    final String createdAt = notification['created_at'] ?? '';
    final int? id = notification['id'];
    final Map<String, dynamic>? customer =
        notification['customers'] is Map<String, dynamic>
            ? notification['customers'] as Map<String, dynamic>
            : null;

    final IconData typeIcon;
    final Color typeColor;
    final String typeLabel;

    switch (type) {
      case 'promotion':
        typeIcon = Icons.local_offer;
        typeColor = Colors.orange;
        typeLabel = 'عرض';
        break;
      case 'announcement':
        typeIcon = Icons.campaign;
        typeColor = Colors.blue;
        typeLabel = 'إعلان';
        break;
      case 'order_status':
        typeIcon = Icons.receipt_long;
        typeColor = Colors.green;
        typeLabel = 'حالة طلب';
        break;
      default:
        typeIcon = Icons.notifications;
        typeColor = Colors.grey;
        typeLabel = type;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(typeIcon, color: typeColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (customer != null)
                      MyText(
                        customer['name'] ?? '',
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          if (id != null && type != 'order_status')
            IconButton(
              onPressed: () async {
                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف الإشعار'),
                    content:
                        const Text('هل أنت متأكد من حذف هذا الإشعار؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  cubit.deleteNotification(notificationId: id);
                }
              },
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'حذف',
            ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final DateTime date = DateTime.parse(dateStr);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Empty View ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            'لا توجد إشعارات مرسلة بعد',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'اضغط على "إرسال إشعار جديد" لإرسال عرض أو إعلان لجميع العملاء.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
