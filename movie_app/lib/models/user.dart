class User {
  final String? id;
  final String email;
  final String password;
  final String createdAt;
  final String? membershipType; // 'monthly', 'yearly', or null
  final String? membershipExpiry; // ISO 8601 format
  final bool isActive;
  final String role; // 'admin' or 'user'
  final String? name;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.createdAt,
    this.membershipType,
    this.membershipExpiry,
    this.isActive = false,
    this.role = 'user',
    this.name,
  });

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? createdAt,
    String? membershipType,
    String? membershipExpiry,
    bool? isActive,
    String? role,
    String? name,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      membershipType: membershipType ?? this.membershipType,
      membershipExpiry: membershipExpiry ?? this.membershipExpiry,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      'membershipType': membershipType,
      'membershipExpiry': membershipExpiry,
      'isActive': isActive ? 1 : 0,
      'role': role,
      'name': name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String?,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: map['createdAt'] as String,
      membershipType: map['membershipType'] as String?,
      membershipExpiry: map['membershipExpiry'] as String?,
      isActive: map['isActive'] == 1,
      role: (map['role'] as String?) ?? 'user',
      name: map['name'] as String?,
    );
  }

  bool get isAdmin => role == 'admin';

  // Kiểm tra membership còn hạn
  bool get hasActiveMembership {
    if (!isActive || membershipExpiry == null) return false;
    final expiry = DateTime.tryParse(membershipExpiry!);
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  // Lấy thời gian còn lại của gói
  Duration? get remainingTime {
    if (!hasActiveMembership) return null;
    final expiry = DateTime.parse(membershipExpiry!);
    return expiry.difference(DateTime.now());
  }

  // Lấy số ngày còn lại
  int? get remainingDays {
    final remaining = remainingTime;
    if (remaining == null) return null;
    return remaining.inDays;
  }

  // Lấy tên gói hiển thị
  String get membershipName {
    if (!hasActiveMembership) return 'Chưa có gói';
    return membershipType == 'yearly' ? 'Gói Năm' : 'Gói Tháng';
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, membership: $membershipType, active: $isActive)';
  }
}
