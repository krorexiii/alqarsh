import 'package:alkhafajdashboard/view/screen/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'view/screen/auth/loginScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'view/screen/users/cubit/users_cubit.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://ibwawjjqewuikmmnxqgo.supabase.co',
    anonKey: 'sb_publishable_UDC3-1lmARJgip7zcwAYtg_jE2MMral',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => UsersCubit()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
