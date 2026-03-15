import 'dart:typed_data';

import 'package:alkhafajdashboard/data/model/bannerAdsModel.dart';
import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/model/deliveryZoneModel.dart';
import 'package:alkhafajdashboard/data/model/itemImageModel.dart';
import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/data/model/partItemModel.dart';
import 'package:alkhafajdashboard/data/model/partModel.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:alkhafajdashboard/data/model/userModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApi {
  SupabaseClient supabase = Supabase.instance.client;
  String shopId = "550e8400-e29b-41d4-a716-446655440001";
  static const String recoveryRedirectUrl = 'http://localhost:52157/';

  login({required String user, required String password}) async {
    return await supabase.auth.signInWithPassword(
      email: user,
      password: password,
    );
  }

  Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    await supabase.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.recovery,
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

  fetchLocations() async {
    return await supabase.from('location').select().eq("shop_id", shopId);
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

    await supabase.from('categories').delete().eq('id', category.id as Object);
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

  Future<void> addItem({required ItemModel item}) async {
    await supabase.from('items').insert(item.toJson());
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
    final List<dynamic> images = await fetchItemImages(itemId: itemId);
    final List<String> paths = images
        .map((dynamic image) => image['image_path'])
        .whereType<String>()
        .where((path) => path.isNotEmpty)
        .toList();

    if (paths.isNotEmpty) {
      await supabase.storage.from('items').remove(paths);
    }

    await supabase
        .from('items')
        .delete()
        .eq('id', itemId)
        .eq('shop_id', shopId);
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
    final List<dynamic> response = await supabase
        .from('orders')
        .select(
          '*, customers(name, phone, l_x, l_y), assigned_location:location!orders_assigned_location_id_fkey(id, name, location_name), order_items(*), order_status_history(*)',
        )
        .eq('shop_id', shopId)
        .order('created_at', ascending: false);

    return response
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
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
    final Map<String, dynamic> payload = {'status': status};
    if (status == 'pending' || status == 'cancelled') {
      payload['assigned_location_id'] = null;
    } else if (locationId != null) {
      payload['assigned_location_id'] = locationId;
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
      'location_id': locationId,
    });
  }

  addUser({required UserModel user}) async {
    print(
      "Adding user: ${user.name}, username: ${user.username}, role: ${user.role}, locationId: ${user.locationId}",
    );

    final email = user.username!.trim();

    AuthResponse response = await supabase.auth.signUp(
      email: email,
      password: user.password!,
    );

    if (response.user == null) {
      throw AuthException('تعذر إنشاء الحساب');
    }

    await supabase.from('shop_users').insert({
      "name": user.name,
      "user_id": response.user?.id,
      "username": user.username,
      "role": user.role,
      "shop_id": shopId,
      "location_id": user.locationId,
    });
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
}
