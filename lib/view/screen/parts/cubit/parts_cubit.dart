import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/data/model/partItemModel.dart';
import 'package:alkhafajdashboard/data/model/partModel.dart';
import 'package:alkhafajdashboard/data/repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'parts_state.dart';

class PartsCubit extends Cubit<PartsState> {
  PartsCubit() : super(PartsInitial());

  final Repository _repository = Repository();

  List<PartModel> parts = [];
  List<ItemModel> items = [];
  List<PartItemModel> partItems = [];

  PartModel? selectedPart;
  final Set<int> selectedItemIds = <int>{};

  final TextEditingController nameController = TextEditingController();
  final TextEditingController sortOrderController = TextEditingController(
    text: '1',
  );

  bool isActive = true;
  String searchQuery = '';

  Future<void> initialize() async {
    emit(PartsLoading());
    try {
      await _fetchPartsInternal();
      await _fetchItemsInternal();
      if (selectedPart == null && parts.isNotEmpty) {
        await selectPart(parts.first, emitState: false);
      } else {
        _syncControllers();
      }
      emit(PartsLoaded());
    } catch (e) {
      emit(PartsError('فشل في تهيئة صفحة الأقسام'));
    }
  }

  Future<void> refreshData() async {
    emit(PartsLoading());
    try {
      await _fetchPartsInternal();
      await _fetchItemsInternal();
      if (selectedPart != null) {
        await _loadPartItems();
      }
      _syncControllers();
      emit(PartsLoaded());
    } catch (e) {
      emit(PartsError('فشل في تحديث البيانات'));
    }
  }

  Future<void> _fetchPartsInternal() async {
    final List<dynamic> response = await _repository.fetchParts();
    parts = response.map((item) {
      return PartModel.fromJson(item as Map<String, dynamic>);
    }).toList();

    if (selectedPart != null) {
      final int index = parts.indexWhere((part) => part.id == selectedPart!.id);
      selectedPart = index >= 0 ? parts[index] : null;
    }
  }

  Future<void> _fetchItemsInternal() async {
    final List<dynamic> response = await _repository.fetchItems();
    items = response.map((item) {
      return ItemModel.fromJson(item as Map<String, dynamic>);
    }).toList();
  }

  Future<void> selectPart(PartModel? part, {bool emitState = true}) async {
    selectedPart = part;
    await _loadPartItems();
    _syncControllers();
    if (emitState) {
      emit(PartsLoaded());
    }
  }

  void startCreatingNewPart() {
    selectedPart = null;
    partItems = [];
    selectedItemIds.clear();
    nameController.clear();
    sortOrderController.text = '${parts.length + 1}';
    isActive = true;
    searchQuery = '';
    emit(PartsLoaded());
  }

  Future<void> _loadPartItems() async {
    selectedItemIds.clear();

    if (selectedPart?.id == null) {
      partItems = [];
      return;
    }

    final List<dynamic> response = await _repository.fetchPartItems(
      partId: selectedPart!.id!,
    );

    partItems = response.map((item) {
      return PartItemModel.fromJson(item as Map<String, dynamic>);
    }).toList();

    for (final partItem in partItems) {
      if (partItem.itemId != null) {
        selectedItemIds.add(partItem.itemId!);
      }
    }
  }

  void updateActiveStatus(bool value) {
    isActive = value;
    emit(PartsLoaded());
  }

  void updateSearchQuery(String value) {
    searchQuery = value.trim();
    emit(PartsLoaded());
  }

  void toggleItemSelection(int itemId) {
    if (selectedItemIds.contains(itemId)) {
      selectedItemIds.remove(itemId);
    } else {
      selectedItemIds.add(itemId);
    }
    emit(PartsLoaded());
  }

  void movePartUp(int index) {
    if (index <= 0 || index >= parts.length) {
      return;
    }

    final item = parts.removeAt(index);
    parts.insert(index - 1, item);
    _recalculateSortOrders();
    emit(PartsLoaded());
  }

