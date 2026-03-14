class PartModel {
  int? id;
  String? shopId;
  String? name;
  int? sortOrder;
  bool? isActive;
  DateTime? createdAt;

  PartModel({
    this.id,
    this.shopId,
    this.name,
    this.sortOrder,
    this.isActive,
    this.createdAt,
  });

  factory PartModel.fromJson(Map<String, dynamic> json) {
    return PartModel(
      id: json['id'] as int?,
      shopId: json['shop_id'] as String?,
      name: json['name'] as String?,
      sortOrder: json['sort_order'] as int?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'name': name,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  PartModel copyWith({
    int? id,
    String? shopId,
    String? name,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PartModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// create table public.parts (
//   id bigint generated always as identity not null,
//   shop_id uuid not null,
//   name text not null,
//   sort_order smallint null default 1,
//   is_active boolean null default true,
//   created_at timestamp with time zone null default now(),
//   constraint parts_pkey primary key (id),
//   constraint parts_shop_id_fkey foreign KEY (shop_id) references shops (id)
// ) TABLESPACE pg_default;
