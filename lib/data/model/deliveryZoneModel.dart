class DeliveryZoneModel {
  int? id;
  String? shopId;
  String? city;
  double? price;
  DateTime? createdAt;
  DateTime? updatedAt;

  DeliveryZoneModel({
    this.id,
    this.shopId,
    this.city,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    return DeliveryZoneModel(
      id: json['id'] as int?,
      shopId: json['shop_id'] as String?,
      city: json['city'] as String?,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'shop_id': shopId, 'city': city, 'price': price};
  }

  DeliveryZoneModel copyWith({
    int? id,
    String? shopId,
    String? city,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryZoneModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      city: city ?? this.city,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// create table public.delivery_zones (
//   id bigint generated always as identity not null,
//   shop_id uuid not null,
//   city text not null,
//   price numeric(12, 2) not null default 0,
//   created_at timestamp with time zone not null default now(),
//   updated_at timestamp with time zone not null default now(),
//   constraint delivery_zones_pkey primary key (id),
//   constraint delivery_zones_unique_city unique (shop_id, city),
//   constraint delivery_zones_shop_id_fkey foreign KEY (shop_id) references shops (id) on delete CASCADE
// ) TABLESPACE pg_default;
