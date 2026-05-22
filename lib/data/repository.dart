import 'package:alkhafajdashboard/data/api/supabaseApi.dart';
import 'package:alkhafajdashboard/data/model/bannerAdsModel.dart';
import 'package:alkhafajdashboard/data/model/categoryModel.dart';
import 'package:alkhafajdashboard/data/model/discountCodeModel.dart';
import 'package:alkhafajdashboard/data/model/deliveryZoneModel.dart';
import 'package:alkhafajdashboard/data/model/itemColorModel.dart';
import 'package:alkhafajdashboard/data/model/itemImageModel.dart';
import 'package:alkhafajdashboard/data/model/itemModel.dart';
import 'package:alkhafajdashboard/data/model/itemSizeModel.dart';
import 'package:alkhafajdashboard/data/model/partItemModel.dart';
import 'package:alkhafajdashboard/data/model/partModel.dart';
import 'package:alkhafajdashboard/data/model/orders/order_model.dart';
import 'package:alkhafajdashboard/data/model/session_user_model.dart';
import 'package:alkhafajdashboard/data/model/userModel.dart';
import 'dart:typed_data';

class Repository {
  final SupabaseApi supabaseApi = SupabaseApi();

  login({required String username, required String password}) async {
    return await supabaseApi.login(user: username, password: password);
  }

  Future<void> resetPassword({required String email}) async {
    await supabaseApi.resetPassword(email: email);
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    await supabaseApi.verifyRecoveryOtp(email: email, otp: otp);
  }

  Future<void> updatePassword({required String newPassword}) async {
    await supabaseApi.updatePassword(newPassword: newPassword);
  }

  Future<SessionUserModel?> fetchCurrentSessionUser() async {
    return await supabaseApi.fetchCurrentSessionUser();
  }

  Future<List<dynamic>> fetchStoreLocations() async {
    return await supabaseApi.fetchStoreLocations();
  }

  Future<void> addStoreLocation({
    required String name,
    required String locationName,
    required double lX,
    required double lY,
  }) async {
    await supabaseApi.addStoreLocation(
      name: name,
      locationName: locationName,
      lX: lX,
      lY: lY,
    );
  }

  Future<void> updateStoreLocation({
    required int id,
    required String name,
    required String locationName,
    required double lX,
    required double lY,
  }) async {
    await supabaseApi.updateStoreLocation(
      id: id,
      name: name,
      locationName: locationName,
      lX: lX,
      lY: lY,
    );
  }

  Future<void> deleteStoreLocation({required int id}) async {
    await supabaseApi.deleteStoreLocation(id: id);
  }

  fetchUsers() async {
    return await supabaseApi.fetchUsers();
  }

  addUser({required UserModel user}) async {
    await supabaseApi.addUser(user: user);
  }

  Future<List<dynamic>> fetchBannerAds() async {
    return await supabaseApi.fetchBannerAds();
  }

