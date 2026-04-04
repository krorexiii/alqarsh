import 'package:alkhafajdashboard/view/screen/auth/cubit/auth_cubit.dart';
import 'package:alkhafajdashboard/view/screen/auth/loginScreen.dart';
import 'package:alkhafajdashboard/view/widget/myButton.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:alkhafajdashboard/view/widget/myText.dart';
import 'package:alkhafajdashboard/view/widget/myTextFeild.dart';
import 'package:alkhafajdashboard/view/widget/mySnackbar.dart';
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
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
        builder: (context, state) {
          final AuthCubit cubit = context.read<AuthCubit>();
          final bool isLoading = state is AuthLoading;
          final bool otpVerified = cubit.isRecoveryOtpVerified;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 460,
                  child: MyCard(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xffeef2ff),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xffc7d2fe),
                                ),
                              ),
                              child: const Column(
                                children: [
                                  MyText(
                                    'إعادة تعيين كلمة المرور',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 6),
                                  MyText(
                                    'أدخل رمز OTP الذي وصلك بالإيميل، وبعد التحقق عيّن كلمة المرور الجديدة.',
                                    fontSize: 15,
                                    color: Colors.black54,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            MyTextFeild(
                              labelText: 'رمز OTP',
                              icon: Icons.pin_outlined,
                              keyboardType: TextInputType.number,
                              controller: otpController,
                              isReadOnly: otpVerified,
                            ),
                            const SizedBox(height: 12),
                            MyButton(
                              text: otpVerified
                                  ? 'تم التحقق من الرمز'
                                  : isLoading
                                  ? 'جاري التحقق من الرمز...'
                                  : 'تحقق من الرمز',
                              icon: Icons.verified_outlined,
                              expand: true,
                              onPressed: isLoading || otpVerified
                                  ? null
                                  : () {
                                      if (otpController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('يرجى إدخال رمز OTP'),
                                          ),
                                        );
                                        return;
                                      }
                                      cubit.verifyRecoveryOtp(
                                        otpController.text.trim(),
                                      );
                                    },
                            ),
                            const SizedBox(height: 18),
                            MyTextFeild(
                              labelText: 'كلمة المرور الجديدة',
                              obscureText: true,
                              icon: Icons.lock_outline,
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
                                confirmPasswordController.text !=
                                    passwordController.text)
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
                                  ? 'جاري تحديث كلمة المرور...'
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'كلمتا المرور غير متطابقتين',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      cubit.updatePassword(
                                        passwordController.text,
                                      );
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
