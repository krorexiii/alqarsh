import 'package:alkhafajdashboard/data/model/discountCodeModel.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'discount_codes_state.dart';

class DiscountCodesCubit extends Cubit<DiscountCodesState> {
  DiscountCodesCubit() : super(DiscountCodesInitial());

  final Repository _repository = Repository();

  List<DiscountCodeModel> discountCodes = <DiscountCodeModel>[];
  DiscountCodeModel? selectedDiscountCode;
  SessionUserModel? currentUser;

  final TextEditingController codeController = TextEditingController();
  final TextEditingController discountPercentController = TextEditingController(
    text: '10',
  );
  final TextEditingController discountAmountController =
      TextEditingController();
  final TextEditingController minPurchaseController = TextEditingController(
    text: '0',
  );
  final TextEditingController maxDiscountController = TextEditingController();
  final TextEditingController limitCountController = TextEditingController();

  String selectedDiscountType = 'percent';
  bool isActive = true;
  DateTime expiryDate = DateTime.now().add(const Duration(days: 30));

  bool get isAdmin => currentUser?.isAdmin ?? false;

  Future<void> fetchDiscountCodes() async {
    emit(DiscountCodesLoading());
    try {
      currentUser = await _repository.fetchCurrentSessionUser();
      final List<dynamic> response = await _repository.fetchDiscountCodes();
      discountCodes = response
          .whereType<Map<String, dynamic>>()
          .map(DiscountCodeModel.fromJson)
          .toList();

      if (selectedDiscountCode != null) {
        final int index = discountCodes.indexWhere(
          (item) => item.id == selectedDiscountCode!.id,
        );
        selectedDiscountCode = index >= 0 ? discountCodes[index] : null;
      }

      if (selectedDiscountCode == null && discountCodes.isNotEmpty) {
        selectDiscountCode(discountCodes.first, emitState: false);
      } else {
        _syncControllers();
      }

      emit(DiscountCodesLoaded());
    } catch (_) {
      emit(DiscountCodesError('فشل في جلب أكواد الخصم'));
    }
  }

  void selectDiscountCode(
    DiscountCodeModel? discountCode, {
    bool emitState = true,
  }) {
    selectedDiscountCode = discountCode;
    _syncControllers();
    if (emitState) {
      emit(DiscountCodesLoaded());
    }
  }

  void startCreatingNewDiscountCode() {
    selectedDiscountCode = null;
    codeController.clear();
    discountPercentController.text = '10';
    discountAmountController.clear();
    minPurchaseController.text = '0';
    maxDiscountController.clear();
    limitCountController.clear();
    selectedDiscountType = 'percent';
    isActive = true;
    expiryDate = DateTime.now().add(const Duration(days: 30));
    emit(DiscountCodesLoaded());
  }

  void setDiscountType(String? value) {
    if (value == null) {
      return;
    }
    selectedDiscountType = value;
    emit(DiscountCodesLoaded());
  }

  void setExpiryDate(DateTime value) {
    expiryDate = value;
    emit(DiscountCodesLoaded());
  }

  void setIsActive(bool value) {
    isActive = value;
    emit(DiscountCodesLoaded());
  }

  void notifyFormChanged() {
    emit(DiscountCodesLoaded());
  }

