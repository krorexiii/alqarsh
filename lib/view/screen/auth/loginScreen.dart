import 'package:alkhafajdashboard/view/screen/auth/cubit/auth_cubit.dart';
import 'package:alkhafajdashboard/view/screen/auth/resetPasswordScreen.dart';
import 'package:alkhafajdashboard/view/screen/orders/ordersScreen.dart';
import 'package:alkhafajdashboard/view/widget/auth_shell.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/mySnackbar.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthError) {
          showMySnackbar(
            context,
            title: 'خطأ',
            message: state.message,
            type: SnackbarType.error,
          );
        } else if (state is AuthInfo) {
          showMySnackbar(
            context,
            title: 'معلومة',
            message: state.message,
            type: SnackbarType.info,
          );
          if (state.message.contains('استعادة كلمة المرور')) {
            Get.to(() => const ResetPasswordScreen());
          }
        } else if (state is AuthSuccess) {
          showMySnackbar(
            context,
            title: 'نجاح',
            message: 'تم تسجيل الدخول بنجاح',
            type: SnackbarType.success,
          );
          Get.offAll(() => const OrdersScreen());
        }
      },
      builder: (BuildContext context, AuthState state) {
        final AuthCubit cubit = context.read<AuthCubit>();
        final bool isLoading = state is AuthLoading;

        return AuthShell(
          title: 'دخول الإدارة',
          subtitle:
              'سجّل الدخول للوصول إلى لوحة تحكم المتجر وإدارة الطلبات والمنتجات والمحتوى من تجربة عربية احترافية.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const MyText(
                'مرحبًا بعودتك',
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
              const SizedBox(height: 8),
              const MyText(
                'أدخل بياناتك للمتابعة إلى لوحة الإدارة.',
                fontSize: 16,
                color: Color(0xFF60746F),
              ),
              const SizedBox(height: 24),
              MyTextFeild(
                labelText: 'البريد الإلكتروني أو اسم المستخدم',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
              MyTextFeild(
                labelText: 'كلمة المرور',
                obscureText: true,
                icon: Icons.lock_outline_rounded,
                controller: passwordController,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _showResetPasswordDialog(
                          context,
                          cubit,
                          emailController.text.trim(),
                        ),
                  icon: const Icon(Icons.key_rounded, size: 18),
                  label: const Text('نسيت كلمة المرور؟'),
                ),
              ),
              const SizedBox(height: 18),
              MyButton(
                text: isLoading ? 'جارٍ تسجيل الدخول...' : 'تسجيل الدخول',
                icon: isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.login_rounded,
                expand: true,
                onPressed: isLoading
                    ? null
                    : () {
                        cubit.login(
                          emailController.text.trim(),
                          passwordController.text,
                        );
                      },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBF8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFD7E2DB)),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.security_rounded, color: Color(0xFF0B6E69)),
                    SizedBox(width: 10),
                    Expanded(
                      child: MyText(
                        'الدخول مخصص لفريق الإدارة فقط، وجميع العمليات تتم ضمن جلسة آمنة.',
                        fontSize: 14,
                        color: Color(0xFF60746F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showResetPasswordDialog(
    BuildContext context,
    AuthCubit cubit,
    String initialEmail,
  ) async {
    final TextEditingController resetController = TextEditingController(
      text: initialEmail,
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('إعادة ضبط كلمة المرور'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'أدخل بريد الموظف الإلكتروني، وسيتم إرسال رمز OTP أو رابط الاستعادة إليه حسب إعدادات Supabase.',
                ),
                const SizedBox(height: 12),
                MyTextFeild(
                  labelText: 'البريد الإلكتروني',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: resetController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                cubit.sendPasswordReset(resetController.text.trim());
                Navigator.of(dialogContext).pop();
              },
              child: const Text('إرسال الرمز'),
            ),
          ],
        );
      },
    );
  }
}
