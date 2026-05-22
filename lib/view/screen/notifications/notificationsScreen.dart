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
            'إرسال عام عبر Topic وإرسال فردي عبر Token مع سجل موحد للإشعارات داخل المتجر.',
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
    final int broadcastCount = cubit.notifications
        .where((Map<String, dynamic> row) => row['scope'] == 'broadcast')
        .length;
    final int customerCount = cubit.notifications
        .where((Map<String, dynamic> row) => row['scope'] == 'customer')
        .length;

    return MyCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const MyText(
                  'Push معماري وآمن من خلال Supabase',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(height: 8),
                const MyText(
                  'الإشعارات العامة تُرسل عبر Topic، والفردية تُرسل عبر Token محفوظ في Supabase بدون كشف أسرار Firebase داخل Flutter.',
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
                      label: 'العملاء المعروفون',
                      value: '${cubit.customerCount}',
                    ),
                    _InfoChip(
                      icon: Icons.campaign_rounded,
                      label: 'العامة',
                      value: '$broadcastCount',
                    ),
                    _InfoChip(
                      icon: Icons.person_rounded,
                      label: 'الفردية',
                      value: '$customerCount',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 220,
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
    final String scope = (notification['scope'] ?? 'customer').toString();
    final String createdAt = (notification['created_at'] ?? '').toString();
    final int? id = notification['id'] as int?;
    final String? topic = notification['topic']?.toString();
    final bool isSentFcm = notification['is_sent_fcm'] == true;
    final Map<String, dynamic>? customer =
        notification['customers'] is Map<String, dynamic>
        ? notification['customers'] as Map<String, dynamic>
        : null;
    final Map<String, dynamic>? deliveryMeta =
        notification['delivery_meta'] is Map<String, dynamic>
        ? notification['delivery_meta'] as Map<String, dynamic>
        : null;

    final _NotificationMeta meta = _metaForType(type, scope);
    final String sentState = _sentStateLabel(
      scope: scope,
      isSentFcm: isSentFcm,
      deliveryMeta: deliveryMeta,
    );

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
                    _MetaBadge(
                      icon: scope == 'broadcast'
                          ? Icons.public_rounded
                          : Icons.person_rounded,
                      text: scope == 'broadcast' ? 'عام' : 'فردي',
                    ),
                    _MetaBadge(
                      icon: isSentFcm
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      text: sentState,
                    ),
                    if (scope == 'broadcast' &&
                        topic != null &&
                        topic.isNotEmpty)
                      _MetaBadge(icon: Icons.tag_rounded, text: topic),
                    if (customer != null && customer['name'] != null)
                      _MetaBadge(
                        icon: Icons.person_pin_rounded,
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
          if (scope == 'customer')
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

  _NotificationMeta _metaForType(String type, String scope) {
    if (scope == 'broadcast') {
      return const _NotificationMeta(
        label: 'عام / Topic',
        icon: Icons.campaign_rounded,
        color: ConstVar.infoColor,
      );
    }

    switch (type) {
      case 'promotion':
        return const _NotificationMeta(
          label: 'عرض فردي',
          icon: Icons.local_offer_rounded,
          color: Color(0xFFE48F12),
        );
      case 'announcement':
        return const _NotificationMeta(
          label: 'رسالة خاصة',
          icon: Icons.mark_email_read_rounded,
          color: ConstVar.infoColor,
        );
      case 'order_status':
        return const _NotificationMeta(
          label: 'حالة طلب',
          icon: Icons.receipt_long_rounded,
          color: ConstVar.successColor,
        );
      case 'welcome':
        return const _NotificationMeta(
          label: 'ترحيب',
          icon: Icons.waving_hand_rounded,
          color: ConstVar.sColor,
        );
      default:
        return const _NotificationMeta(
          label: 'فردي',
          icon: Icons.notifications_rounded,
          color: ConstVar.textMuted,
        );
    }
  }

  String _sentStateLabel({
    required String scope,
    required bool isSentFcm,
    required Map<String, dynamic>? deliveryMeta,
  }) {
    if (scope == 'broadcast') {
      return isSentFcm ? 'تم عبر Topic' : 'سجل فقط';
    }

    final int successful =
        (deliveryMeta?['successful_tokens'] as num?)?.toInt() ?? 0;
    final int attempted =
        (deliveryMeta?['attempted_tokens'] as num?)?.toInt() ?? 0;

    if (attempted > 0) {
      return 'نجح $successful/$attempted';
    }

    return isSentFcm ? 'تم الإرسال' : 'لا توجد Tokens';
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
              'ابدأ بإرسال إشعار عام عبر Topic أو إشعار فردي عبر Token من الزر العلوي.',
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