  Future<String> uploadBannerImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return await supabaseApi.uploadBannerImage(
      bytes: bytes,
      fileName: fileName,
    );
  }

  String getBannerImagePublicUrl(String imagePath) {
    return supabaseApi.getBannerImagePublicUrl(imagePath);
  }

  Future<String> uploadCategoryImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    return await supabaseApi.uploadCategoryImage(
      bytes: bytes,
      fileName: fileName,
    );
  }

  String getCategoryImagePublicUrl(String imagePath) {
    return supabaseApi.getCategoryImagePublicUrl(imagePath);
  }

  Future<void> addBannerAd({required BannerAdsModel bannerAd}) async {
    await supabaseApi.addBannerAd(bannerAd: bannerAd);
  }

  Future<void> updateBannerAd({required BannerAdsModel bannerAd}) async {
    await supabaseApi.updateBannerAd(bannerAd: bannerAd);
  }

  Future<void> deleteBannerAd({required BannerAdsModel bannerAd}) async {
    await supabaseApi.deleteBannerAd(bannerAd: bannerAd);
  }

  Future<void> updateBannerAdsOrder({required List<BannerAdsModel> ads}) async {
    await supabaseApi.updateBannerAdsOrder(ads: ads);
  }

  Future<List<dynamic>> fetchCategories() async {
    return await supabaseApi.fetchCategories();
  }

  Future<void> addCategory({required CategoryModel category}) async {
    await supabaseApi.addCategory(category: category);
  }

  Future<void> updateCategory({required CategoryModel category}) async {
    await supabaseApi.updateCategory(category: category);
  }

  Future<void> deleteCategory({required CategoryModel category}) async {
    await supabaseApi.deleteCategory(category: category);
  }

  Future<List<dynamic>> fetchDeliveryZones() async {
    return await supabaseApi.fetchDeliveryZones();
  }

  Future<void> addDeliveryZone({
    required DeliveryZoneModel deliveryZone,
  }) async {
    await supabaseApi.addDeliveryZone(deliveryZone: deliveryZone);
  }

  Future<void> updateDeliveryZone({
    required DeliveryZoneModel deliveryZone,
  }) async {
    await supabaseApi.updateDeliveryZone(deliveryZone: deliveryZone);
  }

  Future<void> deleteDeliveryZone({required int deliveryZoneId}) async {
    await supabaseApi.deleteDeliveryZone(deliveryZoneId: deliveryZoneId);
  }

  Future<List<dynamic>> fetchDiscountCodes() async {
    return await supabaseApi.fetchDiscountCodes();
  }

  Future<void> addDiscountCode({
    required DiscountCodeModel discountCode,
  }) async {
    await supabaseApi.addDiscountCode(discountCode: discountCode);
  }

  Future<void> updateDiscountCode({
    required DiscountCodeModel discountCode,
  }) async {
    await supabaseApi.updateDiscountCode(discountCode: discountCode);
  }

  Future<void> deleteDiscountCode({required int discountCodeId}) async {
    await supabaseApi.deleteDiscountCode(discountCodeId: discountCodeId);
  }

  Future<List<dynamic>> fetchItems({bool includeDeleted = false}) async {
    return await supabaseApi.fetchItems(includeDeleted: includeDeleted);
  }

  Future<List<dynamic>> fetchItemsByCategory({
    required String categoryId,
    bool includeDeleted = false,
  }) async {
    return await supabaseApi.fetchItemsByCategory(
      categoryId: categoryId,
      includeDeleted: includeDeleted,
    );
  }

  Future<ItemModel> addItem({required ItemModel item}) async {
    return await supabaseApi.addItem(item: item);
  }

  Future<void> updateItem({required ItemModel item}) async {
    await supabaseApi.updateItem(item: item);
  }

  Future<void> softDeleteItem({required int itemId}) async {
    await supabaseApi.softDeleteItem(itemId: itemId);
  }

  Future<void> restoreItem({required int itemId}) async {
    await supabaseApi.restoreItem(itemId: itemId);
  }

  Future<void> deleteItemPermanently({required int itemId}) async {
    await supabaseApi.deleteItemPermanently(itemId: itemId);
  }

  Future<String> uploadItemImage({
    required Uint8List bytes,
    required String fileName,
    int? itemId,
  }) async {
    return await supabaseApi.uploadItemImage(
      bytes: bytes,
      fileName: fileName,
      itemId: itemId,
    );
  }

  String getItemImagePublicUrl(String imagePath) {
    return supabaseApi.getItemImagePublicUrl(imagePath);
  }

  Future<List<dynamic>> fetchItemImages({required int itemId}) async {
    return await supabaseApi.fetchItemImages(itemId: itemId);
  }

  Future<void> addItemImage({required ItemImageModel itemImage}) async {
    await supabaseApi.addItemImage(itemImage: itemImage);
  }

  Future<void> updateItemImage({required ItemImageModel itemImage}) async {
    await supabaseApi.updateItemImage(itemImage: itemImage);
  }

  Future<void> deleteItemImage({required ItemImageModel itemImage}) async {
    await supabaseApi.deleteItemImage(itemImage: itemImage);
  }

  Future<List<dynamic>> fetchItemColors({required int itemId}) async {
    return await supabaseApi.fetchItemColors(itemId: itemId);
  }

  Future<List<dynamic>> fetchItemSizes({required int itemId}) async {
    return await supabaseApi.fetchItemSizes(itemId: itemId);
  }

  Future<void> replaceItemColors({
    required int itemId,
    required List<ItemColorModel> colors,
  }) async {
    await supabaseApi.replaceItemColors(itemId: itemId, colors: colors);
  }

  Future<void> replaceItemSizes({
    required int itemId,
    required List<ItemSizeModel> sizes,
  }) async {
    await supabaseApi.replaceItemSizes(itemId: itemId, sizes: sizes);
  }

  Future<List<dynamic>> fetchParts() async {
    return await supabaseApi.fetchParts();
  }

  Future<void> addPart({required PartModel part}) async {
    await supabaseApi.addPart(part: part);
  }

  Future<void> updatePart({required PartModel part}) async {
    await supabaseApi.updatePart(part: part);
  }

  Future<void> deletePart({required int partId}) async {
    await supabaseApi.deletePart(partId: partId);
  }

  Future<void> updatePartsOrder({required List<PartModel> parts}) async {
    await supabaseApi.updatePartsOrder(parts: parts);
  }

  Future<List<dynamic>> fetchPartItems({required int partId}) async {
    return await supabaseApi.fetchPartItems(partId: partId);
  }

  Future<void> addPartItem({required PartItemModel partItem}) async {
    await supabaseApi.addPartItem(partItem: partItem);
  }

  Future<void> deletePartItem({required int id}) async {
    await supabaseApi.deletePartItem(id: id);
  }

  Future<void> replacePartItems({
    required int partId,
    required List<int> itemIds,
  }) async {
    await supabaseApi.replacePartItems(partId: partId, itemIds: itemIds);
  }

  Future<List<OrderModel>> fetchOrders() async {
    return await supabaseApi.fetchOrders();
  }

  Future<void> assignOrderToLocation({
    required int orderId,
    required int locationId,
    required String changedBy,
    String? notes,
  }) async {
    await supabaseApi.assignOrderToLocation(
      orderId: orderId,
      locationId: locationId,
      changedBy: changedBy,
      notes: notes,
    );
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
    required String changedBy,
    int? locationId,
    String? notes,
  }) async {
    await supabaseApi.updateOrderStatus(
      orderId: orderId,
      status: status,
      changedBy: changedBy,
      locationId: locationId,
      notes: notes,
    );
  }

  // ─── Notifications ───────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    return await supabaseApi.fetchNotifications();
  }

  Future<List<Map<String, dynamic>>> fetchNotificationCustomers() async {
    return await supabaseApi.fetchNotificationCustomers();
  }

  Future<Map<String, dynamic>> sendBroadcastNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    return await supabaseApi.sendBroadcastNotification(
      title: title,
      body: body,
      type: type,
      payload: payload,
    );
  }

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
    return await supabaseApi.sendNotificationToCustomer(
      customerId: customerId,
      title: title,
      body: body,
      type: type,
      orderId: orderId,
      orderStatus: orderStatus,
      payload: payload,
      imageUrl: imageUrl,
    );
  }

  Future<void> deleteNotification({required int notificationId}) async {
    await supabaseApi.deleteNotification(notificationId: notificationId);
  }

  Future<int> fetchCustomerCount() async {
    return await supabaseApi.fetchCustomerCount();
  }
}
