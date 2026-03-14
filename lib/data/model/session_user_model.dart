class SessionUserModel {
  final String userId;
  final String name;
  final String role;
  final int locationId;

  const SessionUserModel({
    required this.userId,
    required this.name,
    required this.role,
    required this.locationId,
  });

  bool get isAdmin => role == 'admin';

  factory SessionUserModel.fromJson(Map<String, dynamic> json) {
    return SessionUserModel(
      userId: (json['user_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? 'staff').toString(),
      locationId: json['location_id'] as int? ?? 0,
    );
  }
}
