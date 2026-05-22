# Push Notifications Setup

## ما الذي تم تنفيذه داخل هذا المستودع

- إنشاء جدول `broadcast_notifications` لحفظ الإشعارات العامة مرة واحدة بدل تكرارها لكل عميل.
- الإبقاء على `customer_notifications` للإشعارات الفردية فقط مع توسيعه بحقـول تتبع الإرسال.
- توسيع `fcm_tokens` ليتضمن `device_id`, `app_version`, `last_seen_at`, `topic_name`, `topic_subscribed_at`.
- إضافة RLS وسياسات عميل تتيح:
  - قراءة العميل لإشعاراته الفردية.
  - تحديث حالة القراءة.
  - حفظ وتحديث وتعطيل FCM token الخاص به.
- إضافة دوال SQL/RPC جاهزة لتطبيق العميل:
  - `build_shop_broadcast_topic`
  - `get_public_broadcast_notifications`
  - `get_my_notification_feed`
  - `upsert_my_fcm_token`
  - `deactivate_my_fcm_token`
- إضافة Edge Function آمنة: `send-notification`
  - الداشبورد يستدعيها بدل أي Firebase key داخل Flutter.
  - الإرسال العام يتم إلى Topic.
  - الإرسال الفردي يتم إلى Tokens العميل الفعالة.
  - يتم حفظ سجل الإشعار داخل Supabase قبل/أثناء الإرسال.
  - يتم تعطيل التوكنات غير الصالحة تلقائيًا عند اكتشاف `UNREGISTERED`.
- تحديث شاشة الإشعارات في الداشبورد لتدعم:
  - إشعار عام عبر Topic
  - إشعار فردي لعميل محدد
  - سجل موحد يوضح نوع الإشعار وحالة الإرسال
- ربط تحديثات حالة الطلب في الداشبورد بإرسال إشعار فردي تلقائي للعميل.

## ملفات التنفيذ

- Migration:
  - `supabase/migrations/20260428_add_push_notifications_architecture.sql`
- Edge Function:
  - `supabase/functions/send-notification/index.ts`
- ربط الداشبورد:
  - `lib/data/api/supabaseApi.dart`
  - `lib/view/screen/notifications/...`
  - `lib/view/screen/orders/cubit/orders_cubit.dart`

## ما الذي يجب عليك فعله في Supabase

1. شغّل الـ migration الجديدة.
2. انشر الـ Edge Function:

```bash
supabase functions deploy send-notification
```

3. أضف secrets المطلوبة:

```bash
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON='{"type":"service_account","project_id":"servicing-as",...}'
```

ملاحظة:
- لا تضع ملف الـ service account داخل Flutter app أو dashboard.
- استخدم JSON كامل لحساب الخدمة الذي يملك صلاحية Firebase Cloud Messaging.

## ما الذي يجب عليك فعله في Firebase Console

1. تأكد أن المشروع الصحيح هو `servicing-as`.
2. فعّل أو راجع `Firebase Cloud Messaging API` على مشروع Google Cloud المرتبط.
3. أنشئ Service Account مخصصًا للإرسال من السيرفر.
4. نزّل JSON الخاص به.
5. خزّنه فقط داخل `Supabase secrets` باسم `FIREBASE_SERVICE_ACCOUNT_JSON`.
6. أضف تطبيقات Android/iOS الحقيقية للعميل داخل Firebase إذا لم تكن مضافة بعد.
7. إن كان لديك iOS:
  - ارفع `APNs Authentication Key` أو شهادات APNs داخل Firebase Console.

مراجع رسمية:
- FCM HTTP v1: https://firebase.google.com/docs/cloud-messaging/auth-server
- Topic Messaging: https://firebase.google.com/docs/cloud-messaging/send-topic-messages

## ما الذي يجب عليك فعله في Android

1. أضف `google-services.json` لتطبيق العميل.
2. تأكد من إعداد `firebase_messaging`.
3. أنشئ Notification Channel باسم:

```text
general_notifications
```

4. فعّل استقبال إشعارات foreground/background بالطريقة المعتادة في FlutterFire.

## ما الذي يجب عليك فعله في iOS / Xcode

1. أضف `GoogleService-Info.plist` لتطبيق العميل.
2. فعّل:
  - `Push Notifications`
  - `Background Modes > Remote notifications`
3. تأكد من ربط APNs مع Firebase.
4. اطلب صلاحيات الإشعارات من التطبيق عند التشغيل الأول.

## منطق الـ Topic العام

اسم الـ Topic العام للمتجر يُبنى بهذه الصيغة:

```text
shop_<shop_id_sanitized>_all
```

وللمتجر الحالي يمكن جلبه أيضًا من الدالة:

```sql
select public.build_shop_broadcast_topic('550e8400-e29b-41d4-a716-446655440001');
```

