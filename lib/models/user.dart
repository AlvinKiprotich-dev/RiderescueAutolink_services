class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final List<String> roles;
  final String status;
  final Map<String, dynamic>? currentLocation;
  final bool isOnline;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    required this.roles,
    required this.status,
    this.currentLocation,
    required this.isOnline,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address'],
      roles: List<String>.from(json['roles'] ?? []),
      status: json['status'] ?? 'active',
      currentLocation: json['currentLocation'] as Map<String, dynamic>?,
      isOnline: json['isOnline'] ?? false,
      avatar: json['avatar'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  get phoneVerified => null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'roles': roles,
      'status': status,
      'currentLocation': currentLocation,
      'isOnline': isOnline,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
