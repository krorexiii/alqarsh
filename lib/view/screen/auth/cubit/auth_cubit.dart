import 'package:alkhafajdashboard/data/repository.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final Repository _repository = Repository();

  login(String username, String password) async {
    emit(AuthLoading());
    try {
      AuthResponse result = await _repository.login(
        username: "$username@k.com",
        password: password,
      );
      print(result);
      final SessionUserModel? currentUser = await _repository
          .fetchCurrentSessionUser();
      if (currentUser == null) {
        throw Exception('Missing shop user profile');
      }
      emit(AuthSuccess(currentUser));
    } catch (e) {
      print("Login failed with error: $e");
      emit(AuthError("اسم المستخدم أو كلمة المرور غير صحيحة"));
    }
  }
}
