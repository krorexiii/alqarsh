class PartItemModel {
  int? id;
  int? partId;
  int? itemId;
  DateTime? createdAt;

  PartItemModel({this.id, this.partId, this.itemId, this.createdAt});

  factory PartItemModel.fromJson(Map<String, dynamic> json) {
    return PartItemModel(
      id: json['id'] as int?,
      partId: json['part_id'] as int?,
      itemId: json['item_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'part_id': partId, 'item_id': itemId};
  }

  PartItemModel copyWith({
    int? id,
    int? partId,
    int? itemId,
    DateTime? createdAt,
  }) {
    return PartItemModel(
      id: id ?? this.id,
      partId: partId ?? this.partId,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// create table public.part_items (
//   id bigint generated always as identity not null,
//   part_id bigint not null,
//   item_id bigint not null,
//   created_at timestamp with time zone null default now(),
//   constraint part_items_pkey primary key (id),
//   constraint part_items_unique unique (part_id, item_id),
//   constraint part_items_item_id_fkey foreign KEY (item_id) references items (id),
//   constraint part_items_part_id_fkey foreign KEY (part_id) references parts (id)
// ) TABLESPACE pg_default;
