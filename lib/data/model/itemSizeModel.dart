class ItemSizeModel {
  final int? id;
  final int? itemId;
  final String name;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ItemSizeModel({
    this.id,
    this.itemId,
    required this.name,
    this.sortOrder = 1,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemSizeModel.fromJson(Map<String, dynamic> json) {
    return ItemSizeModel(
      id: json['id'] as int?,
      itemId: json['item_id'] as int?,
      name: (json['name'] ?? '').toString(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 1,
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
    return {
      'item_id': itemId,
      'name': name,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  ItemSizeModel copyWith({
    int? id,
    int? itemId,
    String? name,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemSizeModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