  Future<void> saveDiscountCode() async {
    if (!isAdmin) {
      emit(
        DiscountCodesError(
          'ليس لديك صلاحية لإنشاء أو تعديل البرومو كود. يرجى تسجيل الدخول بحساب أدمن.',
        ),
      );
      return;
    }

    final String code = codeController.text.trim().toUpperCase();
    final double? minPurchase = double.tryParse(
      minPurchaseController.text.trim(),
    );
    final double? maxDiscount = maxDiscountController.text.trim().isEmpty
        ? null
        : double.tryParse(maxDiscountController.text.trim());
    final int? limitCount = limitCountController.text.trim().isEmpty
        ? null
        : int.tryParse(limitCountController.text.trim());
    final int? discountPercent = discountPercentController.text.trim().isEmpty
        ? null
        : int.tryParse(discountPercentController.text.trim());
    final double? discountAmount = discountAmountController.text.trim().isEmpty
        ? null
        : double.tryParse(discountAmountController.text.trim());

    if (code.isEmpty) {
      emit(DiscountCodesError('رمز الخصم مطلوب'));
      return;
    }

    if (minPurchase == null || minPurchase < 0) {
      emit(DiscountCodesError('الحد الأدنى للشراء غير صالح'));
      return;
    }

    if (selectedDiscountType == 'percent') {
      if (discountPercent == null ||
          discountPercent < 1 ||
          discountPercent > 95) {
        emit(DiscountCodesError('نسبة الخصم يجب أن تكون بين 1 و95'));
        return;
      }
    } else {
      if (discountAmount == null || discountAmount <= 0) {
        emit(DiscountCodesError('قيمة الخصم يجب أن تكون أكبر من صفر'));
        return;
      }
    }

    if (maxDiscount != null && maxDiscount <= 0) {
      emit(DiscountCodesError('الحد الأعلى للخصم غير صالح'));
      return;
    }

    if (limitCount != null && limitCount <= 0) {
      emit(DiscountCodesError('عدد مرات الاستخدام يجب أن يكون أكبر من صفر'));
      return;
    }

    emit(DiscountCodesSaving());

    try {
      final DiscountCodeModel draft = DiscountCodeModel(
        id: selectedDiscountCode?.id,
        shopId: _repository.supabaseApi.shopId,
        code: code,
        discountType: selectedDiscountType,
        discountPercent: selectedDiscountType == 'percent'
            ? discountPercent
            : null,
        discountAmount: selectedDiscountType == 'amount'
            ? discountAmount
            : null,
        minPurchaseAmount: minPurchase,
        maxDiscountAmount: maxDiscount,
        limitCount: limitCount,
        usedCount: selectedDiscountCode?.usedCount ?? 0,
        expiryDate: expiryDate,
        isActive: isActive,
      );

      if (selectedDiscountCode == null) {
        await _repository.addDiscountCode(discountCode: draft);
        await fetchDiscountCodes();
        startCreatingNewDiscountCode();
        emit(DiscountCodesSuccess('تم إنشاء البرومو كود بنجاح'));
        return;
      }

      await _repository.updateDiscountCode(discountCode: draft);
      selectedDiscountCode = draft;
      await fetchDiscountCodes();
      emit(DiscountCodesSuccess('تم تحديث البرومو كود بنجاح'));
    } catch (error) {
      emit(DiscountCodesError(_mapSaveError(error)));
    }
  }

  Future<void> deleteSelectedDiscountCode() async {
    if (!isAdmin) {
      emit(
        DiscountCodesError(
          'ليس لديك صلاحية لحذف البرومو كود. يرجى تسجيل الدخول بحساب أدمن.',
        ),
      );
      return;
    }

    if (selectedDiscountCode?.id == null) {
      emit(DiscountCodesError('اختر برومو كود للحذف أولًا'));
      return;
    }

    emit(DiscountCodesSaving());
    try {
      await _repository.deleteDiscountCode(
        discountCodeId: selectedDiscountCode!.id!,
      );
      selectedDiscountCode = null;
      await fetchDiscountCodes();
      startCreatingNewDiscountCode();
      emit(DiscountCodesSuccess('تم حذف البرومو كود'));
    } catch (_) {
      emit(DiscountCodesError('فشل في حذف البرومو كود'));
    }
  }

  String _mapSaveError(Object error) {
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return 'يوجد برومو كود بنفس الاسم بالفعل';
      }

      if (error.code == '42501' ||
          error.message.toLowerCase().contains('row-level security')) {
        return 'قاعدة البيانات رفضت العملية بسبب الصلاحيات. استخدم حساب أدمن لإدارة البرومو كود.';
      }

      final String details = error.message.trim();
      if (details.isNotEmpty) {
        return 'فشل في حفظ البرومو كود: $details';
      }
    }

    final String fallback = error.toString().trim();
    if (fallback.isNotEmpty) {
      return 'فشل في حفظ البرومو كود: $fallback';
    }

    return 'فشل في حفظ البرومو كود';
  }

  void _syncControllers() {
    codeController.text = selectedDiscountCode?.normalizedCode ?? '';
    discountPercentController.text =
        (selectedDiscountCode?.discountPercent ?? 10).toString();
    discountAmountController.text =
        selectedDiscountCode?.discountAmount?.toStringAsFixed(0) ?? '';
    minPurchaseController.text = (selectedDiscountCode?.minPurchaseAmount ?? 0)
        .toStringAsFixed(0);
    maxDiscountController.text =
        selectedDiscountCode?.maxDiscountAmount?.toStringAsFixed(0) ?? '';
    limitCountController.text =
        selectedDiscountCode?.limitCount?.toString() ?? '';
    selectedDiscountType = selectedDiscountCode?.discountType ?? 'percent';
    isActive = selectedDiscountCode?.isActive ?? true;
    expiryDate =
        selectedDiscountCode?.expiryDate ??
        DateTime.now().add(const Duration(days: 30));
  }

  @override
  Future<void> close() {
    codeController.dispose();
    discountPercentController.dispose();
    discountAmountController.dispose();
    minPurchaseController.dispose();
    maxDiscountController.dispose();
    limitCountController.dispose();
    return super.close();
  }
}
