class CategoryModel {
  String? id;
  String? shopId;
  String? name;
  String? icon;
  String? publicUrl;
  DateTime? createdAt;
  DateTime? updatedAt;

  CategoryModel({
    this.id,
    this.shopId,
    this.name,
    this.icon,
    this.publicUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String?,
      shopId: json['shop_id'] as String?,
      name: json['name'] as String?,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'shop_id': shopId, 'name': name, 'icon': icon};
  }

  CategoryModel copyWith({
    String? id,
    String? shopId,
    String? name,
    String? icon,
    String? publicUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      publicUrl: publicUrl ?? this.publicUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// create table public.categories (
//   id uuid not null default gen_random_uuid (),
//   shop_id uuid not null,
//   name text not null,
//   icon text null,
//   created_at timestamp with time zone not null default now(),
//   updated_at timestamp with time zone not null default now(),
//   constraint categories_pkey primary key (id),
//   constraint categories_unique_name_per_shop unique (shop_id, name),
//   constraint categories_shop_id_fkey foreign KEY (shop_id) references shops (id) on delete CASCADE
// ) TABLESPACE pg_default;
