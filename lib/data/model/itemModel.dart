class ItemModel {
  int? id;
  String? shopId;
  String? categoryId;
  String? title;
  String? description;
  double? price;
  int? discountPercent;
  bool? isActive;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;

  ItemModel({
    this.id,
    this.shopId,
    this.categoryId,
    this.title,
    this.description,
    this.price,
    this.discountPercent,
    this.isActive,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int?,
      shopId: json['shop_id'] as String?,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      discountPercent: json['discount_percent'] != null
          ? int.tryParse(json['discount_percent'].toString())
          : null,
      isActive: json['is_active'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'discount_percent': discountPercent,
      'is_active': isActive,
      'is_deleted': isDeleted,
    };
  }

  ItemModel copyWith({
    int? id,
    String? shopId,
    String? categoryId,
    String? title,
    String? description,
    double? price,
    int? discountPercent,
    bool? isActive,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

extension ItemModelPricing on ItemModel {
  bool get hasDiscount => (discountPercent ?? 0) > 0;

  double get finalPrice {
    final original = price ?? 0;
    final percent = discountPercent ?? 0;
    if (percent <= 0) {
      return original;
    }
    return original * (1 - (percent / 100));
  }
}

// create table public.items (
//   id bigint generated always as identity not null,
//   shop_id uuid not null,
//   category_id uuid not null,
//   title text not null,
//   description text null,
//   price numeric(12, 2) not null default 0,
//   discount_percent smallint null default 0,
//   is_active boolean not null default true,
//   is_deleted boolean not null default false,
//   created_at timestamp with time zone not null default now(),
//   updated_at timestamp with time zone not null default now(),
//   constraint items_pkey primary key (id),
//   constraint items_category_id_fkey foreign KEY (category_id) references categories (id) on delete RESTRICT,
//   constraint items_shop_id_fkey foreign KEY (shop_id) references shops (id) on delete CASCADE,
//   constraint items_price_chk check ((price >= (0)::numeric))
// ) TABLESPACE pg_default;
