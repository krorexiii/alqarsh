import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/notifications/cubit/notifications_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendNotificationDialog extends StatefulWidget {
  const SendNotificationDialog({super.key});

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  String _selectedType = 'promotion';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dialogWidth = MediaQuery.of(context).size.width > 760
        ? 620
        : 460;

    return BlocListener<NotificationsCubit, NotificationsState>(
      listener: (BuildContext context, NotificationsState state) {
        if (state is NotificationsSuccess) {
          Navigator.of(context).pop(true);
        }
        if (state is NotificationsError) {
          setState(() => _isSending = false);
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        backgroundColor: Colors.transparent,
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
            boxShadow: ConstVar.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    decoration: const BoxDecoration(
                      gradient: ConstVar.brandGradient,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const <Widget>[
                                  MyText(
                                    'إرسال إشعار جماعي',
                                    size: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  SizedBox(height: 6),
                                  MyText(
                                    'رسالة موحّدة لجميع عملاء التطبيق مع نوع إشعار واضح ومظهر عربي أنيق.',
                                    size: 13,
                                    color: Colors.white70,
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
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _PreviewStat(
                                label: 'النوع الحالي',
                                value: _selectedType == 'promotion'
                                    ? 'عرض'
                                    : 'إعلان',
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: _PreviewStat(
                                label: 'قناة الإرسال',
                                value: 'Push',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const MyText(
                          'اختر نوع الإشعار',
                          size: 16,
                          fontWeight: FontWeight.w900,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _TypeCard(
                                label: 'عرض',
                                subtitle: 'مناسب للعروض والخصومات',
                                icon: Icons.local_offer_rounded,
                                color: ConstVar.sColor,
                                isSelected: _selectedType == 'promotion',
                                onTap: () =>
                                    setState(() => _selectedType = 'promotion'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _TypeCard(
                                label: 'إعلان',
                                subtitle: 'للتحديثات العامة والتنبيهات',
                                icon: Icons.campaign_rounded,
                                color: ConstVar.pColor,
                                isSelected: _selectedType == 'announcement',
                                onTap: () => setState(
                                  () => _selectedType = 'announcement',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        MyTextFeild(
                          controller: _titleController,
                          labelText: 'عنوان الإشعار',
                          icon: Icons.title_rounded,
                        ),
                        MyTextFeild(
                          controller: _bodyController,
                          labelText: 'محتوى الإشعار',
                          icon: Icons.message_outlined,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ConstVar.panelSoft,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: ConstVar.borderColor),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.info_outline_rounded,
                                color: ConstVar.pColor,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: MyText(
                                  'سيصل الإشعار فوراً إلى جميع العملاء. اختر عنواناً واضحاً ونصاً مختصراً يناسب شاشة الهاتف.',
                                  size: 13,
                                  color: ConstVar.textMuted,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: MyButton(
                                text: 'إلغاء',
                                icon: Icons.close_rounded,
                                variant: MyButtonVariant.ghost,
                                expand: true,
                                onPressed: _isSending
                                    ? null
                                    : () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: MyButton(
                                text: _isSending
                                    ? 'جارٍ الإرسال...'
                                    : 'إرسال الإشعار',
                                icon: _isSending
                                    ? Icons.hourglass_top_rounded
                                    : Icons.send_rounded,
                                expand: true,
                                onPressed: _isSending ? null : _send,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _send() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);

    context.read<NotificationsCubit>().sendBroadcastNotification(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      type: _selectedType,
    );
  }
}

class _PreviewStat extends StatelessWidget {
  const _PreviewStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MyText(
            label,
            size: 12,
            color: Colors.white.withValues(alpha: 0.78),
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          MyText(
            value,
            size: 18,
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : ConstVar.borderColor,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 14),
            MyText(
              label,
              size: 16,
              fontWeight: FontWeight.w900,
              color: ConstVar.textPrimary,
            ),
            const SizedBox(height: 4),
            MyText(subtitle, size: 12, color: ConstVar.textMuted, height: 1.5),
          ],
        ),
      ),
    );
  }
}
