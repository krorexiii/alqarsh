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
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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

        return AuthShell(
          title: 'استعادة الوصول',
          subtitle:
              'تحقق من رمز OTP أولًا، ثم عيّن كلمة مرور جديدة للوصول مجددًا إلى لوحة الإدارة.',
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
                'أدخل رمز OTP الذي وصلك بالبريد، وبعد التحقق حدّد كلمة المرور الجديدة.',
                fontSize: 16,
                color: Color(0xFF60746F),
              ),
              const SizedBox(height: 24),
              MyTextFeild(
                labelText: 'رمز OTP',
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
                        if (otpController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى إدخال رمز OTP')),
                          );
                          return;
                        }
                        cubit.verifyRecoveryOtp(otpController.text.trim());
                      },
              ),
              const SizedBox(height: 20),
              MyTextFeild(
                labelText: 'كلمة المرور الجديدة',
                obscureText: true,
                icon: Icons.lock_outline_rounded,
                controller: passwordController,
                isReadOnly: !otpVerified,
              ),
              MyTextFeild(
                labelText: 'تأكيد كلمة المرور',
                obscureText: true,
                icon: Icons.lock_reset_outlined,
                controller: confirmPasswordController,
                isReadOnly: !otpVerified,
                onChanged: (_) => setState(() {}),
              ),
              if (confirmPasswordController.text.isNotEmpty &&
                  confirmPasswordController.text != passwordController.text)
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
                onPressed: isLoading || !otpVerified
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
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
