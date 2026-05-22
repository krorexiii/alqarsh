import 'package:alkhafajdashboard/data/model/locationModel.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'store_locations_state.dart';

class StoreLocationsCubit extends Cubit<StoreLocationsState> {
  StoreLocationsCubit() : super(StoreLocationsInitial());

  final Repository _repository = Repository();

  List<LocationModel> locations = <LocationModel>[];
  LocationModel? selectedLocation;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationNameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  Future<void> fetchStoreLocations() async {
    emit(StoreLocationsLoading());

    try {
      final List<dynamic> response = await _repository.fetchStoreLocations();
      locations = response
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();

      if (selectedLocation != null) {
        final int index = locations.indexWhere(
          (item) => item.id == selectedLocation!.id,
        );
        selectedLocation = index >= 0 ? locations[index] : null;
      }

      if (selectedLocation == null && locations.isNotEmpty) {
        selectLocation(locations.first, emitState: false);
      } else {
        _syncControllers();
      }

      emit(StoreLocationsLoaded());
    } catch (e) {
      emit(StoreLocationsError('فشل في جلب مواقع المتجر'));
    }
  }

  void selectLocation(LocationModel? location, {bool emitState = true}) {
    selectedLocation = location;
    _syncControllers();

    if (emitState) {
      emit(StoreLocationsLoaded());
    }
  }

  void startCreatingNewLocation() {
    selectedLocation = null;
    nameController.clear();
    locationNameController.clear();
    latitudeController.clear();
    longitudeController.clear();
    emit(StoreLocationsLoaded());
  }

  void notifyDraftChanged() {
    if (state is StoreLocationsSaving) {
      return;
    }
    emit(StoreLocationsLoaded());
  }

  Future<void> saveLocation() async {
    final String name = nameController.text.trim();
    final String locationName = locationNameController.text.trim();
    final double? latitude = double.tryParse(latitudeController.text.trim());
    final double? longitude = double.tryParse(longitudeController.text.trim());

    if (name.isEmpty) {
      emit(StoreLocationsError('اسم الموقع مطلوب'));
      return;
    }

    if (locationName.isEmpty) {
      emit(StoreLocationsError('وصف الموقع أو العنوان المختصر مطلوب'));
      return;
    }

    if (latitude == null || latitude < -90 || latitude > 90) {
      emit(StoreLocationsError('خط العرض غير صالح'));
      return;
    }

    if (longitude == null || longitude < -180 || longitude > 180) {
      emit(StoreLocationsError('خط الطول غير صالح'));
      return;
    }

    emit(StoreLocationsSaving());

    try {
      if (selectedLocation == null) {
        await _repository.addStoreLocation(
          name: name,
          locationName: locationName,
          lX: latitude,
          lY: longitude,
        );
        await fetchStoreLocations();
        startCreatingNewLocation();
        emit(StoreLocationsSuccess('تم إنشاء موقع المتجر بنجاح'));
        return;
      }

      await _repository.updateStoreLocation(
        id: selectedLocation!.id,
        name: name,
        locationName: locationName,
        lX: latitude,
        lY: longitude,
      );
      await fetchStoreLocations();
      emit(StoreLocationsSuccess('تم تحديث موقع المتجر بنجاح'));
    } catch (e) {
      print(e);
      emit(StoreLocationsError('فشل في حفظ موقع المتجر'));
    }
  }

  Future<void> deleteSelectedLocation() async {
    final LocationModel? location = selectedLocation;
    if (location == null) {
      emit(StoreLocationsError('اختر موقعًا للحذف أولًا'));
      return;
    }

    emit(StoreLocationsSaving());

    try {
      await _repository.deleteStoreLocation(id: location.id);
      selectedLocation = null;
      await fetchStoreLocations();
      emit(StoreLocationsSuccess('تم حذف موقع المتجر'));
    } catch (e) {
      emit(
        StoreLocationsError(
          'فشل في حذف الموقع. قد يكون مرتبطًا بطلبات أو مستخدمين.',
        ),
      );
    }
  }

  void _syncControllers() {
    final LocationModel? location = selectedLocation;

    nameController.text = location?.name ?? '';
    locationNameController.text = location?.locationName ?? '';
    latitudeController.text = location == null
        ? ''
        : location.lX.toStringAsFixed(6);
    longitudeController.text = location == null
        ? ''
        : location.lY.toStringAsFixed(6);
  }

  @override
  Future<void> close() {
    nameController.dispose();
    locationNameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    return super.close();
  }
}
