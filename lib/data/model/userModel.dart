class UserModel {
  final String id;
  final String? username;
  final String? password;
  final String name;
  final String role;
  final int? locationId;

  UserModel({
    required this.id,
    this.username,
    this.password,
    required this.name,
    required this.role,
    required this.locationId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['user_id'] ?? '').toString(),
      username: json['username']?.toString(),
      name: (json['name'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      locationId: (json['location_id'] as num?)?.toInt(),
    );
  }
}