  void movePartDown(int index) {
    if (index < 0 || index >= parts.length - 1) {
      return;
    }

    final item = parts.removeAt(index);
    parts.insert(index + 1, item);
    _recalculateSortOrders();
    emit(PartsLoaded());
  }

  Future<void> persistOrder() async {
    emit(PartsSaving());
    try {
      await _repository.updatePartsOrder(parts: parts);
      await refreshData();
      emit(PartsSuccess('تم حفظ ترتيب الأقسام'));
    } catch (e) {
      emit(PartsError('فشل في حفظ ترتيب الأقسام'));
    }
  }

  Future<void> savePart() async {
    final String name = nameController.text.trim();
    final int? sortOrder = int.tryParse(sortOrderController.text.trim());

    if (name.isEmpty) {
      emit(PartsError('اسم القسم مطلوب'));
      return;
    }

    if (sortOrder == null || sortOrder < 1) {
      emit(PartsError('الترتيب يجب أن يكون رقماً صحيحاً أكبر من صفر'));
      return;
    }

    emit(PartsSaving());

    try {
      if (selectedPart == null) {
        final PartModel part = PartModel(
          shopId: _repository.supabaseApi.shopId,
          name: name,
          sortOrder: sortOrder,
          isActive: isActive,
        );

        await _repository.addPart(part: part);
        await _fetchPartsInternal();
        final PartModel? createdPart = parts.isNotEmpty ? parts.last : null;

        if (createdPart != null) {
          await _repository.replacePartItems(
            partId: createdPart.id!,
            itemIds: selectedItemIds.toList(),
          );
        }

        await refreshData();
        startCreatingNewPart();
        emit(PartsSuccess('تم إنشاء القسم بنجاح'));
        return;
      }

      final PartModel updatedPart = selectedPart!.copyWith(
        name: name,
        sortOrder: sortOrder,
        isActive: isActive,
      );

      await _repository.updatePart(part: updatedPart);
      await _repository.replacePartItems(
        partId: updatedPart.id!,
        itemIds: selectedItemIds.toList(),
      );
      selectedPart = updatedPart;
      await refreshData();
      emit(PartsSuccess('تم تحديث القسم بنجاح'));
    } catch (e) {
      emit(PartsError('فشل في حفظ القسم'));
    }
  }

  Future<void> deleteSelectedPart() async {
    if (selectedPart?.id == null) {
      emit(PartsError('اختر قسماً للحذف أولاً'));
      return;
    }

    emit(PartsSaving());
    try {
      await _repository.deletePart(partId: selectedPart!.id!);
      startCreatingNewPart();
      await refreshData();
      emit(PartsSuccess('تم حذف القسم'));
    } catch (e) {
      emit(PartsError('فشل في حذف القسم'));
    }
  }

  List<ItemModel> get filteredItems {
    if (searchQuery.isEmpty) {
      return items;
    }

    final query = searchQuery.toLowerCase();
    return items.where((item) {
      final title = (item.title ?? '').toLowerCase();
      final description = (item.description ?? '').toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  String selectedItemsSummary() {
    if (selectedItemIds.isEmpty) {
      return 'لم يتم اختيار منتجات بعد';
    }

    return 'تم اختيار ${selectedItemIds.length} منتج';
  }

  List<ItemModel> linkedItemsPreview() {
    return items.where((item) => selectedItemIds.contains(item.id)).toList();
  }

  void _syncControllers() {
    nameController.text = selectedPart?.name ?? '';
    sortOrderController.text = '${selectedPart?.sortOrder ?? 1}';
    isActive = selectedPart?.isActive ?? true;
  }

  void _recalculateSortOrders() {
    parts = parts.asMap().entries.map((entry) {
      return entry.value.copyWith(sortOrder: entry.key);
    }).toList();

    if (selectedPart != null) {
      final int index = parts.indexWhere((item) => item.id == selectedPart!.id);
      if (index >= 0) {
        selectedPart = parts[index];
      }
    }

    sortOrderController.text = '${selectedPart?.sortOrder ?? 1}';
  }

  @override
  Future<void> close() {
    nameController.dispose();
    sortOrderController.dispose();
    return super.close();
  }
}
