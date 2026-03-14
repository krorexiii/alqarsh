import 'package:alkhafajdashboard/view/screen/auth/cubit/auth_cubit.dart';
import 'package:alkhafajdashboard/view/widget/myCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:get/get.dart';
import '../../widget/myButton.dart';
import '../../widget/myText.dart';
import '../../widget/myTextFeild.dart';
import '../orders/ordersScreen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            final snackBar = SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              content: AwesomeSnackbarContent(
                title: 'خطأ',
                message: state.message,
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          } else if (state is AuthSuccess) {
            final snackBar = SnackBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              behavior: SnackBarBehavior.floating,
              content: const AwesomeSnackbarContent(
                title: 'نجاح',
                message: 'تم تسجيل الدخول بنجاح',
                contentType: ContentType.success,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
            Get.offAll(() => const OrdersScreen());
          }
        },
        builder: (context, state) {
          final cubit = BlocProvider.of<AuthCubit>(context);
          final bool isLoading = state is AuthLoading;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 420,
                  child: MyCard(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xffeef2ff),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xffc7d2fe),
                              ),
                            ),
                            child: Column(
                              children: const [
                                MyText(
                                  'تسجيل الدخول',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 6),
                                MyText(
                                  'أدخل بياناتك للوصول إلى لوحة التحكم',
                                  fontSize: 16,
                                  color: Colors.black54,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          MyTextFeild(
                            labelText: "اسم المستخدم",
                            icon: Icons.person_outline,
                            controller: usernameController,
                          ),
                          MyTextFeild(
                            labelText: "كلمة المرور",
                            obscureText: true,
                            icon: Icons.lock_outline,
                            controller: passwordController,
                          ),

                          const SizedBox(height: 22),
                          MyButton(
                            text: isLoading
                                ? "جاري تسجيل الدخول..."
                                : "تسجيل الدخول",
                            icon: isLoading
                                ? Icons.hourglass_top_rounded
                                : Icons.login_rounded,
                            expand: true,
                            onPressed: isLoading
                                ? null
                                : () {
                                    cubit.login(
                                      usernameController.text.trim(),
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
          );
        },
      ),
    );
  }
}
