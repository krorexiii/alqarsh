import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/notifications/cubit/notifications_cubit.dart';
import 'package:alkhafajdashboard/view/screen/notifications/widget/send_notification_dialog.dart';
import 'package:alkhafajdashboard/view/widget/dashboard_scaffold.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsCubit()..initialize(),
      child: DashboardScaffold(
        currentRoute: 'notifications',
        title: 'إدارة الإشعارات',
        subtitle:
            'أنشئ حملات Push للعملاء وراجع الرسائل السابقة ضمن لوحة عربية مريحة وسريعة.',
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) => FilledButton.icon(
              onPressed: () => context.read<NotificationsCubit>().initialize(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('تحديث'),
            ),
          ),
        ],
        child: BlocConsumer<NotificationsCubit, NotificationsState>(
          listener: (BuildContext context, NotificationsState state) {
            if (state is NotificationsError || state is NotificationsSuccess) {
              final String message = state is NotificationsError
                  ? state.message
                  : (state as NotificationsSuccess).message;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: state is NotificationsError
                      ? ConstVar.dangerColor
                      : ConstVar.successColor,
                ),
              );
            }
          },
          builder: (BuildContext context, NotificationsState state) {
            final NotificationsCubit cubit = context.read<NotificationsCubit>();

            if (state is NotificationsLoading && cubit.notifications.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: <Widget>[
                _NotificationsHeader(cubit: cubit),
                const SizedBox(height: 16),
                Expanded(
                  child: cubit.notifications.isEmpty
                      ? const _EmptyView()
                      : ListView.separated(
                          itemCount: cubit.notifications.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> notification =
                                cubit.notifications[index];
                            return _NotificationCard(
                              notification: notification,
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
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.cubit});

  final NotificationsCubit cubit;

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const MyText(
                  'إرسال إشعارات Push للعملاء',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(height: 8),
                const MyText(
                  'أرسل عروضًا أو إعلانات عامة، وستظهر مباشرة في تطبيق العملاء.',
                  fontSize: 15,
                  color: ConstVar.textMuted,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _InfoChip(
                      icon: Icons.people_alt_rounded,
                      label: 'عدد العملاء',
                      value: '${cubit.customerCount}',
                    ),
                    _InfoChip(
                      icon: Icons.notifications_active_rounded,
                      label: 'الإشعارات الحالية',
                      value: '${cubit.notifications.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 210,
            child: MyButton(
              text: 'إرسال إشعار جديد',
              icon: Icons.send_rounded,
              expand: true,
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
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ConstVar.panelSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ConstVar.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: ConstVar.pColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyText(
                label,
                fontSize: 13,
                color: ConstVar.textFaint,
                fontWeight: FontWeight.w700,
              ),
              MyText(value, fontSize: 18, fontWeight: FontWeight.w900),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.cubit});

  final Map<String, dynamic> notification;
  final NotificationsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final String title = (notification['title'] ?? '').toString();
    final String body = (notification['body'] ?? '').toString();
    final String type = (notification['type'] ?? '').toString();
    final String createdAt = (notification['created_at'] ?? '').toString();
    final int? id = notification['id'] as int?;
    final Map<String, dynamic>? customer =
        notification['customers'] is Map<String, dynamic>
        ? notification['customers'] as Map<String, dynamic>
        : null;

    final _NotificationMeta meta = _metaForType(type);

    return MyCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(meta.icon, color: meta.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MyText(
                        title.isEmpty ? 'إشعار' : title,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: MyText(
                        meta.label,
                        color: meta.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                MyText(
                  body,
                  fontSize: 15,
                  color: ConstVar.textMuted,
                  height: 1.45,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _MetaBadge(
                      icon: Icons.schedule_rounded,
                      text: createdAt.isEmpty
                          ? 'بدون تاريخ'
                          : createdAt.split('T').first,
                    ),
                    if (customer != null && customer['name'] != null)
                      _MetaBadge(
                        icon: Icons.person_rounded,
                        text: customer['name'].toString(),
                      ),
                    if (customer != null &&
                        (customer['phone'] ?? '').toString().isNotEmpty)
                      _MetaBadge(
                        icon: Icons.phone_rounded,
                        text: customer['phone'].toString(),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          MyButton(
            text: 'حذف',
            icon: Icons.delete_outline_rounded,
            variant: MyButtonVariant.danger,
            onPressed: id == null
                ? null
                : () => cubit.deleteNotification(notificationId: id),
          ),
        ],
      ),
    );
  }

  _NotificationMeta _metaForType(String type) {
    switch (type) {
      case 'promotion':
        return const _NotificationMeta(
          label: 'عرض',
          icon: Icons.local_offer_rounded,
          color: Color(0xFFE48F12),
        );
      case 'announcement':
        return const _NotificationMeta(
          label: 'إعلان',
          icon: Icons.campaign_rounded,
          color: ConstVar.infoColor,
        );
      case 'order_status':
        return const _NotificationMeta(
          label: 'حالة طلب',
          icon: Icons.receipt_long_rounded,
          color: ConstVar.successColor,
        );
      default:
        return const _NotificationMeta(
          label: 'إشعار',
          icon: Icons.notifications_rounded,
          color: ConstVar.textMuted,
        );
    }
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ConstVar.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: ConstVar.pColor),
          const SizedBox(width: 6),
          MyText(
            text,
            fontSize: 13,
            color: ConstVar.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return MyCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(
              Icons.notifications_off_rounded,
              size: 54,
              color: ConstVar.textFaint,
            ),
            SizedBox(height: 14),
            MyText(
              'لا توجد إشعارات مرسلة بعد',
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
            SizedBox(height: 8),
            MyText(
              'ابدأ بإرسال أول إشعار للعملاء من الزر العلوي.',
              fontSize: 15,
              color: ConstVar.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationMeta {
  const _NotificationMeta({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
