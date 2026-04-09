class DiscountCodeModel {
  final int? id;
  final String? shopId;
  final String code;
  final String discountType;
  final int? discountPercent;
  final double? discountAmount;
  final double minPurchaseAmount;
  final double? maxDiscountAmount;
  final int? limitCount;
  final int usedCount;
  final DateTime expiryDate;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DiscountCodeModel({
    this.id,
    this.shopId,
    required this.code,
    required this.discountType,
    this.discountPercent,
    this.discountAmount,
    required this.minPurchaseAmount,
    this.maxDiscountAmount,
    this.limitCount,
    required this.usedCount,
    required this.expiryDate,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory DiscountCodeModel.fromJson(Map<String, dynamic> json) {
    return DiscountCodeModel(
      id: json['id'] as int?,
      shopId: json['shop_id']?.toString(),
      code: (json['code'] ?? '').toString(),
      discountType: (json['discount_type'] ?? 'amount').toString(),
      discountPercent: (json['discount_percent'] as num?)?.toInt(),
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      minPurchaseAmount: (json['min_purchase_amount'] as num?)?.toDouble() ?? 0,
      maxDiscountAmount: (json['max_discount_amount'] as num?)?.toDouble(),
      limitCount: (json['limit_count'] as num?)?.toInt(),
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      expiryDate: DateTime.parse(
        (json['expiry_date'] ?? DateTime.now().toIso8601String()).toString(),
      ),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'shop_id': shopId,
      'code': normalizedCode,
      'discount_type': discountType,
      'discount_percent': discountType == 'percent' ? discountPercent : null,
      'discount_amount': discountType == 'amount' ? discountAmount : null,
      'min_purchase_amount': minPurchaseAmount,
      'max_discount_amount': maxDiscountAmount,
      'limit_count': limitCount,
      'used_count': usedCount,
      'expiry_date': expiryDate.toIso8601String().split('T').first,
      'is_active': isActive,
    };
  }

  DiscountCodeModel copyWith({
    int? id,
    String? shopId,
    String? code,
    String? discountType,
    int? discountPercent,
    double? discountAmount,
    double? minPurchaseAmount,
    double? maxDiscountAmount,
    int? limitCount,
    int? usedCount,
    DateTime? expiryDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiscountCodeModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      limitCount: limitCount ?? this.limitCount,
      usedCount: usedCount ?? this.usedCount,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get normalizedCode => code.trim().toUpperCase();

  bool get isPercent => discountType == 'percent';

  bool get isAmount => discountType == 'amount';

  bool get isExpired {
    final DateTime expiryAtEndOfDay = DateTime(
      expiryDate.year,
      expiryDate.month,
      expiryDate.day,
      23,
      59,
      59,
    );
    return expiryAtEndOfDay.isBefore(DateTime.now());
  }

  int? get remainingUses {
    if (limitCount == null) {
      return null;
    }
    return limitCount! - usedCount;
  }

  String get discountLabel {
    if (isPercent) {
      return '${discountPercent ?? 0}%';
    }
    return '${(discountAmount ?? 0).toStringAsFixed(0)} د.ع';
  }
}
