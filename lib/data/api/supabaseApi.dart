import 'dart:typed_data';

import 'package:alkhafajdashboard/config/app_supabase_config.dart';
import 'package:alkhafajdashboard/data/model/bannerAdsModel.dart';
import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/model/discountCodeModel.dart';
import 'package:alkhafajdashboard/data/model/deliveryZoneModel.dart';
import 'package:alkhafajdashboard/data/model/itemColorModel.dart';
import 'package:alkhafajdashboard/data/model/itemImageModel.dart';
import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/data/model/itemSizeModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/data/model/partItemModel.dart';
import 'package:alkhafajdashboard/data/model/partModel.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:alkhafajdashboard/data/model/userModel.dart';
import 'package:alkhafajdashboard/utils/dashboard_auth_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApi {
  SupabaseClient supabase = Supabase.instance.client;
  final String shopId = AppSupabaseConfig.shopId;

  login({required String user, required String password}) async {
    return await supabase.auth.signInWithPassword(
      email: user,
      password: password,
    );
  }

  Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
      redirectTo: AppSupabaseConfig.recoveryRedirectUrl,
    );
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    await supabase.auth.verifyOTP(
      email: email.trim().toLowerCase(),
      token: otp.trim(),
      type: OtpType.recovery,
      redirectTo: AppSupabaseConfig.recoveryRedirectUrl,
    );
  }

  Future<void> updatePassword({required String newPassword}) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<SessionUserModel?> fetchCurrentSessionUser() async {
    final String? userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final Map<String, dynamic>? data = await supabase
        .from('shop_users')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return SessionUserModel.fromJson(data);
  }

  Future<List<dynamic>> fetchStoreLocations() async {
    return await supabase
        .from('sotre_location')
        .select()
        .eq('shop_id', shopId)
        .order('name', ascending: true)
        .order('id', ascending: true);
  }

  Future<void> addStoreLocation({
    required String name,
    required String locationName,
    required double lX,
    required double lY,
  }) async {
    await supabase.from('sotre_location').insert(<String, dynamic>{
      'shop_id': shopId,
      'name': name,
      'location_name': locationName,
      'l_x': lX,
      'l_y': lY,
    });
  }

  Future<void> updateStoreLocation({
    required int id,
    required String name,
    required String locationName,
    required double lX,
    required double lY,
  }) async {
    await supabase
        .from('sotre_location')
        .update(<String, dynamic>{
          'name': name,
          'location_name': locationName,
          'l_x': lX,
          'l_y': lY,
        })
        .eq('id', id)
        .eq('shop_id', shopId);
  }

  Future<void> deleteStoreLocation({required int id}) async {
    await supabase
        .from('sotre_location')
        .delete()
        .eq('id', id)
        .eq('shop_id', shopId);
  }

  fetchUsers() async {
    // var authResponse = await supabase.auth.();

    return await supabase.from('shop_users').select().eq("shop_id", shopId);
  }

  Future<List<dynamic>> fetchBannerAds() async {
    return await supabase
        .from('banner_ads')
        .select()
        .eq('shop_id', shopId)
        .order('sort_order', ascending: true)
        .order('id', ascending: true);
  }

  Future<String> uploadBannerImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final String safeName = fileName.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    final String path =
        'shop_$shopId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await supabase.storage
        .from('ads')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return path;
  }

  String getBannerImagePublicUrl(String imagePath) {
    return supabase.storage.from('ads').getPublicUrl(imagePath);
  }

  Future<void> addBannerAd({required BannerAdsModel bannerAd}) async {
    await supabase.from('banner_ads').insert(bannerAd.toJson());
  }

  Future<void> updateBannerAd({required BannerAdsModel bannerAd}) async {
    await supabase
        .from('banner_ads')
        .update(bannerAd.toJson())
        .eq('id', bannerAd.id as Object);
  }

  Future<void> deleteBannerAd({required BannerAdsModel bannerAd}) async {
    if (bannerAd.imagePath != null && bannerAd.imagePath!.isNotEmpty) {
      await supabase.storage.from('ads').remove([bannerAd.imagePath!]);
    }

    await supabase.from('banner_ads').delete().eq('id', bannerAd.id as Object);
  }

  Future<void> updateBannerAdsOrder({required List<BannerAdsModel> ads}) async {
    final int offset = ads.length + 1000;

    for (final ad in ads) {
      await supabase
          .from('banner_ads')
          .update({'sort_order': offset + (ad.sortOrder ?? 0)})
          .eq('id', ad.id as Object)
          .eq('shop_id', shopId);
    }

    for (final ad in ads) {
      await supabase
          .from('banner_ads')
          .update({'sort_order': ad.sortOrder, 'is_active': ad.isActive})
          .eq('id', ad.id as Object)
          .eq('shop_id', shopId);
    }
  }

  Future<String> uploadCategoryImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final String safeName = fileName.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    final String path =
        'shop_$shopId/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await supabase.storage
        .from('icon')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return path;
  }

  String getCategoryImagePublicUrl(String imagePath) {
    return supabase.storage.from('icon').getPublicUrl(imagePath);
  }

  Future<List<dynamic>> fetchCategories() async {
    return await supabase
        .from('categories')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false)
        .order('name', ascending: true);
  }

  Future<void> addCategory({required CategoryModel category}) async {
    await supabase.from('categories').insert(category.toJson());
  }

  Future<void> updateCategory({required CategoryModel category}) async {
    await supabase
        .from('categories')
        .update(category.toJson())
        .eq('id', category.id as Object);
  }

  Future<void> deleteCategory({required CategoryModel category}) async {
    if (category.icon != null && category.icon!.isNotEmpty) {
      await supabase.storage.from('icon').remove([category.icon!]);
    }

    await supabase.from('categories').delete().eq('id', category.id!);
  }

  Future<List<dynamic>> fetchDeliveryZones() async {
    return await supabase
        .from('delivery_zones')
        .select()
        .eq('shop_id', shopId)
        .order('city', ascending: true)
        .order('id', ascending: true);
  }

  Future<void> addDeliveryZone({
    required DeliveryZoneModel deliveryZone,
  }) async {
    await supabase.from('delivery_zones').insert(deliveryZone.toJson());
  }

  Future<void> updateDeliveryZone({
    required DeliveryZoneModel deliveryZone,
  }) async {
    await supabase
        .from('delivery_zones')
        .update(deliveryZone.toJson())
        .eq('id', deliveryZone.id as Object);
  }

  Future<void> deleteDeliveryZone({required int deliveryZoneId}) async {
    await supabase
        .from('delivery_zones')
        .delete()
        .eq('id', deliveryZoneId)
        .eq('shop_id', shopId);
  }

  Future<List<dynamic>> fetchDiscountCodes() async {
    return await supabase
        .from('discount_codes')
        .select()
        .eq('shop_id', shopId)
        .order('created_at', ascending: false)
        .order('id', ascending: false);
  }

  Future<void> addDiscountCode({
    required DiscountCodeModel discountCode,
  }) async {
    await supabase.from('discount_codes').insert(discountCode.toJson());
  }

  Future<void> updateDiscountCode({
    required DiscountCodeModel discountCode,
  }) async {
    await supabase
        .from('discount_codes')
        .update({
          ...discountCode.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', discountCode.id as Object)
        .eq('shop_id', shopId);
  }

  Future<void> deleteDiscountCode({required int discountCodeId}) async {
    await supabase
        .from('discount_codes')
        .delete()
        .eq('id', discountCodeId)
        .eq('shop_id', shopId);
  }

  Future<List<dynamic>> fetchItems({bool includeDeleted = false}) async {
    final query = supabase.from('items').select().eq('shop_id', shopId);

    if (!includeDeleted) {
      query.eq('is_deleted', false);
    }

    return await query
        .order('created_at', ascending: false)
        .order('id', ascending: false);
  }

  Future<List<dynamic>> fetchItemsByCategory({
    required String categoryId,
    bool includeDeleted = false,
  }) async {
    final query = supabase
        .from('items')
        .select()
        .eq('shop_id', shopId)
        .eq('category_id', categoryId);

    if (!includeDeleted) {
      query.eq('is_deleted', false);
    }

    return await query
        .order('created_at', ascending: false)
        .order('id', ascending: false);
  }

  Future<ItemModel> addItem({required ItemModel item}) async {
    final Map<String, dynamic> response = await supabase
        .from('items')
        .insert(item.toJson())
        .select()
        .single();
    return ItemModel.fromJson(response);
  }

  Future<void> updateItem({required ItemModel item}) async {
    await supabase
        .from('items')
        .update(item.toJson())
        .eq('id', item.id as Object);
  }

  Future<void> softDeleteItem({required int itemId}) async {
    await supabase
        .from('items')
        .update({'is_deleted': true, 'is_active': false})
        .eq('id', itemId)
        .eq('shop_id', shopId);
  }

  Future<void> restoreItem({required int itemId}) async {
    await supabase
        .from('items')
        .update({'is_deleted': false})
        .eq('id', itemId)
        .eq('shop_id', shopId);
  }

  Future<void> deleteItemPermanently({required int itemId}) async {
    final List<dynamic> orderItems = await supabase
        .from('order_items')
        .select('id')
        .eq('item_id', itemId)
        .limit(1);

    if (orderItems.isNotEmpty) {
      throw Exception('ITEM_DELETE_BLOCKED_BY_ORDERS');
    }

    final List<dynamic> images = await fetchItemImages(itemId: itemId);
    final List<String> paths = images
        .map((dynamic image) => image['image_path'])
        .whereType<String>()
        .where((path) => path.isNotEmpty)
        .toList();

    await supabase.from('cart_items').delete().eq('item_id', itemId);
    await supabase.from('favorites').delete().eq('item_id', itemId);
    await supabase.from('part_items').delete().eq('item_id', itemId);
    await supabase.from('item_images').delete().eq('item_id', itemId);
    await supabase.from('item_colors').delete().eq('item_id', itemId);
    await supabase.from('item_sizes').delete().eq('item_id', itemId);

    final List<dynamic> deletedItems = await supabase
        .from('items')
        .delete()
        .eq('id', itemId)
        .eq('shop_id', shopId)
        .select('id');

    if (deletedItems.isEmpty) {
      throw Exception('ITEM_DELETE_NOT_FOUND_OR_FORBIDDEN');
    }

    if (paths.isNotEmpty) {
      await supabase.storage.from('items').remove(paths);
    }
  }

  Future<String> uploadItemImage({
    required Uint8List bytes,
    required String fileName,
    int? itemId,
  }) async {
    final String safeName = fileName.replaceAll(
      RegExp(r'[^A-Za-z0-9._-]'),
      '_',
    );
    final String folder = itemId != null ? 'item_$itemId' : 'unassigned';
    final String path =
        'shop_$shopId/$folder/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await supabase.storage
        .from('items')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return path;
  }

  String getItemImagePublicUrl(String imagePath) {
    return supabase.storage.from('items').getPublicUrl(imagePath);
  }

  Future<List<dynamic>> fetchItemImages({required int itemId}) async {
    return await supabase
        .from('item_images')
        .select()
        .eq('item_id', itemId)
        .order('is_primary', ascending: false)
        .order('sort_order', ascending: true)
        .order('id', ascending: true);
  }

  Future<void> addItemImage({required ItemImageModel itemImage}) async {
    if (itemImage.isPrimary == true) {
      await supabase
          .from('item_images')
          .update({'is_primary': false})
          .eq('item_id', itemImage.itemId as Object);
    }

    await supabase.from('item_images').insert(itemImage.toJson());
  }

  Future<void> updateItemImage({required ItemImageModel itemImage}) async {
    if (itemImage.isPrimary == true) {
      await supabase
          .from('item_images')
          .update({'is_primary': false})
          .eq('item_id', itemImage.itemId as Object)
          .neq('id', itemImage.id as Object);
    }

    await supabase
        .from('item_images')
        .update(itemImage.toJson())
        .eq('id', itemImage.id as Object);
  }

  Future<void> deleteItemImage({required ItemImageModel itemImage}) async {
    if (itemImage.imagePath != null && itemImage.imagePath!.isNotEmpty) {
      await supabase.storage.from('items').remove([itemImage.imagePath!]);
    }

    await supabase
        .from('item_images')
        .delete()
        .eq('id', itemImage.id as Object);
  }

  Future<List<dynamic>> fetchItemColors({required int itemId}) async {
    return await supabase
        .from('item_colors')
        .select()
        .eq('item_id', itemId)
        .order('sort_order', ascending: true)
        .order('id', ascending: true);
  }

  Future<List<dynamic>> fetchItemSizes({required int itemId}) async {
    return await supabase
        .from('item_sizes')
        .select()
        .eq('item_id', itemId)
        .order('sort_order', ascending: true)
        .order('id', ascending: true);
  }

  Future<void> replaceItemColors({
    required int itemId,
    required List<ItemColorModel> colors,
  }) async {
    await supabase.from('item_colors').delete().eq('item_id', itemId);

    if (colors.isEmpty) {
      return;
    }

    await supabase
        .from('item_colors')
        .insert(
          colors
              .asMap()
              .entries
              .map(
                (entry) => entry.value
                    .copyWith(itemId: itemId, sortOrder: entry.key + 1)
                    .toJson(),
              )
              .toList(),
        );
  }

  Future<void> replaceItemSizes({
    required int itemId,
    required List<ItemSizeModel> sizes,
  }) async {
    await supabase.from('item_sizes').delete().eq('item_id', itemId);

    if (sizes.isEmpty) {
      return;
    }

    await supabase
        .from('item_sizes')
        .insert(
          sizes
              .asMap()
              .entries
              .map(
                (entry) => entry.value
                    .copyWith(itemId: itemId, sortOrder: entry.key + 1)
                    .toJson(),
              )
              .toList(),
        );
  }

  Future<List<dynamic>> fetchParts() async {
    return await supabase
        .from('parts')
        .select()
        .eq('shop_id', shopId)
        .order('sort_order', ascending: true)
        .order('id', ascending: true);
  }

  Future<void> addPart({required PartModel part}) async {
    await supabase.from('parts').insert(part.toJson());
  }

  Future<void> updatePart({required PartModel part}) async {
    await supabase
        .from('parts')
        .update(part.toJson())
        .eq('id', part.id as Object);
  }

  Future<void> deletePart({required int partId}) async {
    await supabase
        .from('parts')
        .delete()
        .eq('id', partId)
        .eq('shop_id', shopId);
  }

  Future<void> updatePartsOrder({required List<PartModel> parts}) async {
    final int offset = parts.length + 1000;

    for (final part in parts) {
      await supabase
          .from('parts')
          .update({'sort_order': offset + (part.sortOrder ?? 0)})
          .eq('id', part.id as Object)
          .eq('shop_id', shopId);
    }

    for (final part in parts) {
      await supabase
          .from('parts')
          .update({'sort_order': part.sortOrder, 'is_active': part.isActive})
          .eq('id', part.id as Object)
          .eq('shop_id', shopId);
    }
  }

  Future<List<dynamic>> fetchPartItems({required int partId}) async {
    return await supabase
        .from('part_items')
        .select()
        .eq('part_id', partId)
        .order('id', ascending: true);
  }

  Future<void> addPartItem({required PartItemModel partItem}) async {
    await supabase.from('part_items').insert(partItem.toJson());
  }

  Future<void> deletePartItem({required int id}) async {
    await supabase.from('part_items').delete().eq('id', id);
  }

  Future<void> replacePartItems({
    required int partId,
    required List<int> itemIds,
  }) async {
    await supabase.from('part_items').delete().eq('part_id', partId);

    if (itemIds.isEmpty) {
      return;
    }

    await supabase
        .from('part_items')
        .insert(
          itemIds
              .map((itemId) => {'part_id': partId, 'item_id': itemId})
              .toList(),
        );
  }

  Future<List<OrderModel>> fetchOrders() async {
    List<dynamic> orderRows;

    try {
      orderRows = await supabase
          .from('orders')
          .select(
            '*, customers(name, phone), order_items(*), order_status_history(*)',
          )
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
    } catch (e) {
      print('fetchOrders relational query failed, fallback to basic query: $e');

      orderRows = await supabase
          .from('orders')
          .select('*')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);
    }

    return await _composeOrdersWithNewLocations(orderRows);
  }

  Future<List<OrderModel>> _composeOrdersWithNewLocations(
    List<dynamic> orderRows,
  ) async {
    final List<Map<String, dynamic>> orders = orderRows
        .whereType<Map<String, dynamic>>()
        .toList();

    if (orders.isEmpty) {
      return <OrderModel>[];
    }

    final Set<int> customerIds = orders
        .map((row) => row['customer_id'])
        .whereType<int>()
        .toSet();

    final Set<int> orderIds = orders
        .map((row) => row['id'])
        .whereType<int>()
        .toSet();

    final Set<int> assignedLocationIds = orders
        .map((row) => row['assigned_location_id'])
        .whereType<int>()
        .toSet();

    final bool hasOrderItemsInRows = orders.any(
      (row) => row['order_items'] is List,
    );
    final bool hasHistoryInRows = orders.any(
      (row) => row['order_status_history'] is List,
    );

    final Map<int, List<Map<String, dynamic>>> orderItemsByOrderId =
        <int, List<Map<String, dynamic>>>{};
    final Map<int, List<Map<String, dynamic>>> orderHistoryByOrderId =
        <int, List<Map<String, dynamic>>>{};

    if (orderIds.isNotEmpty && !hasOrderItemsInRows) {
      final List<dynamic> orderItemsRows = await supabase
          .from('order_items')
          .select('*')
          .inFilter('order_id', orderIds.toList());

      for (final row in orderItemsRows.whereType<Map<String, dynamic>>()) {
        final int? orderId = row['order_id'] as int?;
        if (orderId == null) {
          continue;
        }
        orderItemsByOrderId.putIfAbsent(
          orderId,
          () => <Map<String, dynamic>>[],
        );
        orderItemsByOrderId[orderId]!.add(row);
      }
    }

    if (orderIds.isNotEmpty && !hasHistoryInRows) {
      final List<dynamic> historyRows = await supabase
          .from('order_status_history')
          .select('*')
          .inFilter('order_id', orderIds.toList())
          .order('created_at', ascending: true);

      for (final row in historyRows.whereType<Map<String, dynamic>>()) {
        final int? orderId = row['order_id'] as int?;
        if (orderId == null) {
          continue;
        }
        orderHistoryByOrderId.putIfAbsent(
          orderId,
          () => <Map<String, dynamic>>[],
        );
        orderHistoryByOrderId[orderId]!.add(row);
      }
    }

    final Map<int, Map<String, dynamic>> customerLocationByCustomerId =
        <int, Map<String, dynamic>>{};
    if (customerIds.isNotEmpty) {
      final List<dynamic> customerLocationRows = await supabase
          .from('location')
          .select(
            'id, customer_id, location_name, full_address, l_x, l_y, is_default, updated_at',
          )
          .eq('shop_id', shopId)
          .inFilter('customer_id', customerIds.toList())
          .order('is_default', ascending: false)
          .order('updated_at', ascending: false);

      for (final row
          in customerLocationRows.whereType<Map<String, dynamic>>()) {
        final int? customerId = row['customer_id'] as int?;
        if (customerId == null) {
          continue;
        }
        customerLocationByCustomerId.putIfAbsent(customerId, () => row);
      }
    }

    final Map<int, Map<String, dynamic>> storeLocationById =
        <int, Map<String, dynamic>>{};
    if (assignedLocationIds.isNotEmpty) {
      final List<dynamic> storeLocationRows = await supabase
          .from('sotre_location')
          .select('id, name, location_name, l_x, l_y')
          .inFilter('id', assignedLocationIds.toList());

      for (final row in storeLocationRows.whereType<Map<String, dynamic>>()) {
        final int? id = row['id'] as int?;
        if (id != null) {
          storeLocationById[id] = row;
        }
      }
    }

    final List<Map<String, dynamic>> normalizedRows = orders.map((row) {
      final int? customerId = row['customer_id'] as int?;
      final int? assignedLocationId = row['assigned_location_id'] as int?;
      final int? orderId = row['id'] as int?;

      final Map<String, dynamic>? customerLoc = customerId == null
          ? null
          : customerLocationByCustomerId[customerId];
      final Map<String, dynamic>? storeLoc = assignedLocationId == null
          ? null
          : storeLocationById[assignedLocationId];

      final List<Map<String, dynamic>> fallbackItems = orderId == null
          ? <Map<String, dynamic>>[]
          : (orderItemsByOrderId[orderId] ?? <Map<String, dynamic>>[]);
      final List<Map<String, dynamic>> fallbackHistory = orderId == null
          ? <Map<String, dynamic>>[]
          : (orderHistoryByOrderId[orderId] ?? <Map<String, dynamic>>[]);

      return <String, dynamic>{
        ...row,
        if (row['order_items'] is! List) 'order_items': fallbackItems,
        if (row['order_status_history'] is! List)
          'order_status_history': fallbackHistory,
        if (customerLoc != null)
          'customer_lat':
              (customerLoc['l_x'] as num?)?.toDouble() ??
              (customerLoc['L_X'] as num?)?.toDouble(),
        if (customerLoc != null)
          'customer_lng':
              (customerLoc['l_y'] as num?)?.toDouble() ??
              (customerLoc['L_y'] as num?)?.toDouble(),
        if (customerLoc != null)
          'customer_location_name':
              (customerLoc['full_address'] ?? customerLoc['location_name'])
                  ?.toString(),
        if (storeLoc != null)
          'assigned_location': {
            'id': storeLoc['id'],
            'name': (storeLoc['name'] ?? '').toString(),
            'location_name': (storeLoc['location_name'] ?? '').toString(),
          },
      };
    }).toList();

    return normalizedRows.map(OrderModel.fromJson).toList();
  }

  Future<void> assignOrderToLocation({
    required int orderId,
    required int locationId,
    required String changedBy,
    String? notes,
  }) async {
    await supabase
        .from('orders')
        .update({'status': 'confirmed', 'assigned_location_id': locationId})
        .eq('id', orderId)
        .eq('shop_id', shopId);

    await supabase.from('order_status_history').insert({
      'order_id': orderId,
      'status': 'confirmed',
      'changed_by': changedBy,
      'notes': notes,
      'location_id': locationId,
    });
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
    required String changedBy,
    int? locationId,
    String? notes,
  }) async {
    final int? normalizedLocationId = (locationId != null && locationId > 0)
        ? locationId
        : null;
    final Map<String, dynamic> payload = {'status': status};
    if (status == 'pending' || status == 'cancelled') {
      payload['assigned_location_id'] = null;
    } else if (normalizedLocationId != null) {
      payload['assigned_location_id'] = normalizedLocationId;
    }

    await supabase
        .from('orders')
        .update(payload)
        .eq('id', orderId)
        .eq('shop_id', shopId);

    await supabase.from('order_status_history').insert({
      'order_id': orderId,
      'status': status,
      'changed_by': changedBy,
      'notes': notes,
      'location_id': normalizedLocationId,
    });
  }

  addUser({required UserModel user}) async {
    print(
      "Adding user: ${user.name}, username: ${user.username}, role: ${user.role}, locationId: ${user.locationId}",
    );
    final response = await supabase.functions.invoke(
      'create-dashboard-user',
      body: <String, dynamic>{
        'shop_id': shopId,
        'name': user.name,
        'username': normalizeDashboardUsername(user.username ?? ''),
        'email': normalizeDashboardEmail(user.username ?? ''),
        'password': user.password,
        'role': user.role,
        'location_id': user.locationId,
      },
    );

    if (response.status < 200 || response.status >= 300) {
      final dynamic data = response.data;
      final String message = data is Map<String, dynamic>
          ? (data['error']?.toString() ?? 'تعذر إنشاء الحساب')
          : 'تعذر إنشاء الحساب';
      throw AuthException(message);
    }
  }

  updateUser({
    required String userId,
    required String username,
    required String password,
    required String name,
  }) async {
    final email = username.trim();

    await supabase.auth.updateUser(
      UserAttributes(password: password, email: email),
    );

    await supabase
        .from('shop_users')
        .update({"name": name})
        .eq("user_id", userId);
  }

  // ─── Notifications ───────────────────────────────────────────────────

  /// جلب جميع الإشعارات المرسلة من الداشبورد
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final List<dynamic> customerResponse = await supabase
        .from('customer_notifications')
        .select('*, customers(name, phone), delivery_meta')
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    final List<dynamic> broadcastResponse = await supabase
        .from('broadcast_notifications')
        .select('*, delivery_meta')
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    final List<Map<String, dynamic>> notifications = <Map<String, dynamic>>[
      ...broadcastResponse.whereType<Map<String, dynamic>>().map(
        (Map<String, dynamic> row) => <String, dynamic>{
          ...row,
          'scope': 'broadcast',
        },
      ),
      ...customerResponse.whereType<Map<String, dynamic>>().map(
        (Map<String, dynamic> row) => <String, dynamic>{
          ...row,
          'scope': 'customer',
        },
      ),
    ];

    notifications.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
      final DateTime left =
          DateTime.tryParse((a['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime right =
          DateTime.tryParse((b['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });

    return notifications;
  }

  Future<List<Map<String, dynamic>>> fetchNotificationCustomers() async {
    final List<dynamic> response = await supabase
        .from('customers')
        .select('id, name, phone, is_active, is_banned')
        .eq('shop_id', shopId)
        .order('name', ascending: true)
        .order('id', ascending: true);

    return response
        .whereType<Map<String, dynamic>>()
        .where(
          (Map<String, dynamic> row) =>
              row['is_banned'] != true && row['is_active'] != false,
        )
        .toList();
  }

  Future<Map<String, dynamic>> sendBroadcastNotification({
    required String title,
    required String body,
    required String type, // 'promotion' | 'announcement'
    Map<String, dynamic>? payload,
  }) async {
    final response = await supabase.functions.invoke(
      'send-notification',
      body: <String, dynamic>{
        'audience': 'broadcast',
        'shop_id': shopId,
        'title': title,
        'body': body,
        'type': type,
        'payload': payload ?? <String, dynamic>{},
      },
    );

    if (response.status < 200 || response.status >= 300) {
      final dynamic data = response.data;
      final String message = data is Map<String, dynamic>
          ? (data['error']?.toString() ?? 'تعذر إرسال الإشعار العام')
          : 'تعذر إرسال الإشعار العام';
      throw AuthException(message);
    }

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  /// إرسال إشعار لعميل محدد
  Future<Map<String, dynamic>> sendNotificationToCustomer({
    required int customerId,
    required String title,
    required String body,
    required String type,
    int? orderId,
    String? orderStatus,
    Map<String, dynamic>? payload,
    String? imageUrl,
  }) async {
    final response = await supabase.functions.invoke(
      'send-notification',
      body: <String, dynamic>{
        'audience': 'customer',
        'shop_id': shopId,
        'customer_id': customerId,
        'title': title,
        'body': body,
        'type': type,
        if (orderId != null) 'order_id': orderId,
        if (orderStatus != null) 'order_status': orderStatus,
        if (imageUrl != null) 'image_url': imageUrl,
        'payload': payload ?? <String, dynamic>{},
      },
    );

    if (response.status < 200 || response.status >= 300) {
      final dynamic data = response.data;
      final String message = data is Map<String, dynamic>
          ? (data['error']?.toString() ?? 'تعذر إرسال الإشعار الفردي')
          : 'تعذر إرسال الإشعار الفردي';
      throw AuthException(message);
    }

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return <String, dynamic>{};
  }

  /// حذف إشعار
  Future<void> deleteNotification({required int notificationId}) async {
    await supabase
        .from('customer_notifications')
        .delete()
        .eq('id', notificationId);
  }

  /// جلب عدد العملاء
  Future<int> fetchCustomerCount() async {
    final List<dynamic> response = await supabase
        .from('customers')
        .select('id')
        .eq('shop_id', shopId);
    return response.length;
  }
}
