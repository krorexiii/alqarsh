import 'package:alkhafajdashboard/view/screen/auth/cubit/auth_cubit.dart';
import 'package:alkhafajdashboard/view/screen/auth/loginScreen.dart';
import 'package:alkhafajdashboard/view/widget/auth_shell.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/mySnackbar.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final String? recoveryEmail = context.read<AuthCubit>().recoveryEmail;
    if (recoveryEmail != null) {
      emailController.text = recoveryEmail;
    }
  }

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
        } else if (state is AuthOtpVerified) {
          showMySnackbar(
            context,
            title: 'تم التحقق',
            message: state.message,
            type: SnackbarType.success,
          );
        } else if (state is AuthPasswordUpdated) {
          showMySnackbar(
            context,
            title: 'نجاح',
            message: state.message,
            type: SnackbarType.success,
          );
          Get.offAll(() => LoginScreen());
        }
      },
      builder: (BuildContext context, AuthState state) {
        final AuthCubit cubit = context.read<AuthCubit>();
        final bool isLoading = state is AuthLoading;
        final bool otpVerified = cubit.isRecoveryOtpVerified;
        final bool passwordsMismatch =
            confirmPasswordController.text.isNotEmpty &&
            confirmPasswordController.text != passwordController.text;

        return AuthShell(
          title: 'استعادة الوصول',
          subtitle:
              'أدخل رمز OTP الذي وصلك عبر البريد، أو افتح رابط الاستعادة إذا استخدمت القالب التقليدي في Supabase.',
          badge: 'استعادة الحساب',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const MyText(
                'إعادة تعيين كلمة المرور',
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
              const SizedBox(height: 8),
              const MyText(
                'تحقق من رمز الاستعادة أولًا، ثم أدخل كلمة المرور الجديدة لإكمال العملية.',
                fontSize: 16,
                color: Color(0xFF60746F),
              ),
              const SizedBox(height: 24),
              MyTextFeild(
                labelText: 'البريد الإلكتروني',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                isReadOnly: otpVerified,
              ),
              MyTextFeild(
                labelText: 'رمز OTP',
                obscureText: false,
                icon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
                controller: otpController,
                isReadOnly: otpVerified,
              ),
              const SizedBox(height: 10),
              MyButton(
                text: otpVerified
                    ? 'تم التحقق من الرمز'
                    : isLoading
                    ? 'جارٍ التحقق من الرمز...'
                    : 'تحقق من الرمز',
                icon: Icons.verified_outlined,
                expand: true,
                variant: otpVerified
                    ? MyButtonVariant.secondary
                    : MyButtonVariant.primary,
                onPressed: isLoading || otpVerified
                    ? null
                    : () {
                        final String email = emailController.text.trim();
                        final String otp = otpController.text.trim();

                        if (email.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى إدخال البريد الإلكتروني'),
                            ),
                          );
                          return;
                        }

                        if (otp.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى إدخال رمز OTP')),
                          );
                          return;
                        }

                        cubit.recoveryEmail = email;
                        cubit.verifyRecoveryOtp(otp);
                      },
              ),
              const SizedBox(height: 20),
              MyTextFeild(
                labelText: 'كلمة المرور الجديدة',
                obscureText: true,
                icon: Icons.lock_outline_rounded,
                controller: passwordController,
                isReadOnly: !otpVerified,
                onChanged: (_) => setState(() {}),
              ),
              MyTextFeild(
                labelText: 'تأكيد كلمة المرور',
                obscureText: true,
                icon: Icons.lock_reset_outlined,
                controller: confirmPasswordController,
                isReadOnly: !otpVerified,
                onChanged: (_) => setState(() {}),
              ),
              if (passwordController.text.isNotEmpty &&
                  passwordController.text.length < 8)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كلمة المرور يجب أن تكون 8 أحرف على الأقل',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              if (passwordsMismatch)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كلمتا المرور غير متطابقتين',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              MyButton(
                text: isLoading
                    ? 'جارٍ تحديث كلمة المرور...'
                    : 'تحديث كلمة المرور',
                icon: isLoading
                    ? Icons.hourglass_top_rounded
                    : Icons.save_outlined,
                expand: true,
                onPressed:
                    isLoading ||
                        !otpVerified ||
                        passwordsMismatch ||
                        passwordController.text.length < 8
                    ? null
                    : () {
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('كلمتا المرور غير متطابقتين'),
                            ),
                          );
                          return;
                        }
                        cubit.updatePassword(passwordController.text);
                      },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
