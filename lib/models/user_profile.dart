class UserProfile {
  final String name;
  final String email;
  final String password;
  final String? profileImagePath;

  UserProfile({
    required this.name,
    required this.email,
    required this.password,
    this.profileImagePath,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? password,
    String? profileImagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      profileImagePath: map['profileImagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'profileImagePath': profileImagePath,
    };
  }
}