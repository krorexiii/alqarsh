import 'package:alkhafajdashboard/data/model/deliveryZoneModel.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'delivery_zones_state.dart';

class DeliveryZonesCubit extends Cubit<DeliveryZonesState> {
  DeliveryZonesCubit() : super(DeliveryZonesInitial());

  final Repository _repository = Repository();

  List<DeliveryZoneModel> deliveryZones = [];
  DeliveryZoneModel? selectedDeliveryZone;

  final TextEditingController cityController = TextEditingController();
  final TextEditingController priceController = TextEditingController(
    text: '0',
  );

  Future<void> fetchDeliveryZones() async {
    emit(DeliveryZonesLoading());
    try {
      final List<dynamic> response = await _repository.fetchDeliveryZones();
      deliveryZones = response.map((item) {
        return DeliveryZoneModel.fromJson(item as Map<String, dynamic>);
      }).toList();

      if (selectedDeliveryZone != null) {
        final int index = deliveryZones.indexWhere(
          (item) => item.id == selectedDeliveryZone!.id,
        );
        selectedDeliveryZone = index >= 0 ? deliveryZones[index] : null;
      }

      if (selectedDeliveryZone == null && deliveryZones.isNotEmpty) {
        selectDeliveryZone(deliveryZones.first, emitState: false);
      } else {
        _syncControllers();
      }

      emit(DeliveryZonesLoaded());
    } catch (e) {
      emit(DeliveryZonesError('فشل في جلب مناطق التوصيل'));
    }
  }

  void selectDeliveryZone(
    DeliveryZoneModel? deliveryZone, {
    bool emitState = true,
  }) {
    selectedDeliveryZone = deliveryZone;
    _syncControllers();
    if (emitState) {
      emit(DeliveryZonesLoaded());
    }
  }

  void startCreatingNewDeliveryZone() {
    selectedDeliveryZone = null;
    cityController.clear();
    priceController.text = '0';
    emit(DeliveryZonesLoaded());
  }

  Future<void> saveDeliveryZone() async {
    final String city = cityController.text.trim();
    final double? price = double.tryParse(priceController.text.trim());

    if (city.isEmpty) {
      emit(DeliveryZonesError('اسم المدينة مطلوب'));
      return;
    }

    if (price == null || price < 0) {
      emit(DeliveryZonesError('سعر التوصيل غير صالح'));
      return;
    }

    emit(DeliveryZonesSaving());

    try {
      if (selectedDeliveryZone == null) {
        final DeliveryZoneModel deliveryZone = DeliveryZoneModel(
          shopId: _repository.supabaseApi.shopId,
          city: city,
          price: price,
        );
        await _repository.addDeliveryZone(deliveryZone: deliveryZone);
        await fetchDeliveryZones();
        startCreatingNewDeliveryZone();
        emit(DeliveryZonesSuccess('تم إنشاء منطقة التوصيل بنجاح'));
        return;
      }

      final DeliveryZoneModel updatedDeliveryZone = selectedDeliveryZone!
          .copyWith(city: city, price: price);

      await _repository.updateDeliveryZone(deliveryZone: updatedDeliveryZone);
      selectedDeliveryZone = updatedDeliveryZone;
      await fetchDeliveryZones();
      emit(DeliveryZonesSuccess('تم تحديث منطقة التوصيل بنجاح'));
    } catch (e) {
      emit(DeliveryZonesError('فشل في حفظ منطقة التوصيل'));
    }
  }

  Future<void> deleteSelectedDeliveryZone() async {
    if (selectedDeliveryZone?.id == null) {
      emit(DeliveryZonesError('اختر منطقة توصيل للحذف أولاً'));
      return;
    }

    emit(DeliveryZonesSaving());
    try {
      await _repository.deleteDeliveryZone(
        deliveryZoneId: selectedDeliveryZone!.id!,
      );
      selectedDeliveryZone = null;
      await fetchDeliveryZones();
      cityController.clear();
      priceController.text = '0';
      emit(DeliveryZonesSuccess('تم حذف منطقة التوصيل'));
    } catch (e) {
      emit(DeliveryZonesError('فشل في حذف منطقة التوصيل'));
    }
  }

  void _syncControllers() {
    cityController.text = selectedDeliveryZone?.city ?? '';
    priceController.text = (selectedDeliveryZone?.price ?? 0).toStringAsFixed(
      2,
    );
  }

  @override
  Future<void> close() {
    cityController.dispose();
    priceController.dispose();
    return super.close();
  }
}
