import 'dart:async';

import 'package:alkhafajdashboard/view/screen/auth/cubit/auth_cubit.dart';
import 'package:alkhafajdashboard/view/screen/auth/loginScreen.dart';
import 'package:alkhafajdashboard/view/screen/auth/resetPasswordScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'utils/dashboard_theme.dart';
import 'view/screen/users/cubit/users_cubit.dart';

Future<void> main() async {
  await supabase.Supabase.initialize(
    url: 'https://ibwawjjqewuikmmnxqgo.supabase.co',
    anonKey: 'sb_publishable_UDC3-1lmARJgip7zcwAYtg_jE2MMral',
  );

  final supabase.Session? session =
      supabase.Supabase.instance.client.auth.currentSession;
  final bool isRecoverySession =
      session != null && session.user.recoverySentAt != null;

  runApp(MyApp(isRecoverySession: isRecoverySession));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.isRecoverySession});

  final bool isRecoverySession;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<supabase.AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((supabase.AuthState data) {
          if (data.event == supabase.AuthChangeEvent.passwordRecovery) {
            Get.offAll(() => const ResetPasswordScreen());
          }
        });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget homeScreen = widget.isRecoverySession
        ? const ResetPasswordScreen()
        : LoginScreen();

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>(create: (BuildContext context) => AuthCubit()),
        BlocProvider<UsersCubit>(
          create: (BuildContext context) => UsersCubit(),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: DashboardTheme.supportedLocales,
        localizationsDelegates: DashboardTheme.localizationsDelegates,
        theme: DashboardTheme.lightTheme,
        builder: (BuildContext context, Widget? child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: homeScreen,
      ),
    );
  }
}