## ما الذي يجب على تطبيق العميل فعله

بما أن تطبيق العميل غير موجود داخل هذا المستودع، فهذا هو العقد المطلوب تنفيذه فيه.

### 1. الاشتراك التلقائي في الـ Topic العام

عند كل فتح للتطبيق، حتى قبل تسجيل الدخول:

```dart
await FirebaseMessaging.instance.subscribeToTopic(
  'shop_550e8400-e29b-41d4-a716-446655440001_all',
);
```

الأفضل أن تبني الاسم برمجيًا بنفس الصيغة أو تجلبه من `build_shop_broadcast_topic`.

### 2. حفظ FCM token بعد تسجيل دخول العميل

بعد تسجيل الدخول ووجود `auth user` مرتبط بجدول `customers`:

```dart
await supabase.rpc(
  'upsert_my_fcm_token',
  params: {
    'p_token': fcmToken,
    'p_platform': 'android', // أو ios / web
    'p_device_id': deviceId,
    'p_app_version': appVersion,
    'p_topic_name': 'shop_550e8400-e29b-41d4-a716-446655440001_all',
  },
);
```

### 3. تحديث التوكن عند تغيّره

اربط `FirebaseMessaging.onTokenRefresh` مع نفس RPC أعلاه.

### 4. تعطيل التوكن عند تسجيل الخروج

```dart
await supabase.rpc(
  'deactivate_my_fcm_token',
  params: {'p_token': fcmToken},
);
```

### 5. مزامنة الإشعارات داخل التطبيق

- للضيوف أو قبل تسجيل الدخول:

```dart
await supabase.rpc(
  'get_public_broadcast_notifications',
  params: {
    'p_shop_id': '550e8400-e29b-41d4-a716-446655440001',
    'p_limit': 50,
  },
);
```

- للعملاء المسجلين دخول:

```dart
await supabase.rpc(
  'get_my_notification_feed',
  params: {'p_limit': 100},
);
```

## كيف يرسل الداشبورد إشعارًا عامًا

من شاشة الإشعارات في الداشبورد:

1. اختر `إشعار عام`.
2. اختر النوع `عرض` أو `إعلان`.
3. أرسل.

ما يحدث خلفيًا:

1. Flutter dashboard يستدعي `send-notification`.
2. Edge Function تتحقق من المستخدم وصلاحياته.
3. يتم حفظ صف في `broadcast_notifications`.
4. يتم إرسال Push واحدة إلى Topic العام للمتجر.

## كيف يرسل الداشبورد إشعارًا فرديًا

من شاشة الإشعارات في الداشبورد:

1. اختر `إشعار فردي`.
2. اختر العميل.
3. أرسل.

ما يحدث خلفيًا:

1. Flutter dashboard يستدعي `send-notification`.
2. Edge Function تتحقق من المستخدم والعميل.
3. يتم حفظ صف في `customer_notifications`.
4. يتم جلب كل `fcm_tokens` الفعالة لذلك العميل.
5. يتم إرسال Push لكل Token.

## الإشعار الفردي التلقائي عند تغيّر حالة الطلب

عند:

- تحويل الطلب إلى `confirmed`
- تحديث الحالة إلى `preparing`
- `shipped`
- `delivered`
- `cancelled`

يقوم الداشبورد تلقائيًا بإنشاء إشعار فردي وإرساله للعميل عبر نفس الـ Edge Function.

## خطوات التحقق والاختبار

### اختبار الإشعار العام

1. افتح تطبيق العميل على جهاز غير مسجل دخول.
2. اشترك في الـ Topic العام.
3. أرسل إشعارًا عامًا من الداشبورد.
4. تأكد من وصوله على الجهاز.
5. تأكد من ظهور سجل في `broadcast_notifications`.

### اختبار الإشعار الفردي

1. سجّل دخول عميل حقيقي.
2. نفّذ `upsert_my_fcm_token`.
3. تحقق من ظهور الصف في `fcm_tokens`.
4. أرسل إشعارًا فرديًا من الداشبورد.
5. تأكد من:
  - وصول الإشعار
  - حفظ سجل في `customer_notifications`
  - تعبئة `delivery_meta`

### اختبار إشعار حالة الطلب

1. غيّر حالة طلب من الداشبورد.
2. راقب وصول Push للعميل.
3. تأكد من أن `type = order_status`.

## ملاحظات معمارية مهمة

- الإشعار العام لا يعتمد على التوكنات الفردية.
- الإشعار الفردي لا يعتمد على Topic.
- مفاتيح Firebase بقيت خارج Flutter بالكامل.
- Edge Function هي نقطة الإرسال الوحيدة.
- `broadcast_notifications` فصلت السجل العام عن الفردي بشكل صحيح وقابل للتوسع.
