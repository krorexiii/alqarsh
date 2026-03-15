import 'package:alkhafajdashboard/data/repository.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  final Repository _repository = Repository();
  String? recoveryEmail;
  bool isRecoveryOtpVerified = false;

  String _normalizeEmail(String value) {
    final String trimmed = value.trim();
    if (trimmed.contains('@')) {
      return trimmed;
    }
    return '$trimmed@k.com';
  }

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      AuthResponse result = await _repository.login(
        username: _normalizeEmail(username),
        password: password,
      );
      if (result.user != null && result.session == null) {
        emit(
          AuthInfo(
            'تم إرسال رابط تأكيد إلى بريدك الإلكتروني. يرجى تأكيد الحساب قبل تسجيل الدخول.',
          ),
        );
        return;
      }

      final SessionUserModel? currentUser = await _repository
          .fetchCurrentSessionUser();
      if (currentUser == null) {
        throw Exception('Missing shop user profile');
      }
      emit(AuthSuccess(currentUser));
    } on AuthException catch (e) {
      final String message = e.message.toLowerCase();
      if (message.contains('email not confirmed') ||
          message.contains('email_not_confirmed')) {
        emit(
          AuthInfo(
            'الحساب موجود لكن البريد الإلكتروني غير مؤكد بعد. افتح بريدك وأكمل التأكيد ثم أعد المحاولة.',
          ),
        );
        return;
      }
      emit(AuthError(e.message));
    } catch (e) {
      print('Login error: $e');
      emit(AuthError("اسم المستخدم أو كلمة المرور غير صحيحة"));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(AuthLoading());
    try {
      final String normalizedEmail = _normalizeEmail(email);
      recoveryEmail = normalizedEmail;
      isRecoveryOtpVerified = false;
      await _repository.resetPassword(email: normalizedEmail);
      emit(
        AuthInfo(
          'تم إرسال رمز التحقق إلى بريدك الإلكتروني إذا كان الحساب موجوداً.',
        ),
      );
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('تعذر إرسال رمز إعادة ضبط كلمة المرور حالياً'));
    }
  }

  Future<void> verifyRecoveryOtp(String otp) async {
    emit(AuthLoading());
    try {
      if (recoveryEmail == null) {
        emit(AuthError('يرجى إدخال البريد الإلكتروني وإرسال الرمز أولاً'));
        return;
      }

      await _repository.verifyRecoveryOtp(email: recoveryEmail!, otp: otp);
      isRecoveryOtpVerified = true;
      emit(
        AuthOtpVerified(
          'تم التحقق من الرمز بنجاح، يمكنك الآن تعيين كلمة مرور جديدة.',
        ),
      );
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('الرمز غير صحيح أو انتهت صلاحيته'));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    emit(AuthLoading());
    try {
      if (!isRecoveryOtpVerified) {
        emit(AuthError('يجب التحقق من رمز OTP أولاً'));
        return;
      }

      await _repository.updatePassword(newPassword: newPassword);
      isRecoveryOtpVerified = false;
      recoveryEmail = null;
      emit(
        AuthPasswordUpdated(
          'تم تحديث كلمة المرور بنجاح، يمكنك تسجيل الدخول الآن.',
        ),
      );
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (_) {
      emit(AuthError('تعذر تحديث كلمة المرور حالياً'));
    }
  }
}
