# alkhafajdashboard

لوحة تحكم Flutter مرتبطة بـ Supabase وتستخدم Firebase Cloud Messaging من خلال
Supabase Edge Functions الآمنة.

## Push Notifications

تمت إضافة بنية Push كاملة تفصل بين:

- الإشعارات العامة عبر `FCM Topics`
- الإشعارات الفردية عبر `FCM device tokens`

التفاصيل الكاملة وخطوات الإعداد موجودة هنا:

- [docs/push_notifications_setup.md](docs/push_notifications_setup.md)
