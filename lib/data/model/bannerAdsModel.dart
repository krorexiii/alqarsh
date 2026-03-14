class BannerAdsModel {
  int? id;
  String? shopId;
  String? imagePath;
  int? sortOrder;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  BannerAdsModel({
    this.id,
    this.shopId,
    this.imagePath,
    this.sortOrder,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerAdsModel.fromJson(Map<String, dynamic> json) {
    return BannerAdsModel(
      id: json['id'],
      shopId: json['shop_id'],
      imagePath: json['image_path'],
      sortOrder: json['sort_order'],
      isActive: json['is_active'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'image_path': imagePath,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  BannerAdsModel copyWith({
    int? id,
    String? shopId,
    String? imagePath,
    String? publicUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerAdsModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      imagePath: imagePath ?? this.imagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// create table public.banner_ads (
//   id bigint generated always as identity not null,
//   shop_id uuid not null,
//   image_path text not null,
//   sort_order smallint not null default 1,
//   is_active boolean not null default true,
//   created_at timestamp with time zone not null default now(),
//   updated_at timestamp with time zone not null default now(),
//   constraint banner_ads_pkey primary key (id),
//   constraint banner_ads_unique_sort unique (shop_id, sort_order),
//   constraint banner_ads_shop_id_fkey foreign KEY (shop_id) references shops (id) on delete CASCADE
// ) TABLESPACE pg_default;
