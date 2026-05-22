import 'package:alkhafajdashboard/utils/constVar.dart';
import 'package:alkhafajdashboard/view/screen/notifications/cubit/notifications_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _NotificationAudience { broadcast, customer }

class SendNotificationDialog extends StatefulWidget {
  const SendNotificationDialog({super.key});

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  _NotificationAudience _audience = _NotificationAudience.broadcast;
  String _selectedType = 'promotion';
  int? _selectedCustomerId;
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NotificationsCubit cubit = context.read<NotificationsCubit>();
    final List<Map<String, dynamic>> customers = cubit.customers;
    final bool isBroadcast = _audience == _NotificationAudience.broadcast;
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogWidth = screenSize.width > 760
        ? 660
        : (screenSize.width - 32).clamp(320.0, 500.0);
    final double dialogMaxHeight = screenSize.height * 0.92;
    final bool useCompactLayout = dialogWidth < 560;

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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: dialogMaxHeight,
          ),
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
                                child: Icon(
                                  isBroadcast
                                      ? Icons.campaign_rounded
                                      : Icons.person_pin_circle_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    MyText(
                                      isBroadcast
                                          ? 'إرسال إشعار عام'
                                          : 'إرسال إشعار فردي',
                                      size: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    const SizedBox(height: 6),
                                    MyText(
                                      isBroadcast
                                          ? 'سيُرسل عبر FCM Topic ليصل حتى للمستخدمين غير المسجلين دخول.'
                                          : 'سيُرسل عبر FCM Token للأجهزة المرتبطة بالعميل المحدد بعد حفظ التوكن في Supabase.',
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
                          Flex(
                            direction: useCompactLayout
                                ? Axis.vertical
                                : Axis.horizontal,
                            children: <Widget>[
                              Expanded(
                                flex: useCompactLayout ? 0 : 1,
                                child: _PreviewStat(
                                  label: 'وضع الإرسال',
                                  value: isBroadcast
                                      ? 'عام / Topic'
                                      : 'فردي / Token',
                                ),
                              ),
                              SizedBox(
                                width: useCompactLayout ? 0 : 12,
                                height: useCompactLayout ? 12 : 0,
                              ),
                              Expanded(
                                flex: useCompactLayout ? 0 : 1,
                                child: _PreviewStat(
                                  label: 'النوع الحالي',
                                  value: _typeLabel(_selectedType),
                                ),
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
                            const MyText(
                              'اختر القناة',
                              size: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            const SizedBox(height: 10),
                            Flex(
                              direction: useCompactLayout
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              children: <Widget>[
                                Expanded(
                                  flex: useCompactLayout ? 0 : 1,
                                  child: _ModeCard(
                                    label: 'إشعار عام',
                                    subtitle: 'عبر Topic لكل من يفتح التطبيق',
                                    icon: Icons.campaign_rounded,
                                    color: ConstVar.sColor,
                                    isSelected: isBroadcast,
                                    onTap: () {
                                      setState(() {
                                        _audience =
                                            _NotificationAudience.broadcast;
                                        _selectedType = 'promotion';
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: useCompactLayout ? 0 : 12,
                                  height: useCompactLayout ? 12 : 0,
                                ),
                                Expanded(
                                  flex: useCompactLayout ? 0 : 1,
                                  child: _ModeCard(
                                    label: 'إشعار فردي',
                                    subtitle: 'عبر Token لعميل واحد',
                                    icon: Icons.person_rounded,
                                    color: ConstVar.pColor,
                                    isSelected: !isBroadcast,
                                    onTap: () {
                                      setState(() {
                                        _audience =
                                            _NotificationAudience.customer;
                                        _selectedType = 'announcement';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const MyText(
                              'نوع الإشعار',
                              size: 16,
                              fontWeight: FontWeight.w900,
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _availableTypes(isBroadcast)
                                  .map(
                                    (Map<String, dynamic> option) => _TypePill(
                                      label: option['label'].toString(),
                                      icon: option['icon'] as IconData,
                                      color: option['color'] as Color,
                                      isSelected:
                                          _selectedType ==
                                          option['value'].toString(),
                                      onTap: () => setState(
                                        () => _selectedType = option['value']
                                            .toString(),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            if (!isBroadcast) ...<Widget>[
                              const SizedBox(height: 18),
                              DropdownButtonFormField<int>(
                                initialValue: _selectedCustomerId,
                                decoration: InputDecoration(
                                  labelText: 'العميل المستهدف',
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      margin: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: ConstVar.panelSoft,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.person_search_rounded,
                                        color: ConstVar.pColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 56,
                                    minHeight: 56,
                                  ),
                                ),
                                items: customers
                                    .map(
                                      (Map<String, dynamic> customer) =>
                                          DropdownMenuItem<int>(
                                            value: customer['id'] as int?,
                                            child: Text(
                                              _customerLabel(customer),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (int? value) {
                                  setState(() => _selectedCustomerId = value);
                                },
                                validator: (int? value) {
                                  if (_audience ==
                                          _NotificationAudience.customer &&
                                      value == null) {
                                    return 'اختر العميل أولاً';
                                  }
                                  return null;
                                },
                              ),
                            ],
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
                                  Expanded(
                                    child: MyText(
                                      isBroadcast
                                          ? 'الإشعار العام يُرسل عبر Topic آمن من الـ Edge Function، لذلك يصل للمستخدمين الجدد وغير المسجلين دخول أيضًا.'
                                          : 'الإشعار الفردي يُرسل فقط للأجهزة التي رفعت FCM token بنجاح إلى Supabase بعد تسجيل دخول العميل.',
                                      size: 13,
                                      color: ConstVar.textMuted,
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Flex(
                              direction: useCompactLayout
                                  ? Axis.vertical
                                  : Axis.horizontal,
                              children: <Widget>[
                                Expanded(
                                  flex: useCompactLayout ? 0 : 1,
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
                                SizedBox(
                                  width: useCompactLayout ? 0 : 12,
                                  height: useCompactLayout ? 12 : 0,
                                ),
                                Expanded(
                                  flex: useCompactLayout ? 0 : 2,
                                  child: MyButton(
                                    text: _isSending
                                        ? 'جارٍ الإرسال...'
                                        : isBroadcast
                                        ? 'إرسال الإشعار العام'
                                        : 'إرسال الإشعار الفردي',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _availableTypes(bool isBroadcast) {
    if (isBroadcast) {
      return <Map<String, dynamic>>[
        <String, dynamic>{
          'value': 'promotion',
          'label': 'عرض',
          'icon': Icons.local_offer_rounded,
          'color': ConstVar.sColor,
        },
        <String, dynamic>{
          'value': 'announcement',
          'label': 'إعلان',
          'icon': Icons.campaign_rounded,
          'color': ConstVar.infoColor,
        },
      ];
    }

    return <Map<String, dynamic>>[
      <String, dynamic>{
        'value': 'announcement',
        'label': 'رسالة خاصة',
        'icon': Icons.mark_email_read_rounded,
        'color': ConstVar.infoColor,
      },
      <String, dynamic>{
        'value': 'order_status',
        'label': 'حالة طلب',
        'icon': Icons.receipt_long_rounded,
        'color': ConstVar.successColor,
      },
      <String, dynamic>{
        'value': 'welcome',
        'label': 'ترحيب',
        'icon': Icons.waving_hand_rounded,
        'color': ConstVar.sColor,
      },
    ];
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'promotion':
        return 'عرض';
      case 'announcement':
        return 'إعلان';
      case 'order_status':
        return 'حالة طلب';
      case 'welcome':
        return 'ترحيب';
      default:
        return 'إشعار';
    }
  }

  String _customerLabel(Map<String, dynamic> customer) {
    final String name = (customer['name'] ?? 'عميل').toString();
    final String phone = (customer['phone'] ?? '').toString();
    return phone.isEmpty ? name : '$name - $phone';
  }

  void _send() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSending = true);

    if (_audience == _NotificationAudience.broadcast) {
      context.read<NotificationsCubit>().sendBroadcastNotification(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        type: _selectedType,
      );
      return;
    }

    context.read<NotificationsCubit>().sendNotificationToCustomer(
      customerId: _selectedCustomerId!,
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

class _ModeCard extends StatelessWidget {
  const _ModeCard({
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
            MyText(label, fontSize: 18, fontWeight: FontWeight.w900),
            const SizedBox(height: 6),
            MyText(
              subtitle,
              fontSize: 13,
              color: ConstVar.textMuted,
              height: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : ConstVar.borderColor,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            MyText(
              label,
              fontSize: 14,
              color: isSelected ? color : ConstVar.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}
