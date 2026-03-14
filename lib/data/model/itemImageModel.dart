class ItemImageModel {
  int? id;
  int? itemId;
  String? imagePath;
  int? sortOrder;
  bool? isPrimary;
  String? publicUrl;
  DateTime? createdAt;

  ItemImageModel({
    this.id,
    this.itemId,
    this.imagePath,
    this.sortOrder,
    this.isPrimary,
    this.publicUrl,
    this.createdAt,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      id: json['id'] as int?,
      itemId: json['item_id'] as int?,
      imagePath: json['image_path'] as String?,
      sortOrder: json['sort_order'] as int?,
      isPrimary: json['is_primary'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'image_path': imagePath,
      'sort_order': sortOrder,
      'is_primary': isPrimary,
    };
  }

  ItemImageModel copyWith({
    int? id,
    int? itemId,
    String? imagePath,
    int? sortOrder,
    bool? isPrimary,
    String? publicUrl,
    DateTime? createdAt,
  }) {
    return ItemImageModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      imagePath: imagePath ?? this.imagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      isPrimary: isPrimary ?? this.isPrimary,
      publicUrl: publicUrl ?? this.publicUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// create table public.item_images (
//   id bigint generated always as identity not null,
//   item_id bigint not null,
//   image_path text not null,
//   sort_order smallint not null default 1,
//   is_primary boolean not null default false,
//   created_at timestamp with time zone not null default now(),
//   constraint item_images_pkey primary key (id),
//   constraint item_images_item_id_fkey foreign KEY (item_id) references items (id) on delete CASCADE
// ) TABLESPACE pg_default;
