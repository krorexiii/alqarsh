class LocationModel {
  final int id;
  final String name;
  final double lX;
  final double lY;
  final String locationName;

  LocationModel({
    required this.id,
    required this.name,
    required this.lX,
    required this.lY,
    required this.locationName,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      lX:
          (json['l_x'] as num?)?.toDouble() ??
          (json['L_X'] as num?)?.toDouble() ??
          0.0,
      lY:
          (json['l_y'] as num?)?.toDouble() ??
          (json['L_y'] as num?)?.toDouble() ??
          0.0,
      locationName: json['location_name'] ?? '',
    );
  }
}
